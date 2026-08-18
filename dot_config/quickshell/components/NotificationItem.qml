// NotificationItem.qml
// Single notification item used by both the center (row) and the popups.
// compact: false (default) = center row with Dismiss/time/badge.
// compact: true = transient popup with click-to-dismiss and auto-dismiss
// timer for hint: "transient".
import Quickshell
import QtQuick
import ".."
import "../components"
import "../services"
import "../theme"
import "../states"

Rectangle {
  id: root
  property var notification: null
  property bool compact: false

  color: Theme.notificationSurface
  border.width: 1
  border.color: Theme.notificationBorder
  radius: Theme.borderRadius
  implicitHeight: column.implicitHeight + 12
  width: compact ? 360 : (parent ? parent.width : 400)

  Accessible.role: Accessible.ListItem
  Accessible.name: notification ? (notification.summary || "") : ""
  Accessible.focusable: true

  readonly property string mediaSource: {
    if (!notification) return ""
    const img = NotificationState.normalizeImageSource(notification.image || "")
    if (img) return img
    const icon = NotificationState.normalizeImageSource(notification.appIcon || "")
    return icon
  }
  readonly property bool hasMedia: mediaSource.length > 0

  readonly property real textColWidth: width - 56

  Timer {
    running: root.compact && root.notification
      && root.notification.hints && root.notification.hints["transient"]
    interval: NotificationState.popupAutoDismissMs
    repeat: false
    onTriggered: root.dismiss()
  }

  Column {
    id: column
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 8
    spacing: 4

    Row {
      spacing: 8
      width: parent.width

      Image {
        source: root.mediaSource
        visible: root.hasMedia
        width: 32
        height: 32
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
      }

      Column {
        width: root.textColWidth
        spacing: 2

        Text {
          text: notification ? (notification.summary || "Notification") : ""
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
          elide: Text.ElideRight
          width: parent.width
        }

        Text {
          text: notification ? (notification.body || "") : ""
          color: Theme.textMuted
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          wrapMode: Text.Wrap
          maximumLineCount: root.compact ? 2 : 3
          elide: Text.ElideRight
          width: parent.width
          visible: text.length > 0
        }

        Text {
          textFormat: Text.RichText
          text: {
            if (!notification) return ""
            if (root.compact) return ""
            const t = root.formatTime(notification)
            if (notification && NotificationService.isArrivedDuringDnd(notification["id"])) {
              return Theme.iconSpan("&#xf1f6;") + (t ? " " + t : "")
            }
            return t
          }
          color: Theme.textMuted
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize - 1
          width: parent.width
        }
      }
    }

    NotificationActionsBar {
      visible: notification && (notification.actions || []).length > 0
      notification: root.notification
    }

    Row {
      spacing: 8
      width: parent.width

      ActionButton {
        text: "Dismiss"
        textColor: Theme.textMuted
        width: 80
        height: 22
        onClicked: root.dismiss()
      }

      Text {
        text: notification && notification.urgency >= 2 ? "!" : ""
        color: notification && notification.urgency >= 3 ? Theme.batteryLow : Theme.accent
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    visible: root.compact
    onClicked: root.dismiss()
  }

  function formatTime(notif) {
    if (!notif) return ""
    const ts = notif.hints && notif.hints["timestamp"]
    if (ts) {
      const ms = Number(ts)
      if (!isNaN(ms)) {
        const d = new Date(ms)
        const diff = Date.now() - d
        if (diff < 60000) return "just now"
        if (diff < 3600000) return Math.floor(diff / 60000) + "m ago"
        if (diff < 86400000) return Math.floor(diff / 3600000) + "h ago"
        return d.toLocaleDateString(Qt.locale(), "MMM d")
      }
    }
    return ""
  }

  function dismiss() {
    if (notification) NotificationState.dismiss(notification["id"])
  }
}
