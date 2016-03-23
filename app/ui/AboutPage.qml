import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: aboutPage

    title: i18n.tr("About")

    Image {
        id: image
        anchors.top: parent.top
        anchors.topMargin: units.gu(8)
        anchors.horizontalCenter: parent.horizontalCenter
        source: Qt.resolvedUrl("../icon.png")
        sourceSize.width: units.gu(20)
        sourceSize.height: units.gu(20)
    }

    Label {
        id: title
        anchors.top: image.bottom
        anchors.topMargin: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("<b>Shadowsocks 1.0.0</b>")
        fontSize: "large"
    }

    Label {
        id: subtitle
        anchors.top: title.bottom
        anchors.right: title.right
        text: i18n.tr("for Ubuntu Touch")
        fontSize: "small"
    }

    Label {
        id: info
        anchors.top: subtitle.bottom
        anchors.topMargin: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("A Shoadowsocks client for Ubuntu, written in Golang.")
    }

    Label {
        id: copyright
        anchors.top: info.bottom
        anchors.topMargin: units.gu(1)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("(C) Copyright 2016 by DawnDIY")
        fontSize: "small"
    }

    Label {
        id: tks
        anchors.top: copyright.bottom
        anchors.topMargin: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Thanks to:")
        fontSize: "small"
    }

    Label {
        id: proj
        anchors.top: tks.bottom
        anchors.topMargin: units.gu(1)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("<a href='https://github.com/go-qml/qml'>go-qml</a><br/><a href='https://github.com/shadowsocks/shadowsocks-go'>Shadowsocks-go</a><br/><a href='https://github.com/shadowsocks/ChinaDNS'>ChinaDNS</a><br/><a href='https://github.com/darkk/redsocks'>Redsocks</a>")
        linkColor: UbuntuColors.orange
        onLinkActivated: Qt.openUrlExternally(link)
        fontSize: "small"
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(4)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Powered by <b>go-qml</b>")
    }
}
