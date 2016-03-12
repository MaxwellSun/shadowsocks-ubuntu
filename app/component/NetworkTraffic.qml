import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {

    property int sentTotal: 0
    property int receivedTotal: 0
    property int sentRecord: 0
    property int receivedRecord: 0

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
        }
        if ((num % 1) > 0) {
            num = num.toFixed(2)
        }
        return num + " " + unit
    }

    height: units.gu(10)

    onClicked: {
        Haptics.play()
        ssClient.checkConnectivity()
        checkLabel.text = i18n.tr("Testing...")
    }

    Connections {
        target: ssClient
        onSent: {
            sentTotal += Number(n)
        }
        onReceived: {
            receivedTotal += Number(n)
        }
        onStartSucceed: {
            timer.running = true
        }
        onStopped: {
            timer.running = false
            sentTotal = 0
            receivedTotal = 0
            sentRecord = 0
            receivedRecord = 0
            receivedTraffic.text = formatTraffic(0)
            sentTraffic.text = formatTraffic(0)
        }
        onCheckFinished: {
            switch (result) {
            case "ok":
                checkLabel.text = i18n.tr("Success: ")+message+i18n.tr("ms latency")
                break
            case "err":
                checkLabel.text = i18n.tr("Failed: time out")
                break
            case "errCode":
                checkLabel.text = i18n.tr("Failed: status code error")
                break
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: {
            var sentIncrease = sentTotal - sentRecord
            var receivedIncrease = receivedTotal - receivedRecord
            sentRecord = sentTotal
            receivedRecord = receivedTotal
            sentTraffic.text = formatTraffic(sentTotal)
            receivedTraffic.text = formatTraffic(receivedTotal)
            sentSpeed.text = formatTraffic(sentIncrease) + "/s"
            receivedSpeed.text = formatTraffic(receivedIncrease) + "/s"
        }
    }

    Label {
        id: networkLabel
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        anchors.left: parent.left
        anchors.leftMargin: units.gu(2)
        text: i18n.tr("Network Traffic")
    }
    Label {
        id: checkLabel
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        text: i18n.tr("Check Connectivity")
    }

    Label {
        id: receivedLabel
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            left: parent.left
            leftMargin: units.gu(2)
        }
        text: i18n.tr("Received:")
        fontSize: "small"
    }

    Label {
        id: sentLabel
        anchors {
            bottom: receivedLabel.top
            bottomMargin: units.gu(0.5)
            left: parent.left
            leftMargin: units.gu(2)
        }
        text: i18n.tr("Sent:")
        fontSize: "small"
    }

    Label {
        id: receivedTraffic
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            right: parent.right
            rightMargin: parent.width/2 + units.gu(4)
        }
        text: "0 Bytes"
        fontSize: "small"
    }

    Label {
        id: sentTraffic
        anchors {
            bottom: receivedTraffic.top
            bottomMargin: units.gu(0.5)
            right: parent.right
            rightMargin: parent.width/2 + units.gu(4)
        }
        text: "0 Bytes"
        fontSize: "small"
    }

    Label {
        id: receivedSpeed
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(2)
        }
        text: "0 Bytes/s"
        fontSize: "small"
    }

    Label {
        id: sentSpeed
        anchors {
            bottom: receivedSpeed.top
            bottomMargin: units.gu(0.5)
            right: parent.right
            rightMargin: units.gu(2)
        }
        text: "0 Bytes/s"
        fontSize: "small"
    }

    Label {
        id: receivedFlag
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            left: parent.left
            leftMargin: parent.width/2 + units.gu(4)
        }
        text: "🔽"
        fontSize: "small"
    }

    Label {
        id: sentFlag
        anchors {
            bottom: receivedFlag.top
            bottomMargin: units.gu(0.5)
            left: parent.left
            leftMargin: parent.width/2 + units.gu(4)
        }
        text: "🔼"
        fontSize: "small"
    }
}
