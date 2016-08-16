import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "ui"
import "js"

MainView {
    id: root
    objectName: "mainView"
    applicationName: "shadowsocks.ubuntu-dawndiy"

    property var profile: null

    width: units.gu(50)
    height: units.gu(75)
    anchorToKeyboard: true

    Component.onCompleted: {
        console.log("---- START ----")
        mainPageStack.push(tabs)
    }

    /**
     * Show a notification
     */
    function notification(text, duration) {
        var noti = Qt.createComponent(Qt.resolvedUrl("component/SnackBar.qml"))
        noti.createObject(root, {text: text, duration: duration})
    }

    /**
     * Traffic Formatter
     */
    function formatTraffic(bytes) {
        var num = 0, unit = "Bytes";
        if (bytes < 1024) {
            num = bytes
            unit = "Bytes"
        } else if (bytes < 1024*1024) {
            num = bytes / 1024
            unit = "KB"
        } else if (bytes < 1024*1024*1024) {
            num = bytes / (1024*1024)
            unit = "MB"
        } else if (bytes < 1024*1024*1024*1024) {
            num = bytes / (1024*1024*1024)
            unit = "GB"
        } else {
            num = bytes / (1024*1024*1024*1024)
            unit = "TB"
        }
        if ((num % 1) > 0) {
            num = num.toFixed(2)
        }
        return num + " " + unit
    }


    ShadowsocksClient {
        id: ssClient
        objectName: "ssClient"
    }

    Storage {
        id: storage
    }

    FontLoader {
        id: icelandFont
        source: Qt.resolvedUrl("font/Iceland.ttf")
    }

    PageStack {
        id: mainPageStack

        Tabs {
            id: tabs
            anchors.fill: parent

            Tab {
                id: homeTab
                title: i18n.tr("Shadowsocks")
                page: Loader {
                    parent: homeTab
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    source: Qt.resolvedUrl("ui/HomePage.qml")
                }
            }

            Tab {
                id: profilesTab
                title: i18n.tr("Profiles")
                page: Loader {
                    parent: profilesTab
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    source: (tabs.selectedTab === profilesTab) ? Qt.resolvedUrl("ui/ProfilesPage.qml") : ""
                }
            }
        }
    }

    Component {
        id: passwordPopup
        Dialog {
            id: passwordDialog
            title: i18n.tr("Enter password")
            text: i18n.tr("Your password is required for this action")

            signal accepted(string password)
            signal rejected()

            TextField {
                id: passwordText
                echoMode: TextInput.Password
            }

            Button {
                text: "OK"
                color: UbuntuColors.green
                onClicked: {
                    passwordDialog.accepted(passwordText.text)
                    PopupUtils.close(passwordDialog)
                }
            }

            Button {
                text: "Cancel"
                color: UbuntuColors.red
                onClicked: {
                    passwordDialog.rejected()
                    PopupUtils.close(passwordDialog)
                }
            }
        }
    }
}
