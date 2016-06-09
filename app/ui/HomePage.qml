import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import "../component"

Page {
    id: homePage

    property string validPassword: ""

    function runService() {
        console.log("-----------------------------")
        console.log("Server:", profile.server)
        console.log("Remote Port:", profile.remote_port)
        console.log("Local Port:", profile.local_port)
        // console.log("Password:", profile.password)
        console.log("Method:", profile.method)
        console.log("-----------------------------")

        ssClient.config.server = profile.server
        ssClient.config.serverPort = Number(profile.remote_port)
        ssClient.config.localPort = Number(profile.local_port)
        ssClient.config.localPort = 1080
        ssClient.config.password = profile.password
        ssClient.config.method = profile.method

        ssClient.run()

        Tool.removeRedsocksChain()
        Tool.run()
    }

    function stopService() {
        Tool.removeRedsocksChain()
        ssClient.stop()
    }

    header: SSHeader {

        title: "Shadowsocks"

        // opacity: 0.8

        contents: Label {
            anchors.verticalCenter: parent.verticalCenter;
            text: header.title
            fontSize: "x-large"
            font.family: icelandFont.name
            font.weight: Font.DemiBold
            color: "white"
        }

        leadingActionBar {

            actions: [
                Action {
                    text: i18n.tr("Home")
                    iconName: "send"
                    onTriggered: {
                        tabs.selectedTabIndex = 0
                    }
                },
                Action {
                    text: i18n.tr("Profiles")
                    iconName: "view-list-symbolic"
                    onTriggered: {
                        tabs.selectedTabIndex = 1
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    id: startAction
                    text: i18n.tr('About')
                    iconName: "info"
                    onTriggered: {
                        mainPageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                    }
                }
            ]
        }

    }

    Component.onCompleted: {
        storage.configGet("profile_id", function(profile_id) {
            storage.profileGetById(profile_id, function(data) {
                if (data) {
                    console.log(data.name)
                    root.profile = data
                }
            })
        })
    }

    Flickable {
        id: flickable
        // anchors.fill: parent
        anchors {
            top: homePage.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        // anchors.topMargin: units.gu(2)
        // anchors.bottomMargin: units.gu(2)
        contentHeight: layout.height
        // interactive: contentHeight > height

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right

            ListItem {
                Label {
                    id: profileNameLabel
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("<b>Profile</b>:")
                    fontSize: "small"
                }

                Label {
                    id: statusTitleLabel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: i18n.tr("<b>Status</b>:")
                    fontSize: "small"
                }

                Label {
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                    anchors.left: profileNameLabel.right
                    anchors.leftMargin: units.gu(2)
                    text: Boolean(profile) ? profile.name : ""
                    fontSize: "small"
                }

                Label {
                    id: statusLabel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(1)
                    anchors.left: statusTitleLabel.right
                    anchors.leftMargin: units.gu(2)
                    text: ssClient.running ? i18n.tr("Started") : i18n.tr("Stopped")
                    fontSize: "small"
                }

                Connections {
                    target: ssClient
                    onStartFailed: {
                        notification(i18n.tr("Service Start Failed: ") + message, 5)
                        statusLabel.text = i18n.tr("Start Failed")
                        statusLabel.color = UbuntuColors.red
                        serviceSwitch.checked = false
                        serviceSwitch.enabled = true
                    }
                    onStartSucceed: {
                        notification(i18n.tr("Service Started"), 5)
                        statusLabel.text = i18n.tr("Started")
                        statusLabel.color = UbuntuColors.green
                        serviceSwitch.checked = true
                        serviceSwitch.enabled = true
                    }
                    onStopped: {
                        notification(i18n.tr("Service Stopped"), 5)
                        statusLabel.text = i18n.tr("Stopped")
                        statusLabel.color = statusTitleLabel.color
                        serviceSwitch.checked = false
                        serviceSwitch.enabled = true
                    }
                }

                Switch {
                    id: serviceSwitch
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    onCheckedChanged: {
                        if (!enabled) {
                            return
                        }
                        enabled = false

                        // Start service
                        if (checked) {
                            statusLabel.text = i18n.tr("Starting...")
                            notification(i18n.tr("Service Starting..."))
                            // check if profile is valid
                            if (!profile) {
                                notification(i18n.tr("Please select a profile first!"))
                                statusLabel.text = i18n.tr("Stopped")
                                checked = false
                                enabled = true
                                return
                            }

                            if (validPassword != "") {
                                Tool.password = validPassword
                                runService()
                            } else {
                                var popup = PopupUtils.open(passwordPopup)
                                // input password 
                                popup.accepted.connect(function(password) {
                                    Tool.shadowsocksServer = profile.server
                                    var result = Tool.checkPassword(password)
                                    console.log("password result:", result)
                                    if (result) {
                                        validPassword = password
                                        Tool.password = password
                                        runService()
                                    } else {
                                        notification("Password Error", 5)
                                        validPassword = ""
                                        statusLabel.text = i18n.tr("Stopped")
                                        checked = false
                                        enabled = true
                                    }
                                })

                                // input rejected 
                                popup.rejected.connect(function() {
                                    statusLabel.text = i18n.tr("Stopped")
                                    checked = false
                                    enabled = true
                                })
                            }

                        } else {
                            // Stop service
                            statusLabel.text = i18n.tr("Stopping...")
                            notification(i18n.tr("Service Stopping..."))
                            statusLabel.color = statusTitleLabel.color
                            stopService()
                        }
                    }
                }

            }

            // ListItems.Header {
            //     text: i18n.tr("<b>General Settings</b>")
            // }

            // ListItem {
            //     Label {
            //         anchors.top: parent.top
            //         anchors.topMargin: units.gu(1)
            //         anchors.left: parent.left
            //         anchors.leftMargin: units.gu(2)
            //         text: i18n.tr("Profiles")
            //     }
            //     Label {
            //         anchors.bottom: parent.bottom
            //         anchors.bottomMargin: units.gu(1)
            //         anchors.left: parent.left
            //         anchors.leftMargin: units.gu(2)
            //         text: i18n.tr("Switch to another profile or add new profiles")
            //         fontSize: "small"
            //     }
            //     onClicked: {
            //         Haptics.play()
            //         if (!ssClient.running) {
            //             mainPageStack.push(Qt.resolvedUrl("ProfilesPage.qml"))
            //         } else {
            //             notification(i18n.tr("Can't switch profile when service is running!"))
            //         }
            //     }
            // }

            NetworkTraffic {
                id: networkTraffic
            }

            ListItems.Header {
                text: i18n.tr("<b>Server Settings</b>")
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Profile Name")
                }

                Label {
                    id: profileNameText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(profile) ? profile.name : ""
                }

            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Server")
                }

                Label {
                    id: profileServerText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(profile) ? profile.server : ""
                }
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Remote Port")
                }

                Label {
                    id: profileRemotePortText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(profile) ? profile.remote_port : ""
                }
            }

            // ListItem {
            //     Label {
            //         anchors.left: parent.left
            //         anchors.leftMargin: units.gu(2)
            //         anchors.verticalCenter: parent.verticalCenter;
            //         text: i18n.tr("Local Port")
            //     }

            //     Label {
            //         id: profileLocalPortText
            //         anchors.right: parent.right
            //         anchors.rightMargin: units.gu(2)
            //         anchors.verticalCenter: parent.verticalCenter;
            //         text: Boolean(profile) ? profile.local_port : ""
            //     }
            // }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Password")
                }

                Label {
                    id: profilePasswordText
                    property bool show: false
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: {
                        if (show) {
                            return Boolean(profile) ? profile.password : ""
                        } else {
                            var t = ""
                            if (Boolean(profile)) {
                                var p = profile.password
                                t = p.replace(/./g, "*")
                            }
                            return t
                        }
                    }
                }
                MouseArea {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: profilePasswordText.horizontalCenter
                    width: profilePasswordText.width
                    onClicked: {
                        profilePasswordText.show = !profilePasswordText.show
                    }
                }
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Encrypt Method")
                }

                Label {
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(profile) ? profile.method : ""
                }
            }
        }
    }
}
