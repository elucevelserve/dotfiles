// FocusedWindowState.qml
pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  readonly property string focusedTitle: {
    const w = NiriService.allWindows.find(w => w.is_focused)
    return w ? (w.title || w.app_id || "N/A") : "No focused window"
  }
}
