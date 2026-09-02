// VolumeWidget.qml
import QtQuick
import "../theme"
import "../states"
import "../services"

Row {
  id: root
  required property var panelWindow

  height: parent.height
  spacing: 4

  function volumeIcon(percent, muted) {
    if (muted) {
      return Theme.iconSpan("&#xf6a9;")
    }

    if (percent < 34) {
      return Theme.iconSpan("&#xf026;")
    }

    if (percent < 67) {
      return Theme.iconSpan("&#xf027;")
    }

    return Theme.iconSpan("&#xf028;")
  }

  function micIcon(muted) {
    if (muted) {
      return Theme.iconSpan("&#xf131;")
    }

    return Theme.iconSpan("&#xf130;")
  }

  BarWidget {
    panelWindow: root.panelWindow
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        ControlCenterState.openAt("volume", root)
        return
      }

      if (mouse.button === Qt.RightButton) {
        VolumeService.toggleSinkMute()
      }
    }

    onScrolled: delta => {
      if (!VolumeService.sink || !VolumeService.sink.audio) {
        return
      }

      VolumeService.adjustSinkVolume(delta)
    }

    Text {
      id: outputText
      color: (VolumeService.sink && VolumeService.sink.audio && VolumeService.sink.audio.muted)
        ? Theme.textMuted
        : Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: {
        if (!VolumeService.ready || !VolumeService.sink || !VolumeService.sink.audio) {
          return "VOL N/A"
        }

        const percent = Math.round(VolumeService.sink.audio.volume * 100)
        const icon = volumeIcon(percent, VolumeService.sink.audio.muted)
        return percent + "% " + icon
      }
    }
  }

  BarWidget {
    panelWindow: root.panelWindow
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: mouse => {
      if (mouse.button === Qt.LeftButton) {
        ControlCenterState.openAt("volume", root)
        return
      }

      if (mouse.button === Qt.RightButton) {
        VolumeService.toggleSourceMute()
      }
    }

    onScrolled: delta => {
      if (!VolumeService.source || !VolumeService.source.audio) {
        return
      }

      VolumeService.adjustSourceVolume(delta)
    }

    Text {
      id: micText
      color: (VolumeService.source && VolumeService.source.audio && VolumeService.source.audio.muted)
        ? Theme.textMuted
        : (VolumeService.micActive ? Theme.micActive : Theme.textPrimary)
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      textFormat: Text.RichText
      text: {
        if (!VolumeService.ready || !VolumeService.source || !VolumeService.source.audio) {
          return "MIC N/A"
        }

        const percent = Math.round(VolumeService.source.audio.volume * 100)
        const icon = micIcon(VolumeService.source.audio.muted)
        return percent + "% " + icon
      }
    }
  }
}