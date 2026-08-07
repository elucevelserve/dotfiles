// NiriState.qml
pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: root

  property int activeWorkspaceId: -1
  property var workspaces: []
  property var allWindows: []

  Process {
    id: stream
    command: ["niri", "msg", "--json", "event-stream"]
    running: true
    stdout: SplitParser {
      onRead: line => {
        try {
          const evt = JSON.parse(line)
          if (evt.WorkspacesChanged) {
            const ws = evt.WorkspacesChanged.workspaces || []
            const active = ws.find(w => w.is_active)
            if (active) root.activeWorkspaceId = active.id
            root.workspaces = ws
          } else if (evt.WorkspaceActivated) {
            const id = evt.WorkspaceActivated.id
            if (id !== undefined && id !== null) root.activeWorkspaceId = id
          } else if (evt.WorkspaceActiveWindowChanged) {
            const wsId = evt.WorkspaceActiveWindowChanged.workspace_id
            const newActive = evt.WorkspaceActiveWindowChanged.active_window_id
            if (wsId !== undefined) {
              root.workspaces = root.workspaces.map(w =>
                w.id === wsId ? Object.assign({}, w, { active_window_id: newActive }) : w
              )
            }
          } else if (evt.WindowsChanged) {
            root.allWindows = evt.WindowsChanged.windows || []
          } else if (evt.WindowOpenedOrChanged) {
            const w = evt.WindowOpenedOrChanged.window
            if (w) {
              const idx = root.allWindows.findIndex(x => x.id === w.id)
              if (idx >= 0) {
                const merged = Object.assign({}, w, { is_focused: root.allWindows[idx].is_focused })
                const arr = root.allWindows.slice()
                arr[idx] = merged
                root.allWindows = arr
              } else {
                const newW = Object.assign({}, w)
                if (newW.is_focused) {
                  const demoted = root.allWindows.map(win =>
                    Object.assign({}, win, { is_focused: false })
                  )
                  demoted.push(newW)
                  root.allWindows = demoted
                } else {
                  root.allWindows = root.allWindows.concat([newW])
                }
              }
            }
          } else if (evt.WindowClosed) {
            root.allWindows = root.allWindows.filter(w => w.id !== evt.WindowClosed.id)
          } else if (evt.WindowFocusChanged) {
            const id = evt.WindowFocusChanged.id
            root.allWindows = root.allWindows.map(w =>
              Object.assign({}, w, { is_focused: id !== null && w.id === id })
            )
          } else if (evt.WindowLayoutsChanged) {
            const changes = evt.WindowLayoutsChanged.changes || []
            const m = new Map()
            for (const c of changes) m.set(c[0], c[1])
            root.allWindows = root.allWindows.map(w => {
              const layout = m.get(w.id)
              return layout ? Object.assign({}, w, { layout: layout }) : w
            })
          }
        } catch (e) {
          console.warn("niri event parse error:", e)
        }
      }
    }
  }
}
