import QtQuick 2.4
import Shadowsocks 1.0

ShadowsocksClient {
    id: ssClient

    property int sentBytes: 0
    property int receivedBytes: 0

    signal startFailed(string message)
    signal startSucceed()
    signal stopped()
    signal checkFinished(string result, string message)
    signal log(string message)
    signal sent(string n)
    signal received(string n)

    /**
     * go-qml can not emit signal from go side,
     * so use a function to emit signal.
     * go-qml will check the count of parameters,
     * so we can't use arguments here, use a argString instead
     */
    function emitSignal(signalString, argString) {
        var signalFunc
        try {
            signalFunc = eval(signalString)
        } catch (e) {
            console.error("[ERROR]", e)
            return
        }

        if (typeof(signalFunc) !== "function") {
            console.log("[ERROR]", '"'+signalString+'"', "is a", typeof(signalFunc), "not a function or signal")
            return
        }
        var args = argString.split(",")
        try {
            signalFunc.apply(null, args)
        } catch (e) {
            console.error("[ERROR]", e)
        }
    }

    onStartFailed: {
        console.log("[Signal]: onStartedFailed", message)
    }

    onStartSucceed: {
        console.log("[Signal]: onStartSucceed")
    }

    onCheckFinished: {
        console.log("[Signal]: onCheckFinished", message)
    }

    onStopped: {
        console.log("[Signal]: onStopped")
    }

    onLog: {
        console.log("[Signal]: onLog", message)
    }

    onSent: {
        sentBytes += Number(n)
        storage.updateProfileSent(root.profile.id, Number(n))
    }

    onReceived: {
        receivedBytes += Number(n)
        storage.updateProfileReceived(root.profile.id, Number(n))
    }
}
