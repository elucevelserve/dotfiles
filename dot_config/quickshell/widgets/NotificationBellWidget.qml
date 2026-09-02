// NotificationBellWidget.qml
// Bar bell widget. Left-click toggles the center; right click toggles DND.
import QtQuick
import ".."
import "../services"
import "../theme"
import "../states"

BarWidget {
  id: root
  acceptedButtons: Qt.LeftButton | Qt.RightButton

  onClicked: mouse => {
    if (mouse.button === Qt.LeftButton) {
      NotificationState.openCenter(root)
    } else {
      NotificationState.setDndEnabled(!NotificationState.dndEnabled)
    }
  }

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
}