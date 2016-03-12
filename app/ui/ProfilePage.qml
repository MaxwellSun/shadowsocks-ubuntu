import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

Page {
    id: profilePage

    property var ssProfile

    title: i18n.tr("Profile")

    head.actions: [
        Action {
            id: actionOk
            text: i18n.tr('OK')
            iconName: 'ok'
            enabled: false
            onTriggered: {
                console.log("Save profile")
                saveProfile()
                mainPageStack.pop()
            }
        },
        Action {
            id: actionClose
            text: i18n.tr("Close")
            iconName: 'close'
            onTriggered: {
                mainPageStack.pop()
            }
        }
    ]

    function saveProfile() {
        var profileName = profileNameText.text
        var server = serverText.text
        var remotePort = remotePortText.text
        var localPort = localPortText.text
        var password = passwordText.text
        var method = methodSelector.model[methodSelector.selectedIndex]
        console.log("---------------")
        console.log("profileName", profileName)
        console.log("server", server)
        console.log("remotePort", remotePort)
        console.log("localPort", localPort)
        console.log("password", password)
        console.log("method", method)
        if (server && remotePort && localPort) {
            ssProfile = {
                id: Boolean(ssProfile) ? ssProfile.id : undefined,
                name: profileName,
                server: server,
                remote_port: remotePort,
                local_port: localPort,
                password: password,
                method: method
            }
            storage.profileSave(ssProfile)
            if (Boolean(root.profile) && root.profile.id == ssProfile.id) {
                root.profile = ssProfile
            }
        } else {
            console.log("error")
        }
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

            ListItems.Header {
                text: i18n.tr("General Settings")
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Profile Name")
                }
                TextField {
                    id: profileNameText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(ssProfile) ? ssProfile.name : ""
                    onTextChanged: {
                        actionOk.enabled = true
                    }
                }
            }

            ListItems.Header {
                text: i18n.tr("Server Settings")
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Server")
                }
                TextField {
                    id: serverText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: Boolean(ssProfile) ? ssProfile.server : ""
                    onTextChanged: {
                        actionOk.enabled = true
                    }
                }
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Remote Port")
                }
                TextField {
                    id: remotePortText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    validator: IntValidator {}
                    inputMethodHints: Qt.ImhDialableCharactersOnly
                    text: Boolean(ssProfile) ? ssProfile.remote_port : ""
                    onTextChanged: {
                        actionOk.enabled = true
                    }
                }
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Local Port")
                }
                TextField {
                    id: localPortText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    validator: IntValidator {}
                    inputMethodHints: Qt.ImhDialableCharactersOnly
                    readOnly: true
                    // text: Boolean(ssProfile) ? ssProfile.local_port : ""
                    text: "1080"
                    // onTextChanged: {
                    //     actionOk.enabled = true
                    // }
                }
            }

            ListItem {
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    text: i18n.tr("Password")
                }
                TextField {
                    id: passwordText
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.verticalCenter: parent.verticalCenter;
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhHiddenText 
                    text: Boolean(ssProfile) ? ssProfile.password : ""
                    onTextChanged: {
                        actionOk.enabled = true
                    }
                }
            }

            ListItems.ItemSelector {
                id: methodSelector
                text: i18n.tr("Encrypt Method")
                model: ["rc4",
                        "table",
                        "aes-128-cfb",
                        "aes-192-cfb",
                        "aes-256-cfb",
                        "des-cfb",
                        "bf-cfb",
                        "cast5-cfb",
                        "rc4-md5",
                        "chacha20",
                        "salsa20"]
                containerHeight: itemHeight * 4
                selectedIndex: Boolean(ssProfile) ? model.indexOf(ssProfile.method) : 0
                onSelectedIndexChanged: {
                    actionOk.enabled = true
                }
            }
        }
    }
}
