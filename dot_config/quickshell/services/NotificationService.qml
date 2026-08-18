// NotificationService.qml
// Thin adapter around Quickshell.Services.Notifications.NotificationServer.
// Owns the server, holds DND state, and provides a send() proxy for in-process
// sends. Reactivity is driven by reassigning the _notifications / _flags maps.
// History persists to disk: the file is the source of truth across reloads
// and restarts, so keepOnReload is off.
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Notifications

Singleton {
  id: root

  readonly property var tracked: _notifications

  property bool dndEnabled: false

  property int revision: 0

  property var _notifications: ({})
  property var _flags: ({})

  property string _storePath: {
    const base = Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    return base + "/quickshell/notifications.json"
  }

  NotificationServer {
    id: notificationServer
    keepOnReload: false
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
  }

  // Debounced save on every state change.
  Timer {
    interval: 1000
    running: _saveDirty && _loaded
    onTriggered: {
      _saveDirty = false
      storeView.setText(JSON.stringify(_snapshot()))
    }
  }
  property bool _saveDirty: false
  property bool _loaded: false

  FileView {
    id: storeView
    path: root._storePath
    printErrors: false
    onLoaded: {
      try { _restore(JSON.parse(text())) } catch (e) { console.warn("notifications.json unreadable:", e) }
      _loaded = true
      _bumpRevision()
    }
    onLoadFailed: err => {
      _loaded = true
      if (err === FileViewError.FileNotFound) setText("[]")
    }
  }

  function _snapshot() {
    const saved = []
    const ids = Object.keys(_flags).sort((a, b) => getTime(b) - getTime(a))
    for (const sid of ids.slice(0, 20)) {
      const n = _notifications[sid]
      if (!n) continue
      const f = _flags[sid]
      if (n.hints && n.hints["transient"] === true) continue
      // image:// URLs die with the process — only file paths are restorable
      const image = (n.image && n.image.indexOf("image://") !== 0) ? n.image : ""
      saved.push({
        appName: n.appName || "",
        appIcon: n.appIcon || "",
        summary: n.summary || "",
        body: n.body || "",
        image: image,
        urgency: n.urgency || 1,
        dnd: f.arrivedDuringDnd === true,
        time: f.time || 0
      })
    }
    saved.push({ dnd: dndEnabled })
    return saved
  }

  // In-process notify() doesn't exist on the QML server type, so restores
  // re-enter via our own D-Bus interface using notify-send. execDetached
  // takes an argv list — strings must NOT be shell-quoted.
  function _restore(list) {
    if (!Array.isArray(list)) return
    for (const item of list) {
      if (item && item.dnd === true && !item.summary) {
        dndEnabled = true
        continue
      }
      if (!item || !item.summary) continue
      const args = ["notify-send", "-t", "0", "-u",
        item.urgency >= 2 ? "critical" : (item.urgency === 0 ? "low" : "normal")]
      if (item.appName) args.push("-a", item.appName)
      if (item.appIcon) args.push("-n", item.appIcon)
      if (item.image) args.push("-h", "string:image-path:" + item.image)
      if (item.dnd) args.push("-h", "boolean:x-restore-dnd:true")
      if (item.time) args.push("-h", "string:x-restore-time:" + item.time)
      args.push(item.summary, item.body || "")
      Quickshell.execDetached(args)
    }
  }

  onDndEnabledChanged: {
    _saveDirty = true
    if (dndEnabled) {
      const next = Object.assign({}, root._flags)
      for (const id in root._notifications) {
        const existing = next[id] || {}
        next[id] = {
          consumed: true,
          suppressed: false,
          arrivedDuringDnd: existing.arrivedDuringDnd === true,
          time: existing.time
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

      const nextFlags = Object.assign({}, root._flags)
      const existing = nextFlags[sid] || {}
      const hints = notification.hints || {}
      const isRestore = hints["x-restore-time"] !== undefined
      nextFlags[sid] = root.dndEnabled && !isRestore
        ? { consumed: true, suppressed: true, arrivedDuringDnd: true, time: Date.now(), unseen: true }
        : isRestore
          ? {
            consumed: true,
            suppressed: false,
            arrivedDuringDnd: hints["x-restore-dnd"] === true,
            time: Number(hints["x-restore-time"]) || Date.now()
          }
          : Object.assign({}, existing, { time: Date.now(), unseen: true })
      root._flags = nextFlags
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

  function _bumpRevision() {
    revision = revision + 1
    if (_loaded) _saveDirty = true
  }

  // Re-enters via our own D-Bus interface (the QML server type has no
  // in-process notify()). execDetached takes an argv list — no shell quoting.
  function send(notif) {
    if (!notif) return
    const args = ["notify-send"]
    const t = notif.expireTimeout != null ? notif.expireTimeout : -1
    args.push("-t", String(t === -1 ? 6000 : t))
    if (notif.appName) args.push("-a", notif.appName)
    for (const key in (notif.hints || {})) {
      const v = notif.hints[key]
      if (typeof v === "boolean") args.push("-h", "boolean:" + key + ":" + v)
      else args.push("-h", "string:" + key + ":" + String(v))
    }
    args.push(notif.summary || "", notif.body || "")
    Quickshell.execDetached(args)
  }

  function getActions(id) {
    const n = tracked[String(id)]
    if (!n) return []
    // Quickshell NotificationAction: identifier + text.
    return (n.actions || []).map(a => {
      if (typeof a === "string") return { id: a, label: a, type: "button" }
      const aid = a.identifier || a.id
      return { id: aid, label: a.text || a.label || aid, type: "button" }
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

  function markConsumed(id) {
    const f = root._flags[String(id)]
    if (!f || f.consumed) return
    root._flags = Object.assign({}, root._flags, { [String(id)]: Object.assign({}, f, { consumed: true }) })
    root._bumpRevision()
  }

  // Clear the unseen marker on all rows — called when the center closes.
  function markAllSeen() {
    let changed = false
    const next = Object.assign({}, root._flags)
    for (const id in next) {
      if (next[id].unseen) {
        next[id] = Object.assign({}, next[id], { unseen: false })
        changed = true
      }
    }
    if (changed) {
      root._flags = next
      root._bumpRevision()
    }
  }

  function isUnseen(id) {
    const f = root._flags[String(id)]
    return f ? f.unseen === true : false
  }

  function getTime(id) {
    const f = root._flags[String(id)]
    return f ? f.time || 0 : 0
  }

  // Spec markup only: escape everything, re-enable <b> <i> <u> <a href>;
  // newlines become <br/> (markup renderers collapse bare \n).
  function formatBody(body) {
    if (!body) return ""
    let s = body.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    s = s.replace(/&lt;(\/?)(b|i|u)&gt;/g, "<$1$2>")
    s = s.replace(/&lt;a\s+href="(https?:[^"]*)"\s*&gt;/g, '<a href="$1">')
    s = s.replace(/&lt;\/a&gt;/g, "</a>")
    s = s.replace(/\n/g, "<br/>")
    return s
  }

  function isConsumed(id) {
    const f = root._flags[String(id)]
    return f ? f.consumed === true : false
  }
  function isArrivedDuringDnd(id) {
    const f = root._flags[String(id)]
    return f ? f.arrivedDuringDnd === true : false
  }
}
