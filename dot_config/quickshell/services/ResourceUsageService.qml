pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string cpuUsage: "N/A"
  property string memoryUsage: "N/A"
  property string diskUsage: "N/A"
  property string temperature: "N/A"

  function refresh() {
    if (!usageProcess.running) {
      usageProcess.running = true
    }
  }

  Component.onCompleted: refresh()

  Timer {
    interval: 16000
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Process {
    id: usageProcess
    command: [
      "sh",
      "-c",
      "set -e; " +
        "read -r _ u1 n1 s1 i1 w1 irq1 sirq1 st1 _ < /proc/stat; " +
        "sleep 0.2; " +
        "read -r _ u2 n2 s2 i2 w2 irq2 sirq2 st2 _ < /proc/stat; " +
        "idle1=$((i1 + w1)); idle2=$((i2 + w2)); " +
        "non1=$((u1 + n1 + s1 + irq1 + sirq1 + st1)); " +
        "non2=$((u2 + n2 + s2 + irq2 + sirq2 + st2)); " +
        "total1=$((idle1 + non1)); total2=$((idle2 + non2)); " +
        "totald=$((total2 - total1)); idled=$((idle2 - idle1)); " +
        "if [ \"$totald\" -gt 0 ]; then cpu=$(((100 * (totald - idled)) / totald)); else cpu=0; fi; " +
        "mem=$(free | awk '/^Mem:/ { if ($2 > 0) printf \"%d%%\", ($3 * 100 / $2); else printf \"N/A\" }'); " +
        "disk=$(df -h / | awk 'NR==2 {print $5}'); " +
        "temp=\"N/A\"; " +
        "for t in /sys/class/thermal/thermal_zone*/temp; do " +
          "if [ -r \"$t\" ]; then v=$(cat \"$t\"); " +
            "if [ \"$v\" -gt 1000 ] 2>/dev/null; then temp=$((v / 1000)); else temp=$v; fi; " +
            "temp=\"${temp}°C\"; break; fi; " +
        "done; " +
        "printf 'cpu=%s%%;mem=%s;disk=%s;temp=%s' \"$cpu\" \"$mem\" \"$disk\" \"$temp\""
    ]

    stdout: StdioCollector {
      id: usageStdout
    }

    onExited: {
      const raw = usageStdout.text.trim()
      if (!raw) {
        return
      }

      const fields = raw.split(";")
      for (const field of fields) {
        const parts = field.split("=")
        if (parts.length !== 2) {
          continue
        }

        const key = parts[0].trim()
        const value = parts[1].trim()
        if (key === "cpu") {
          root.cpuUsage = value
        } else if (key === "mem") {
          root.memoryUsage = value
        } else if (key === "disk") {
          root.diskUsage = value
        } else if (key === "temp") {
          root.temperature = value
        }
      }
    }
  }
}
