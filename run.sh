#!/bin/bash

function build()
{
    GOROOT="/usr/local/lib/go1.5"
    # GOROOT="/usr/local/lib/go1.6"
    cd ./src
    GOROOT=$GOROOT $GOROOT/bin/go build -o ../shadowsocks
    cd ../
}

rm ./shadowsocks

while getopts "b" optname
  do
    case "$optname" in
      "b")
        echo -n "Building..."
        build
        echo "OK"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
  done

./shadowsocks
