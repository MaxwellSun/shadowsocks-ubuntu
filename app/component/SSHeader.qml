import QtQuick 2.4
import Ubuntu.Components 1.3

PageHeader {
    StyleHints {
        foregroundColor: "white"
        backgroundColor: "#4caf50"
        dividerColor: "white"
    }

    // NOTE: From OTA 13 Header Button will not transparent
    //       by setting opacity here
    // opacity: 0.9

    leadingActionBar.delegate: SSHeaderButton {}
    trailingActionBar.delegate: SSHeaderButton {}
}
