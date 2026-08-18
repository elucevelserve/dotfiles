// BatteryWidget.qml
import QtQuick
import Quickshell.Services.UPower
import "../theme"
import "../states"

Text {
  id: root

  // Hide on machines without a real laptop battery (VM/desktop): displayDevice
  // is never null but may not be initialized yet, so check ready, then use
  // isLaptopBattery to exclude peripheral/AC devices.
  readonly property bool hasBattery:
    UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery

  visible: hasBattery

  readonly property int percent: {
    const rawPercent = UPower.displayDevice.percentage
    if (rawPercent === undefined || rawPercent === null) {
      return -1
    }

    return rawPercent <= 1 ? Math.round(rawPercent * 100) : Math.round(rawPercent)
  }

  readonly property bool charging: {
    const state = UPower.displayDevice.state
    if (state === undefined || state === null) {
      return false
    }

    if (typeof state === "number") {
      // UPower: 1 = charging, 5 = pending charge
      return state === 1 || state === 5
    }

    const normalized = String(state).toLowerCase()
    return normalized.indexOf("charging") !== -1
  }

  color: {
    if (root.charging) {
      return Theme.batteryCharging
    }

    if (root.percent >= 0 && root.percent < 20) {
      return Theme.batteryLow
    }

    return Theme.textPrimary
  }
  font.family: Theme.fontMainFamily
  font.pixelSize: Theme.fontSize
  textFormat: Text.RichText

  function batteryIcon(percent) {
    if (percent < 20) {
      return Theme.iconSpan("&#xf244;")
    }

    if (percent < 40) {
      return Theme.iconSpan("&#xf243;")
    }

    if (percent < 60) {
      return Theme.iconSpan("&#xf242;")
    }

    if (percent < 80) {
      return Theme.iconSpan("&#xf241;")
    }

    return Theme.iconSpan("&#xf240;")
  }

  function chargingIcon() {
    return Theme.iconSpan("&#xf0e7;")
  }

  text: {
    if (root.percent < 0) {
      return "BAT N/A"
    }

    const chargingSuffix = root.charging ? " " + root.chargingIcon() : ""
    return root.percent + "% " + root.batteryIcon(root.percent) + chargingSuffix
  }
}