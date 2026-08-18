// NotificationState.qml
// Read-only projections + DND/focus state. The service is the source of
// truth; this file exposes a thin, view-friendly API.
pragma Singleton
import Quickshell
import QtQuick
import "../services"
import "../theme"

Singleton {
  property var service: NotificationService

  property bool dndEnabled: service.dndEnabled

  property int popupAutoDismissMs: 6000

  property bool centerVisible: false
  onCenterVisibleChanged: {
    if (!centerVisible) service.markAllSeen()
  }
  property var centerAnchorWindow: null
  property int centerAnchorX: 0
  property int centerAnchorY: 0

  function openCenter(widget) {
    if (centerVisible) {
      centerVisible = false
      return
    }
    // ponytail: pairwise close is fine for 2 popup windows; a third
    // warrants a shared "current popup" discriminator state instead
    ControlCenterState.visible = false
    const win = widget.panelWindow
    const g = widget.mapToGlobal(widget.width, widget.height + Theme.popupGap)
    centerAnchorWindow = win
    centerAnchorX = Math.round(g.x - win.screen.x - centerWidth)
    centerAnchorY = Math.round(g.y - win.screen.y)
    centerVisible = true
  }

  readonly property int centerWidth: 420

  function _allNotifications() {
    const tracked = service.tracked
    const result = []
    for (const id in tracked) {
      const n = tracked[id]
      if (n) result.push(n)
    }
    return result
  }

  // Time-ordered (newest first) — survives restores, unlike id order.
  readonly property var items: _allNotifications().sort((a, b) => service.getTime(b.id) - service.getTime(a.id))

  readonly property int count: items.length

  readonly property var popupItems: {
    void service.revision
    const unconsumed = items.filter(n => !service.isConsumed(n.id))
    // center and popups share the top-right corner — absorb instead of overlap
    if (centerVisible) {
      unconsumed.forEach(n => service.markConsumed(n.id))
      return []
    }
    return unconsumed
  }

  readonly property int popupCount: popupItems.length

  function setDndEnabled(v) { service.setDndEnabled(v) }

  function dismiss(id) { service.dismissNotification(id) }
  function clearAll() { service.clearAll() }

  function normalizeImageSource(value) {
    if (!value || value.length === 0) return ""
    if (value.indexOf("://") !== -1) return value
    if (value.startsWith("/")) return "file://" + value
    return value
  }
}
