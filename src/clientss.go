package main

import (
	"fmt"
	"net"
	"net/http"
	"time"

	ss "github.com/shadowsocks/shadowsocks-go/shadowsocks"
)

// ShadowsocksClient
type ShadowsocksClient struct {
	ss.Config
	Running      bool
	service      *Service
	serverCipher *ServerCipher
}

// Run to start up local service
func (sc *ShadowsocksClient) Run() {

	ch := make(chan error)

	go func(ch chan error) {

		logger.Println("==RUN==...")

		if err := sc.parseConfig(); err != nil {
			ch <- err
			return
		}

		listenAddr := "0.0.0.0:1080"
		addr, _ := net.ResolveTCPAddr("tcp", listenAddr)

		listener, err := net.ListenTCP("tcp", addr)
		if err != nil {
			logger.Println(err)
			ch <- err
			return
		}
		logger.Printf("Starting local socks5 server at %v", listener.Addr())

		service := NewService(sc.serverCipher)
		service.SetTrafficListener(sc)
		sc.service = service
		go service.Serve(listener)
		sc.Running = true
		ch <- nil
	}(ch)

	go func(ch chan error) {
		if result := <-ch; result != nil {
			sc.emitSignal("startFailed", result.Error())
			logger.Println("==RUN==...failed")
		} else {
			sc.emitSignal("startSucceed", "")
			logger.Println("==RUN==...succeed")
		}
	}(ch)
}

// Stop to stop local service
func (sc *ShadowsocksClient) Stop() {

	ch := make(chan bool)

	go func(ch chan bool) {
		logger.Println("==STOP==...STOPPING")
		if sc.Running {
			sc.service.Stop()
			sc.Running = false
		}
		ch <- true
	}(ch)

	go func(ch chan bool) {
		<-ch
		sc.emitSignal("stopped", "")
		logger.Println("==STOP==...STOPPED")
	}(ch)
}

func (sc *ShadowsocksClient) emitSignal(signal, data string) {
	handler := root.ObjectByName("ssClient")
	handler.Call("emitSignal", signal, data)
}

func (sc *ShadowsocksClient) parseConfig() error {
	// if remote := net.ParseIP(fmt.Sprint(sc.Server)); remote == nil {
	// 	return errors.New(fmt.Sprintf("%v is not a valid ip address", sc.Server))
	// }
	sc.Server = fmt.Sprintf("%v:%d", sc.Server, sc.ServerPort)
	if cipher, err := ss.NewCipher(sc.Method, sc.Password); err != nil {
		return err
	} else {
		sc.serverCipher = &ServerCipher{fmt.Sprint(sc.Server), cipher}
	}

	return nil
}

func (sc *ShadowsocksClient) Sent(n int) {
	sc.emitSignal("sent", fmt.Sprint(n))
}
func (sc *ShadowsocksClient) Received(n int) {
	sc.emitSignal("received", fmt.Sprint(n))
}

func (sc *ShadowsocksClient) CheckConnectivity() {

	ch := make(chan string)

	go func(ch chan string) {
		testURL := "https://www.google.com/generate_204"
		client := &http.Client{}
		client.Timeout = time.Second * 5
		start := time.Now().UnixNano()
		res, err := client.Get(testURL)
		elapsed := (time.Now().UnixNano() - start) / 1000000
		if err != nil {
			ch <- "err," + err.Error()
			return
		} else {
			if res.StatusCode == 204 || res.StatusCode == 200 && res.ContentLength == 0 {
				ch <- fmt.Sprintf("%s,%d", "ok", elapsed)
				return
			} else {
				ch <- fmt.Sprint("codeErr,")
				return
			}
		}
	}(ch)

	go func(ch chan string) {
		msg := <-ch
		sc.emitSignal("checkFinished", msg)
	}(ch)
}
