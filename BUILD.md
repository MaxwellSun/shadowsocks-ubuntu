# Build redsocks for armhf 

The project repository is [here](https://github.com/darkk/redsocks)

libevent-2.0.x is required. So let's build libevent first.

- Download libevent from [here](https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz)
- `tar zxf libevent-<VERSION>-stable.tar.gz <YOUR_LIBEVENT_PATH>`
- `cd <YOUR_LIBEVENT_PATH>`
- `export CC=arm-linux-gnueabihf-gcc`
- `./configure --host=arm-linux-gnueabi`
- `make`

build redsocks  

- `git clone git@github.com:darkk/redsocks.git <YOUR_REDSOCKS_PATH>`
- `sudo click chroot -a armhf -f ubuntu-sdk-15.04 -s vivid maint`
- `cd <YOUR_REDSOCKS_PATH>`
- `export CC=arm-linux-gnueabihf-gcc`
- `CFLAGS="-static -I<YOUR_LIBEVENT_PATH>/include" LDFLAGS="-L<YOUR_LIBEVENT_PATH>/.lib" make`

Then you will get the **redsocks** binary in `<YOUR_REDSOCKS_PATH>`.


# Build ChinaDNS for armhf

The project repository is [here](https://github.com/shadowsocks/ChinaDNS)

- Download the latest release from [here](export CC://github.com/shadowsocks/ChinaDNS/releases) (chinadns-*VERSION*.tar.gz).
- `tar zxf chinadns-*VERSION*.tar.gz <YOUR_CHINADNS_PATH>`
- `sudo click chroot -a armhf -f ubuntu-sdk-15.04 -s vivid maint`
- `cd <YOUR_CHINADNS_PATH>`
- `export CC=arm-linux-gnueabihf-gcc`
- `./configure --host=arm-linux-gnueabi && make`

Then you will get the **chinadns** binary in `<YOUR_CHINADNS_PATH>/src/`.


Finally, copy this two files into armh folder for build the click package.
