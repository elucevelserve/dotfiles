// BlueLightService.qml
pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property int modeOff: 0
  readonly property int modeLow: 1
  readonly property int modeAuto: 2

  property int mode: modeOff
  property int activeTemperature: 3800
  property int autoStartHour: 20
  property int autoStartMinute: 0
  property int autoEndHour: 7
  property int autoEndMinute: 0

  Settings {
    category: "quickshell.bluelight"
    property alias mode: root.mode
    property alias activeTemperature: root.activeTemperature
    property alias autoStartHour: root.autoStartHour
    property alias autoStartMinute: root.autoStartMinute
    property alias autoEndHour: root.autoEndHour
    property alias autoEndMinute: root.autoEndMinute
  }

  function inWarmPeriod() {
    const now = new Date()
    const currentMinutes = now.getHours() * 60 + now.getMinutes()
    const startMinutes = autoStartHour * 60 + autoStartMinute
    const endMinutes = autoEndHour * 60 + autoEndMinute
    if (startMinutes === endMinutes) return false
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes
    }
    return currentMinutes >= startMinutes && currentMinutes < endMinutes
  }

  function apply() {
    const warm = mode === modeLow || (mode === modeAuto && inWarmPeriod())
    const temp = warm ? activeTemperature : 6500
    cmd.exec(["busctl", "--user", "set-property", "rs.wl-gammarelay",
      "/", "rs.wl.gammarelay", "Temperature", "q", String(temp)])
  }

  function setMode(targetMode) {
    mode = targetMode
    apply()
  }

  function setActiveTemperature(temp) {
    activeTemperature = temp
    apply()
  }

  Component.onCompleted: setMode(mode)

  Connections {
    target: TimeService
    function onTickMinutes() {
      if (root.mode === root.modeAuto) {
        root.apply()
      }
    }
  }

  Process { id: cmd }
}
