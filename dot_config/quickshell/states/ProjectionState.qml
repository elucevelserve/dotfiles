pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  readonly property var outputs: ProjectionService.outputs
  readonly property string currentMode: ProjectionService.mode

  function setMode(m) {
    ProjectionService.setMode(m)
  }
}
