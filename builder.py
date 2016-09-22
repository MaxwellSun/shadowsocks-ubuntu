#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import shutil
import argparse
import subprocess

from glob import glob


app_name = "shadowsocks"
nick_name = "ubuntu-dawndiy"
package_name = ".".join([app_name, nick_name])
build_framework = "ubuntu-sdk-15.04"
build_serise = "vivid"

go_root = "/usr/local/go"
# go_path = "/home/dawndiy/workspace/golang"
go_path = "{}/gopkg".format(os.getcwd())
go_packages = [
    "github.com/shadowsocks/shadowsocks-go/shadowsocks",
    "github.com/skip2/go-qrcode",
    "golang.org/x/crypto/blowfish",
    "golang.org/x/crypto/cast5",
    "golang.org/x/crypto/salsa20/salsa",
    "gopkg.in/qml.v1",
]


def build_click():
    """
    Build click package
    """

    print("Copying files...", end="")

    shutil.rmtree("build", ignore_errors=True)
    # os.mkdir("build")
    os.makedirs("build/lib/")

    shutil.copytree("lib/arm-linux-gnueabihf", "build/lib/arm-linux-gnueabihf")
    shutil.copytree("app", "build/app")
    shutil.copy("manifest.json", "build")
    shutil.copy("apparmor.json", "build")
    shutil.copy("{}.desktop".format(app_name), "build")
    # shutil.copy("{}.url-dispatcher".format(app_name), "build")
    shutil.copy("redsocks.conf", "build")
    shutil.copy("chnroute.txt", "build")
    shutil.copy("splash.png", "build")

    translation_mo()
    shutil.copytree("share", "build/share")

    print("DONE")

    r = build_go()

    if not r:
        return

    print("Building click package...")

    r = subprocess.run("click build build/", shell=True)

    if r.returncode == 0:
        print("Building click package...OK")
    else:
        print("Building click package...Failed")


def build_go():
    """
    Build binary file from go code
    """

    print("Building binary...")

    command = (
        "click chroot "
        "-a armhf "
        "-f {framework} "
        "-s {serise} "
        "run "
        "CGO_ENABLED=1 "
        "GOARCH=arm "
        "GOARM=7 "
        "PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig:"
        "/usr/libpkgconfig:/usr/share/pgconfig "
        "GOROOT={go_root} "
        "GOPATH={go_path} "
        "CC=arm-linux-gnueabihf-gcc "
        "CXX=arm-linux-gnueabihf-g++ "
        "{go_root}/bin/go build -o build/{app_name} "
        "-ldflags '-extld=arm-linux-gnueabihf-g++' "
        "./src"
    ).format(framework=build_framework,
             serise=build_serise,
             go_root=go_root,
             go_path=go_path,
             app_name=app_name)

    r = subprocess.run(command, shell=True)

    if r.returncode == 0:
        print("Building binary...OK")
        return True
    else:
        print("Building binary...Failed")
        return False


def click_push(path="/home/phablet"):
    """
    Push click package to the phone by using adb push
    """

    click = click_find()

    if not click:
        print("No click package found")
        return

    command = "adb push {} {}".format(click, path)
    subprocess.run(command, shell=True)


def click_install():
    """
    Install click package in the phone
    """

    click = click_find()

    if not click:
        print("No click package found")
        return

    command = "adb shell pkcon install-local --allow-untrusted {}".format(click)
    subprocess.run(command, shell=True)


def click_find():
    """
    Find newest click package
    """

    clicks = glob("*.click")
    clicks.sort()
    if clicks:
        return clicks[-1]
    else:
        return None


def get_go_packages():
    """
    Get or update go packages
    """

    pkgs = " ".join(go_packages)

    command = "GOPATH={go_path} {go_root}/bin/go get -u {pkgs}".format(
        go_path=go_path, go_root=go_root, pkgs=pkgs)
    subprocess.run(command, shell=True)


def run_local():
    """
    Build and run for local test
    """

    print("Building & run...")
    go_root = "/usr/local/go1.5"
    command = (
        "GOPATH={go_path} GOROOT={go_root} {go_root}/bin/go build "
        "-o {app_name} ./src && PATH=$PATH:. ./{app_name}"
    ).format(go_path=go_path, go_root=go_root, app_name=app_name)
    subprocess.run(command, shell=True)


def translation_mo():
    """
    Generate mo files
    """

    shutil.rmtree("share", ignore_errors=True)
    lst = glob("po/*.po")
    for file in lst:
        code = file.split(".")[0][3:]
        os.makedirs("share/locale/{}/LC_MESSAGES".format(code))
        command = (
            "msgfmt po/{code}.po "
            "-o share/locale/{code}/LC_MESSAGES/{package}.mo"
        ).format(code=code, package=package_name)
        subprocess.run(command, shell=True)


def translation_po(language_code):
    """
    Generate po files
    """

    command = (
        "msginit -i po/{package_name}.pot "
        "-o po/{language_code}.po"
    ).format(package_name=package_name, language_code=language_code)
    subprocess.run(command, shell=True)


def translation_po_update():
    """
    Update PO files
    merging POT into PO
    """

    lst = glob("po/*.po")
    for file in lst:
        command = (
            "msgmerge -vU {file_name} po/{package_name}.pot"
        ).format(file_name=file, package_name=package_name)
        subprocess.run(command, shell=True)


def translation_update():
    """
    Update translations, new POT file
    """

    command = (
        "find ./app -iname '*.qml' | "
        "xargs xgettext -o po/{package_name}.pot "
        "--from-code=UTF-8 --c++ --qt --add-comments=TRANSLATORS "
        "--keyword=tr --keyword=tr:1,2 --keyword=N_ "
        "--package-name='{package_name}'"
    ).format(package_name=package_name)
    subprocess.run(command, shell=True)


if __name__ == "__main__":

    arguments = [
        "build",
        "install",
        "run",
        "update-go-packages",
        "update-translations",
        "update-po",
        "update-mo",
    ]

    parser = argparse.ArgumentParser()
    parser.add_argument("operation", type=str, choices=arguments)
    args = parser.parse_args()

    if args.operation == "build":
        build_click()
    elif args.operation == "install":
        click_push()
        click_install()
    elif args.operation == "run":
        run_local()
    elif args.operation == "update-go-packages":
        get_go_packages()
    elif args.operation == "update-translations":
        translation_update()
    elif args.operation == "update-po":
        translation_po_update()
    elif args.operation == "update-mo":
        translation_mo()

