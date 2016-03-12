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
        text: i18n.tr("<b>Shadowsocks</b>")
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
        anchors.topMargin: units.gu(4)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Version:\t0.0.1\nAuthor:\tDawnDIY")
    }

    Label {
        anchors.top: info.bottom
        anchors.topMargin: units.gu(4)
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Powered by <b>go-qml</b>")
    }
}
