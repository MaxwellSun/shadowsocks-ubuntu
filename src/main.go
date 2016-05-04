package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

	"gopkg.in/qml.v1"
)

var (
	logger = log.New(os.Stdout, "", log.LstdFlags|log.Lshortfile)
	root   qml.Object
	tool   = &Tool{}
)

func main() {
	logger.Println("==START==")

	// try to recovery system status
	defer func() {
		tool.RemoveRedsocksChain()
	}()

	// Run redsocks proccess
	go runRedSocks(false)
	// Run chinadns proccess
	go runChinaDNS(false)

	err := qml.Run(run)
	logger.Println(err)
}

// Run QML
func run() error {

	qml.RegisterTypes("Shadowsocks", 1, 0, []qml.TypeSpec{{
		Init: func(v *ShadowsocksClient, obj qml.Object) {},
	}})

	engine := qml.NewEngine()
	context := engine.Context()
	context.SetVar("Tool", tool)

	component, err := engine.LoadFile("app/main.qml")
	if err != nil {
		return err
	}
	win := component.CreateWindow(nil)
	root = win.Root()
	win.Show()
	win.Wait()
	return nil
}

// Run redsocks proccess
func runRedSocks(debug bool) {
	cmd := exec.Command("redsocks", "-c", "redsocks.conf")

	if debug {

		stdout, _ := cmd.StdoutPipe()
		stderr, _ := cmd.StderrPipe()

		c := time.Tick(time.Second)
		go func() {
			for range c {
				p := make([]byte, 1024)
				stdout.Read(p)
				fmt.Print(string(p))
			}
		}()

		c1 := time.Tick(time.Second)
		go func() {
			for range c1 {
				p := make([]byte, 1024)
				stderr.Read(p)
				fmt.Print(string(p))
			}
		}()
	}

	cmd.Run()
}

// Run chinaDNS proccess
func runChinaDNS(debug bool) {
	cmd := exec.Command("chinadns", "-m", "-c", "chnroute.txt", "-p", "5354")

	if debug {

		stdout, _ := cmd.StdoutPipe()
		stderr, _ := cmd.StderrPipe()

		c := time.Tick(time.Second)
		go func() {
			for range c {
				p := make([]byte, 1024)
				stdout.Read(p)
				fmt.Print(string(p))
			}
		}()

		c1 := time.Tick(time.Second)
		go func() {
			for range c1 {
				p := make([]byte, 1024)
				stderr.Read(p)
				fmt.Print(string(p))
			}
		}()
	}

	cmd.Run()
}
