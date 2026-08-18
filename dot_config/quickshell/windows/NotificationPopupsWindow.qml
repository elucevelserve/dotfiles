// NotificationPopupsWindow.qml
// Transient notification popups. Per-screen top-right stack. Auto-dismiss
// for hint: "transient" notifications.
import Quickshell
import QtQuick
import ".."
import "../theme"
import "../states"
import "../components"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      visible: !NotificationState.dndEnabled && NotificationState.popupCount > 0
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      aboveWindows: true
      focusable: false

      implicitWidth: 380
      implicitHeight: Math.max(64, Math.min(360, popupColumn.implicitHeight + 12))

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.popupTopOffset
        right: Theme.windowMargin
      }

      Column {
        id: popupColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 6
        spacing: 6

        Repeater {
          model: NotificationState.popupItems
          delegate: NotificationItem {
            notification: modelData
            compact: true
          }
        }
      }
    }
  }
}
