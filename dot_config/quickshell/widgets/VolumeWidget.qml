// VolumeWidget.qml
import QtQuick
import "../theme"
import "../states"
import "../services"

Item {
  id: root
  required property var panelWindow

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

  implicitWidth: contentRow.implicitWidth
  implicitHeight: contentRow.implicitHeight

  Row {
    id: contentRow
    spacing: 4

    Item {
      implicitWidth: outputText.implicitWidth
      implicitHeight: outputText.implicitHeight

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

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
          if (mouse.button === Qt.LeftButton) {
            ControlCenterState.openAt("volume", root)
            return
          }

          if (mouse.button === Qt.RightButton) {
            VolumeService.toggleSinkMute()
          }
        }

        onWheel: function(wheel) {
          if (!VolumeService.sink || !VolumeService.sink.audio) {
            return
          }

          const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
          if (delta === 0) {
            return
          }

          VolumeService.adjustSinkVolume(delta)
          wheel.accepted = true
        }
      }
    }

    Item {
      implicitWidth: micText.implicitWidth
      implicitHeight: micText.implicitHeight

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

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
          if (mouse.button === Qt.LeftButton) {
            ControlCenterState.openAt("volume", root)
            return
          }

          if (mouse.button === Qt.RightButton) {
            VolumeService.toggleSourceMute()
          }
        }

        onWheel: function(wheel) {
          if (!VolumeService.source || !VolumeService.source.audio) {
            return
          }

          const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.pixelDelta.y
          if (delta === 0) {
            return
          }

          VolumeService.adjustSourceVolume(delta)
          wheel.accepted = true
        }
      }
    }
  }
}