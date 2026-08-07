pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property int brightnessPercent: -1

  function refreshBrightness() {
    if (!readProcess.running) {
      readProcess.running = true
    }
  }

  function adjustBrightness(delta) {
    if (adjustProcess.running) {
      return
    }

    adjustProcess.command = ["brightnessctl", "set", delta > 0 ? "+1%" : "1%-"]
    adjustProcess.running = true
  }

  function setBrightness(percent) {
    if (setProcess.running) {
      return
    }

    setProcess.command = ["brightnessctl", "set", Math.round(percent) + "%"]
    setProcess.running = true
  }

  Component.onCompleted: refreshBrightness()

  Process {
    running: true
    command: [
      "sh",
      "-c",
      "inotifywait -m -e modify /sys/class/backlight/*/brightness"
    ]
    onExited: running = true

    stdout: SplitParser {
      onRead: root.refreshBrightness()
    }
  }

  Process {
    id: readProcess
    command: ["brightnessctl", "-m"]

    onExited: {
      const match = readStdout.text.match(/,(\d+)%/)
      root.brightnessPercent = match ? parseInt(match[1]) : -1
    }

    stdout: StdioCollector {
      id: readStdout
    }
  }

  Process {
    id: adjustProcess
    onExited: root.refreshBrightness()
  }

  Process {
    id: setProcess
    onExited: root.refreshBrightness()
  }
}
