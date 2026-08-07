// NotificationService.qml
// Thin adapter around Quickshell.Services.Notifications.NotificationServer.
// Owns the server, holds DND state, and provides a send() proxy for in-process
// sends. Reactivity is driven by reassigning the _notifications / _flags maps.
pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Services.Notifications

Singleton {
  id: root

  readonly property var tracked: _notifications

  property bool dndEnabled: false

  property int revision: 0

  property var _notifications: ({})
  property var _inProcessActions: ({})
  property var _flags: ({})

  NotificationServer {
    id: notificationServer
    keepOnReload: true
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
  }

  onDndEnabledChanged: {
    if (dndEnabled) {
      const next = Object.assign({}, root._flags)
      for (const id in root._notifications) {
        const existing = next[id] || {}
        next[id] = {
          consumed: true,
          suppressed: false,
          arrivedDuringDnd: existing.arrivedDuringDnd === true
        }
      }
      root._flags = next
      root._bumpRevision()
    } else {
      let n = 0
      const cleared = {}
      for (const id in root._flags) {
        if (root._flags[id].suppressed) n++
        cleared[id] = Object.assign({}, root._flags[id], { suppressed: false })
      }
      root._flags = cleared
      root._bumpRevision()
      if (n > 0) {
        send({
          appName: "Quickshell",
          summary: "DND",
          body: n + " notification" + (n === 1 ? " was" : "s were")
                + " suppressed while in DND mode",
          expireTimeout: 6000,
          hints: { transient: true }
        })
      }
    }
  }

  Connections {
    target: notificationServer
    function onNotification(notification) {
      const sid = String(notification.id)
      const next = Object.assign({}, root._notifications)
      next[sid] = notification
      root._notifications = next

      // Keep the notification alive. Without this, the NotificationServer
      // can discard (destroy) the QObject at any time, causing the Repeater
      // delegate to hold a dangling reference.
      notification.tracked = true

      if (root.dndEnabled) {
        const nextFlags = Object.assign({}, root._flags)
        nextFlags[sid] = { consumed: true, suppressed: true, arrivedDuringDnd: true }
        root._flags = nextFlags
      }
      root._bumpRevision()

      notification.closed.connect(function() {
        if (root._notifications[sid] === notification) {
          const n = Object.assign({}, root._notifications)
          delete n[sid]
          root._notifications = n
        }
        if (root._flags[sid]) {
          const f = Object.assign({}, root._flags)
          delete f[sid]
          root._flags = f
        }
        root._bumpRevision()
      })
    }
  }

  function _bumpRevision() { revision = revision + 1 }

  function send(notif) {
    if (!notif) return ""
    const actionIds = (notif.actions || []).map(a => a.id || a.label || "")
    const id = notificationServer.notify(
      notif.appName || "Quickshell",
      notif.replacesId || 0,
      notif.appIcon || "",
      notif.summary || "",
      notif.body || "",
      actionIds,
      notif.hints || {},
      notif.expireTimeout != null ? notif.expireTimeout : -1
    )
    if (notif.actions && notif.actions.length > 0) {
      _inProcessActions = Object.assign({}, _inProcessActions, { [String(id)]: notif.actions })
    }
    root._bumpRevision()
    return String(id)
  }

  function getActions(id) {
    const sid = String(id)
    const rich = _inProcessActions[sid]
    if (rich) return rich
    const n = tracked[sid]
    if (!n || !n.actions) return []
    const replyPlaceholder = (n.hints && n.hints["x-kde-reply-placeholder-text"]) || "Reply…"
    return n.actions.map(a => {
      if (typeof a === "string") {
        return a === "x-kde-reply"
          ? { id: a, label: a, type: "input", placeholder: replyPlaceholder }
          : { id: a, label: a, type: "button" }
      }
      const isReply = a.id === "x-kde-reply" || a.name === "x-kde-reply"
      return {
        id: a.id,
        label: a.text || a.label || a.id,
        type: isReply ? "input" : "button",
        placeholder: isReply ? replyPlaceholder : undefined
      }
    })
  }

  function dismissNotification(id) {
    const n = tracked[String(id)]
    if (n) n.dismiss()
  }

  function clearAll() {
    const ids = Object.keys(tracked)
    for (const id of ids) {
      const n = tracked[id]
      if (n) n.dismiss()
    }
  }

  function setDndEnabled(v) { dndEnabled = !!v }

  function isConsumed(id) {
    const f = root._flags[String(id)]
    return f ? f.consumed === true : false
  }
  function isArrivedDuringDnd(id) {
    const f = root._flags[String(id)]
    return f ? f.arrivedDuringDnd === true : false
  }
}
