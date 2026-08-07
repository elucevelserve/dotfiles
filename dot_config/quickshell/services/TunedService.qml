pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: root

  property string currentProfile: ""
  property var availableProfiles: []

  function refresh() {
    if (readProc.running) {
      return
    }
    readProc.running = true
  }

  function setProfile(name) {
    if (!name) {
      return
    }
    setProc.command = ["tuned-adm", "profile", name]
    setProc.running = true
    currentProfile = name
  }

  Component.onCompleted: refresh()

  Timer {
    interval: 8000
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Process {
    id: readProc
    command: ["sh", "-c", "tuned-adm active; tuned-adm list"]

    stdout: StdioCollector {
      id: readStdout
    }

    onExited: {
      const raw = readStdout.text
      const m = raw.match(/Current active profile:\s*(.+)/)
      if (m) {
        currentProfile = m[1].trim()
      }
      const lm = raw.match(/Available profiles:\s*\n([\s\S]*?)(?:\n\n|$)/)
      if (lm) {
        const arr = []
        const lines = lm[1].split("\n")
        for (const line of lines) {
          const m = line.match(/^\s*-\s*(\S+)\s+-\s+(.+)$/)
          if (m) {
            arr.push({ name: m[1], description: m[2].trim() })
          }
        }
        availableProfiles = arr
      }
    }
  }

  Process {
    id: setProc
  }
}
