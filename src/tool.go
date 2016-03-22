package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"os/exec"
	"strings"

	"github.com/skip2/go-qrcode"
)

// Tool use for some command line operations
type Tool struct {
	Password          string
	ShadowsocksServer string
}

// NewRedsocksChain to create a new chain in iptables with name REDSOCKS
func (t *Tool) NewRedsocksChain() error {
	cmdLine := "iptables -t nat -n -L REDSOCKS"
	_, ebytes, err := t.sudo(cmdLine)

	if err != nil {
		if strings.Contains(string(ebytes), "No chain/target/match by that name") {
			logger.Println(string(ebytes))
			_, _, err := t.sudo("iptables -t nat -N REDSOCKS")
			if err != nil {
				return err
			}
		} else {
			return err
		}
	}

	return nil
}

// RemoveRedsocksChain to clear configs of iptables
func (t *Tool) RemoveRedsocksChain() {
	// remove rules in OUTPUT
	line := "iptables -t nat -D OUTPUT -p tcp -j REDSOCKS"
	_, _, err := t.sudo(line)
	if err != nil {
		// logger.Println(line)
		// logger.Println(string(e), err)
		return
	}

	// remove rules in REDSOCKS
	line = "iptables -t nat -F REDSOCKS"
	_, _, err = t.sudo(line)
	if err != nil {
		// logger.Println(line)
		// logger.Println(string(e), err)
		return
	}

	// remove chain REDSOCKS
	line = "iptables -t nat -X REDSOCKS"
	_, _, err = t.sudo(line)
	if err != nil {
		// logger.Println(line)
		// logger.Println(string(e), err)
		return
	}

	line = "iptables -t nat -D OUTPUT -m udp -p udp --dport 53 -d 127.0.1.1 -j REDIRECT --to-port 5354"
	_, _, err = t.sudo(line)
	if err != nil {
		// logger.Println(line)
		// logger.Println(string(e), err)
		return
	}
}

// IgnoreLANs to ignore LANs in REDSOCKS
func (t *Tool) IgnoreLANs() {

	LANs := []string{
		"0.0.0.0/8",
		"10.0.0.0/8",
		"127.0.0.0/8",
		"169.254.0.0/16",
		"172.16.0.0/12",
		"192.168.0.0/16",
		"224.0.0.0/4",
		"240.0.0.0/4",
	}

	for _, lan := range LANs {
		line := fmt.Sprintf("iptables -t nat -A REDSOCKS -d %s -j RETURN", lan)
		_, e, err := t.sudo(line)
		if err != nil {
			// logger.Println(line)
			logger.Println(string(e), err)
		}
	}
}

// IgnoreShadowsocksServer to ignore ss-server in REDSOCKS
func (t *Tool) IgnoreShadowsocksServer() {
	line := fmt.Sprintf("iptables -t nat -A REDSOCKS -d %s -j RETURN", t.ShadowsocksServer)
	_, e, err := t.sudo(line)
	if err != nil {
		// logger.Println(line)
		logger.Println(string(e), err)
	}
}

// RedirectToRedsocksPort redirect tcp connections to Redsocks' port
func (t *Tool) RedirectToRedsocksPort(port int) {
	line := fmt.Sprintf("iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports %d", port)
	_, e, err := t.sudo(line)
	if err != nil {
		// logger.Println(line)
		logger.Println(string(e), err)
	}
}

// RedirectToRedsocksChain redirect OUTPUT to REDSOCKS
func (t *Tool) RedirectToRedsocksChain() {
	line := "iptables -t nat -A OUTPUT -p tcp -j REDSOCKS"
	_, e, err := t.sudo(line)
	if err != nil {
		// logger.Println(line)
		logger.Println(string(e), err)
	}
}

// RedirectDNSToChinaDNS redirect udp package to port 5354
func (t *Tool) RedirectDNSToChinaDNS() {
	line := "iptables -t nat -A OUTPUT -m udp -p udp --dport 53 -d 127.0.1.1 -j REDIRECT --to-port 5354"
	// line := "iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:5354"
	_, e, err := t.sudo(line)
	if err != nil {
		// logger.Println(line)
		logger.Println(string(e), err)
	}
}

func (t *Tool) sudo(cmdLine string) ([]byte, []byte, error) {
	var err error

	err = t.sudoValidate(t.Password)
	if err != nil {
		return nil, nil, err
	}

	outBuf := &bytes.Buffer{}
	errBuf := &bytes.Buffer{}

	cmd := exec.Command("sudo", strings.Split(cmdLine, " ")...)
	cmd.Stdout = outBuf
	cmd.Stderr = errBuf

	err = cmd.Run()

	return outBuf.Bytes(), errBuf.Bytes(), err
}

func (t *Tool) sudoValidate(password string) error {
	errBuf := &bytes.Buffer{}
	cmd := exec.Command("sudo", "-S", "-p", "passwdprompt\n", "-v")
	cmd.Stderr = errBuf
	stdin, _ := cmd.StdinPipe()
	err := cmd.Start()
	if err != nil {
		return err
	}
	stdin.Write([]byte(password + "\n"))
	stdin.Close()
	err = cmd.Wait()
	if err != nil {
		if strings.Contains(errBuf.String(), "passwdprompt") {
			return errors.New("password error")
		}
		return err
	}
	return nil
}

// CheckPassword check sudo password
func (t *Tool) CheckPassword(password string) bool {
	// t.Password = password

	err := t.sudoValidate(password)
	if err != nil {
		logger.Println(err)
		return false
	}
	return true
}

// SsQRCode generate a QRCode for ss-url
func (t *Tool) SsQRCode(method, password, server string, port int) string {
	plain := fmt.Sprintf("%s:%s@%s:%d", method, password, server, port)
	encoded := base64.StdEncoding.EncodeToString([]byte(plain))
	qr, _ := qrcode.Encode("ss://"+encoded, qrcode.Medium, 256)
	qrBase64 := base64.StdEncoding.EncodeToString(qr)
	return qrBase64
}

// SetLifecycleExemptAppids to ensure App can running in the background
func (t *Tool) SetLifecycleExemptAppids() {
	outBuf := &bytes.Buffer{}
	errBuf := &bytes.Buffer{}
	cmd := exec.Command("gsettings", "get", "com.canonical.qtmir", "lifecycle-exempt-appids")
	cmd.Stdout = outBuf
	cmd.Stderr = errBuf

	cmd.Run()

	if errBuf.String() != "" {
		logger.Println(errBuf)
		return
	}

	output := strings.TrimSpace(outBuf.String())

	if strings.Contains(output, "shadowsocks.ubuntu-dawndiy") {
		return
	}

	if strings.HasPrefix(output, "[") && strings.HasSuffix(output, "]") {
		logger.Println("Add shadowsocks.ubuntu-dawndiy to", output)
		o := strings.Replace(output, "'", `"`, -1)
		data := []string{}
		if err := json.Unmarshal([]byte(o), &data); err != nil {
			logger.Println(err)
		}
		data = append(data, "shadowsocks.ubuntu-dawndiy")
		b, err := json.Marshal(data)
		if err != nil {
			logger.Println(err)
			return
		}
		value := strings.Replace(string(b), `"`, "'", -1)
		params := []string{"set", "com.canonical.qtmir", "lifecycle-exempt-appids", fmt.Sprintf("%s", value)}
		c := exec.Command("gsettings", params...)
		// c.Stdout = os.Stdout
		// c.Stderr = os.Stderr
		c.Run()
	} else {
		params := []string{"set", "com.canonical.qtmir", "lifecycle-exempt-appids", "['shadowsocks.ubuntu-dawndiy']"}
		logger.Println("Add shadowsocks.ubuntu-dawndiy to empty list")
		c := exec.Command("gsettings", params...)
		// c.Stdout = os.Stdout
		// c.Stderr = os.Stderr
		c.Run()
	}

}

// Run to run a series of commands
func (t *Tool) Run() bool {
	t.RemoveRedsocksChain()
	err := t.NewRedsocksChain()
	if err != nil {
		return false
	}
	t.IgnoreLANs()
	t.IgnoreShadowsocksServer()
	t.RedirectToRedsocksPort(12345)
	t.RedirectDNSToChinaDNS()
	t.RedirectToRedsocksChain()
	t.SetLifecycleExemptAppids()
	return true
}
