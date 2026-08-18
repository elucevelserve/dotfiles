// NotificationItem.qml
// Single notification item used by both the center (row) and the popups.
// popup: true = transient popup (expire timer, hover-pause, 2-line body);
// popup: false = center row (time row shown). Click behavior is shared:
// left = default/sole action else dismiss, middle = dismiss.
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
  property bool popup: false

  color: Theme.notificationSurface
  border.width: notification && notification.urgency >= 2 ? 2 : 1
  border.color: {
    if (notification && NotificationService.isUnseen(notification.id)) return Theme.textPrimary
    if (notification && notification.urgency >= 2) return Theme.batteryLow
    return Theme.notificationBorder
  }
  radius: Theme.borderRadius
  implicitHeight: column.implicitHeight + 16
  width: popup ? 360 : (parent ? parent.width : 400)

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
    id: expireTimer
    running: root.popup && root.notification && expireMs > 0
    interval: expireMs
    repeat: false
    onTriggered: NotificationService.markConsumed(root.notification.id)
  }

  // expireTimeout: -1 = server default, 0 = never, critical forced to never
  readonly property real expireMs: {
    if (!notification) return 0
    if (notification.urgency >= 2) return 0
    const t = notification.expireTimeout
    if (t === 0) return 0
    if (t > 0) return t
    return NotificationState.popupAutoDismissMs
  }

  MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    // ponytail: QML Timer has no pause; restarts the full interval on
    // unhover — remaining-time tracking not worth the code
    onContainsMouseChanged: {
      if (!root.popup) return
      if (containsMouse) expireTimer.stop()
      else if (expireMs > 0) expireTimer.restart()
    }
    onClicked: function(mouse) {
      if (mouse.button === Qt.MiddleButton) {
        root.dismiss()
        return
      }
      const actions = (notification && notification.actions) || []
      const def = actions.find(a => a.identifier === "default")
      if (def) def.invoke()
      else if (actions.length === 1) actions[0].invoke()
      else root.dismiss()
    }
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
          id: bodyText
          // StyledText: renders inline markup without a QTextDocument —
          // maximumLineCount/elide work (RichText ignores both)
          textFormat: Text.StyledText
          linkColor: Theme.accent
          text: notification ? NotificationService.formatBody(notification.body) : ""
          color: Theme.textMuted
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          wrapMode: Text.Wrap
          maximumLineCount: root.popup ? 2 : 15
          elide: Text.ElideRight
          width: parent.width
          visible: text.length > 0
          onLinkActivated: function(link) {
            Qt.openUrlExternally(link)
            if (root.popup) root.dismiss()
          }
          // links in Text get no cursor feedback by default
          HoverHandler {
            cursorShape: bodyText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
          }
        }

        Text {
          textFormat: Text.RichText
          text: {
            if (!notification) return ""
            if (root.popup) return ""
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
          visible: text.length > 0
        }
      }
    }

    NotificationActionsBar {
      visible: notification && (notification.actions || []).length > 0
      notification: root.notification
    }
  }

  function formatTime(notif) {
    if (!notif) return ""
    const ms = NotificationService.getTime(notif["id"])
    if (!ms) return ""
    const d = new Date(ms)
    const diff = Date.now() - d
    if (diff < 60000) return "just now"
    if (diff < 3600000) return Math.floor(diff / 60000) + "m ago"
    if (diff < 86400000) return Math.floor(diff / 3600000) + "h ago"
    return d.toLocaleDateString(Qt.locale(), "MMM d")
  }

  function dismiss() {
    if (notification) NotificationState.dismiss(notification["id"])
  }
}
