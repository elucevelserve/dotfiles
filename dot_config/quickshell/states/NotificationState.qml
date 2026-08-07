// NotificationState.qml
// Read-only projections + DND/focus state. The service is the source of
// truth; this file exposes a thin, view-friendly API.
pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  property var service: NotificationService

  property bool dndEnabled: service.dndEnabled

  property int popupMaxActive: 3
  property int popupAutoDismissMs: 6000

  property bool centerVisible: false

  function _allNotifications() {
    const tracked = service.tracked
    const result = []
    for (const id in tracked) {
      const n = tracked[id]
      if (n) result.push(n)
    }
    return result
  }

  readonly property var items: _allNotifications().sort((a, b) => (b.id || 0) - (a.id || 0))

  readonly property int count: items.length

  readonly property var popupItems: {
    void service.revision
    return items
      .filter(n => !service.isConsumed(n.id))
      .slice(0, popupMaxActive)
  }

  readonly property int popupCount: popupItems.length

  readonly property var lanes: {
    const arr = items
    const map = {}
    const order = []
    for (let i = 0; i < arr.length; i++) {
      const n = arr[i]
      const key = n.appName || "_other"
      const label = n.appName || "Other"
      if (!map[key]) {
        map[key] = { key: key, label: label, items: [] }
        order.push(map[key])
      }
      map[key].items.push(n)
    }
    return order
  }

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
