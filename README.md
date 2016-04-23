# shadowsocks-ubuntu

Shadowsocks-ubuntu is a [shadowsocks](https://shadowsocks.org) client for Ubuntu Touch

## What is shadowsocks?
A secure socks5 proxy, designed to protect your Internet traffic.  
Shadowsocks-ubuntu is designed to be a global proxy for Ubuntu Touch.

## Build & Install

### Install
You can find the latest click package in [HERE](https://github.com/dawndiy/shadowsocks-ubuntu/releases).  
Copy the .click file to phone's home folder via adb: `adb push <PACKAGE-FILE> /home/phablet/`  
Run `adb push pkcon install-local --allow-untrusted <PACKAGE-FILE>` to install.

### Build
Shadowsocks-ubuntu is written in Golang. You must has golang installed before build it from source code.  
How to install golang: https://golang.org/doc/install  
NOTE: use go1.5 for build, not use go1.6 now.

Shadowsocks-ubuntu is build on these projects, and thanks for these projects:

- [go-qml](https://github.com/go-qml/qml)
- [shadowsocks-go](https://github.com/shadowsocks/shadowsocks-go)
- [ChinaDNS](https://github.com/shadowsocks/ChinaDNS)
- [redsocks](https://github.com/darkk/redsocks)
- [go-qrcode](https://github.com/skip2/go-qrcode)

Install necessary libraries: 

```
go get go-qml/qml
go get shadowsocks/shadowsocks-go
go get skip2/go-qrcode
```

Build redsocsk & chinadns: 

[HERE](BUILD.md) is about how to build the binary files of **redsocks** & **chinadns**.

Before build, change `CURRENT_DIR` with your **GOPATH** and `GOROOT` with your **GOROOT** in *build-click-package.sh* .  
Run this command to build the click package for Ubuntu Touch.  
`./build-click-package.sh shadowsocks ubuntu-sdk-15.04 vivid`

