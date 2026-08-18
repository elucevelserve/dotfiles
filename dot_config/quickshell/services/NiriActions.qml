pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
  Process {
    id: focusProc
    running: false
    command: []
  }

  function focusWindow(id) {
    focusProc.command = ["niri", "msg", "action", "focus-window", "--id", String(id)]
    focusProc.running = true
  }

  function focusWorkspace(idx) {
    focusProc.command = ["niri", "msg", "action", "focus-workspace", String(idx)]
    focusProc.running = true
  }
}
