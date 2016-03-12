import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.3 as ListItems

Page {
    id: profilesPage

    property var profileList: []

    title: i18n.tr("Profiles")

    head.actions: [
        Action {
            text: i18n.tr('Add')
            iconName: 'add'
            onTriggered: {
                mainPageStack.push(Qt.resolvedUrl("ProfilePage.qml"))
            }
        }
    ]

    onVisibleChanged: {
        if (visible) {
            updateProfiles()
        }
    }

    Component.onCompleted: {
        updateProfiles()
    }

    function updateProfiles() {
        storage.profileAll(function(data) {
            profileList = data;
        });
    }

    Flickable {

        id: flickable
        anchors.fill: parent
        // anchors.topMargin: units.gu(2)
        // anchors.bottomMargin: units.gu(2)
        contentHeight: layout.height
        // interactive: contentHeight > height

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right

            Repeater {
                model: profileList
                ListItem {
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter;
                        text: profileList[index].name
                    }
                    leadingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "delete"
                                onTriggered: {
                                    console.log("DEL")
                                    storage.profileDel(profileList[index].id)
                                    root.profile = null
                                    updateProfiles()
                                }
                            }
                        ]
                    }

                    trailingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "edit"
                                onTriggered: {
                                    console.log("EDIT")
                                    mainPageStack.push(Qt.resolvedUrl("ProfilePage.qml"), {ssProfile: profileList[index]})
                                }
                            },
                            Action {
                                iconName: "share"
                                onTriggered: {
                                    PopupUtils.open(sharePopup, null, {shareProfile: profileList[index]})
                                }
                            }
                        ]
                    }

                    onClicked: {
                        root.profile = profileList[index]
                        storage.configSet("profile_id", root.profile.id)
                        mainPageStack.pop()
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: profileList.length == 0
        Icon {
            id: iconSettings
            name: "settings"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: units.gu(8)
            width: units.gu(8)
        }
        Label {
            anchors.top: iconSettings.bottom
            anchors.topMargin: units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Please add new profiles")
            fontSize: "large"
            font.bold: true
        }
    }

    Component {
        id: sharePopup
        Dialog {
            id: shareDialog
            property var shareProfile

            Component.onCompleted: {
                var imgData = Tool.ssQRCode(shareProfile.method, shareProfile.password, shareProfile.server, Number(shareProfile.remote_port))
                image.source = "data:image/png;base64," + imgData
            }

            Image {
                id: image
                width: parent.width - units.gu(2)
                height: width
                fillMode: Image.PreserveAspectFit
            }

            Button {
                text: "Close"
                color: UbuntuColors.red
                onClicked: {
                    PopupUtils.close(shareDialog)
                }
            }
        }
    }
}
