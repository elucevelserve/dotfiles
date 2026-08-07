// NotificationBellWidget.qml
// Bar bell widget. Left-click toggles the center; right-click opens a menu.
import QtQuick
import QtQuick.Controls
import ".."
import "../services"
import "../theme"
import "../states"

Item {
  implicitWidth: bellText.implicitWidth
  implicitHeight: bellText.implicitHeight

  Text {
    id: bellText
    color: badgeColor()
    font.family: Theme.fontMainFamily
    font.pixelSize: Theme.fontSize
    textFormat: Text.RichText
    text: {
      const icon = Theme.iconSpan(bellIcon())
      if (NotificationState.dndEnabled) return icon
      return icon + " " + NotificationState.count
    }
  }

  function bellIcon() {
    return NotificationState.dndEnabled ? "&#xf1f6;" : "&#xf0f3;"
  }

  function badgeColor() {
    if (NotificationState.dndEnabled) return Theme.textMuted
    const p = highestPriority()
    if (p >= 3) return Theme.batteryLow
    if (p >= 2) return Theme.accent
    if (NotificationState.count > 0) return Theme.textPrimary
    return Theme.textMuted
  }

  function highestPriority() {
    let max = 0
    for (let i = 0; i < NotificationState.items.length; i++) {
      const n = NotificationState.items[i]
      if ((n.urgency || 0) > max) max = n.urgency
    }
    return max
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.LeftButton) {
        NotificationState.centerVisible = !NotificationState.centerVisible
      } else if (mouse.button === Qt.RightButton) {
        contextMenu.popup()
      }
    }
  }

  Menu {
    id: contextMenu

    MenuItem {
      text: NotificationState.dndEnabled ? "Disable DND" : "Enable DND"
      onTriggered: NotificationState.setDndEnabled(!NotificationState.dndEnabled)
    }
    MenuItem {
      text: "Clear all"
      onTriggered: NotificationState.clearAll()
    }
    MenuItem {
      text: NotificationState.centerVisible ? "Hide center" : "Show center"
      onTriggered: NotificationState.centerVisible = !NotificationState.centerVisible
    }
  }
}
