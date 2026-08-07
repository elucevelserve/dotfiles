// Theme.qml
pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: root

  // Qt's Qt.styleHints.colorScheme is unreliable on Niri. Read the portal directly.
  property bool darkMode: false

  Component.onCompleted: detectThemeProcess.running = true

  Process {
    id: detectThemeProcess
    command: [
      "sh",
      "-c",
      "if command -v busctl >/dev/null 2>&1; then " +
        "result=$(busctl --user call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings ReadOne ss 'org.freedesktop.appearance' 'color-scheme' 2>/dev/null || true); " +
        "case \"$result\" in " +
          "*u\\ 1*) echo dark ;; " +
          "*u\\ 2*) echo light ;; " +
          "*) echo light ;; " +
        "esac; " +
      "else " +
        "echo light; " +
      "fi"
    ]

    stdout: StdioCollector {
      id: detectStdout
    }

    onExited: {
      const result = detectStdout.text.trim().toLowerCase()
      root.darkMode = (result === "dark")
    }
  }

  // Note: NOT `readonly` — readonly breaks the binding chain so dependents
  // (e.g., Theme.surface used by the bar) wouldn't re-evaluate when darkMode flips.
  readonly property color textPrimary: darkMode ? "#f3f4f6" : "#111827"
  readonly property color textMuted: darkMode ? "#9ca3af" : "#6b7280"
  readonly property color surface: darkMode ? "#0f172a" : "#f9fafb"
  readonly property color accent: darkMode ? "#60a5fa" : "#2563eb"
  readonly property color micActive: darkMode ? "#22c55e" : "#15803d"
  readonly property color batteryLow: darkMode ? "#f87171" : "#dc2626"
  readonly property color batteryCharging: darkMode ? "#4ade80" : "#16a34a"
  readonly property color notificationSurface: darkMode ? "#111827" : "#ffffff"
  readonly property color notificationBorder: textMuted
  readonly property color taskbarMarker: "#cac0ff"

  readonly property int barHeight: 20
  readonly property int windowMargin: 16
  readonly property int popupTopOffset: 40
  readonly property int popupGap: 6
  readonly property int controlCenterWidth: 320
  readonly property int borderRadius: 3

  readonly property string fontMainFamily: "DejaVu Sans Condensed"
  readonly property string fontIconFamily: "Font Awesome 7 Free Solid"
  readonly property int fontSize: 12

  function iconSpan(codepointEntity, colorCss) {
    const colorStyle = colorCss ? "; color:" + colorCss : ""
    return "<span style=\"font-family:'" + root.fontIconFamily + "'" + colorStyle + "\">" + codepointEntity + "</span>"
  }
}