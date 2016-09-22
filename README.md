# shadowsocks-ubuntu

[![GitHub release](https://img.shields.io/github/release/dawndiy/shadowsocks-ubuntu.svg?maxAge=2592000)](https://github.com/dawndiy/shadowsocks-ubuntu/releases/latest)
[![GitHub license](https://img.shields.io/badge/license-AGPL-blue.svg)](https://raw.githubusercontent.com/dawndiy/shadowsocks-ubuntu/master/LICENSE)
[![Github All Releases](https://img.shields.io/github/downloads/dawndiy/shadowsocks-ubuntu/total.svg?maxAge=2592000)](https://github.com/dawndiy/shadowsocks-ubuntu/releases)
[![uApp OpenStore](https://img.shields.io/badge/OpenStore-shadowsocks-4caf50.svg)](https://open.uappexplorer.com/app/shadowsocks.ubuntu-dawndiy)

<img src="app/icon.png" width="150">

Shadowsocks-ubuntu is a [shadowsocks](https://shadowsocks.org) client for Ubuntu Touch

## What is shadowsocks?
A secure socks5 proxy, designed to protect your Internet traffic.  
Shadowsocks-ubuntu is designed to be a global proxy for Ubuntu Touch.

## Install
You can find the latest click package in [**HERE**](https://github.com/dawndiy/shadowsocks-ubuntu/releases).  
Copy the .click file to phone's home folder via adb: `adb push <PACKAGE-FILE> /home/phablet/`  
Run `adb shell 'pkcon install-local --allow-untrusted <PACKAGE-FILE>'` to install.

Now, you can also find & install it from [OpenStore](https://open.uappexplorer.com/app/shadowsocks.ubuntu-dawndiy).

## Build
Shadowsocks-ubuntu is written in Golang. You must has golang installed before build it from source code.  
How to install golang: https://golang.org/doc/install  
NOTE: use go1.5 for build, not use go1.6 now.

Shadowsocks-ubuntu is build on these projects, and thanks for these projects:

- [go-qml](https://github.com/go-qml/qml)
- [shadowsocks-go](https://github.com/shadowsocks/shadowsocks-go)
- [ChinaDNS](https://github.com/shadowsocks/ChinaDNS)
- [redsocks](https://github.com/darkk/redsocks)
- [go-qrcode](https://github.com/skip2/go-qrcode)

**builder.py** is a simple script written in python3 for build Shadowsocks-ubuntu.

### Install necessary libraries: 

```bash
$ ./builder.py update-go-packages
```
This command will download necessary go packages using `go get`.

### Build redsocsk & chinadns: 

Use the packages from Ubuntu archives (Recommend)

```
sudo click chroot -a armhf -f ubuntu-sdk-15.04 -s vivid run apt-get install libevent-dev:armhf redsocks:armhf
```
Then find `libevent-2.0.so.5` and `redsocks` in the click chroot. Copy them into folder `armhf`


Also you can build it by youself:

[HERE](BUILD.md) is about how to build the binary files of **redsocks** & **chinadns**.

### Build click package for Ubuntu Phone

Before build, change `go_root` with your **GOROOT** in *builder.py* .  
Run this command to build the click package for Ubuntu Touch.  
```bash
$ ./builder.py build
```

And you can use `./builder.py install` to install the click package you build into your device.

## License

Copyright (C) 2016  [DawnDIY](http://dawndiy.com/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
