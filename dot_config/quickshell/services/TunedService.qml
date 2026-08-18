pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

// Reads and sets power profiles via the net.hadess.PowerProfiles D-Bus interface
// (provided by tuned-ppd, which KDE's powerdevil also uses).
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
    setProc.command = ["busctl", "--system", "set-property",
      "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles",
      "net.hadess.PowerProfiles", "ActiveProfile", "s", name]
    setProc.running = true
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
    command: ["sh", "-c",
      "gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Get net.hadess.PowerProfiles ActiveProfile; gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Get net.hadess.PowerProfiles Profiles"]

    stdout: StdioCollector {
      id: readStdout
    }

    onExited: {
      const raw = readStdout.text
      const active = raw.match(/<'(.*?)'>/)
      if (active) {
        currentProfile = active[1]
      }
      const arr = []
      const re = /Profile': <'(.+?)'>/g
      let m
      while ((m = re.exec(raw)) !== null) {
        if (!arr.includes(m[1])) {
          arr.push(m[1])
        }
      }
      availableProfiles = arr.map(n => ({ name: n, description: "" }))
    }
  }

  Process {
    id: setProc
  }
}
