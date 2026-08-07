import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../theme"
import "../states"
import "../services"
import "../components"

Window {
  visible: ControlCenterState.visible
  width: Theme.controlCenterWidth
  height: 320
  x: ControlCenterState.x
  y: ControlCenterState.y
  
  
  color: "transparent"
  flags: Qt.Popup | Qt.FramelessWindowHint

  onVisibleChanged: {
    if (ControlCenterState.visible !== visible) {
      ControlCenterState.visible = visible
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.surface
    border.width: 1
    border.color: Theme.notificationBorder

    Column {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 12

      RowLayout {
        width: parent.width
        spacing: 4

        TabButton {
          text: "Volume"
          active: ControlCenterState.activeTab === "volume"
          onTriggered: ControlCenterState.activeTab = "volume"
          Layout.fillWidth: true
        }
        TabButton {
          text: "Display"
          active: ControlCenterState.activeTab === "display"
          onTriggered: ControlCenterState.activeTab = "display"
          Layout.fillWidth: true
        }
        TabButton {
          text: "Energy"
          active: ControlCenterState.activeTab === "energy"
          onTriggered: ControlCenterState.activeTab = "energy"
          Layout.fillWidth: true
        }
        TabButton {
          text: "Project"
          active: ControlCenterState.activeTab === "projection"
          onTriggered: ControlCenterState.activeTab = "projection"
          Layout.fillWidth: true
        }
      }

      Column {
        visible: ControlCenterState.activeTab === "display"
        spacing: 14
        width: parent.width

        Column {
          spacing: 6
          width: parent.width

          Text {
            text: "Brightness"
            color: Theme.textPrimary
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
          }

          Text {
            text: BrightnessService.brightnessPercent >= 0 ? BrightnessService.brightnessPercent + "%" : "N/A"
            color: Theme.textPrimary
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }

          Slider {
            width: parent.width
            from: 1
            to: 100
            stepSize: 0
            value: BrightnessService.brightnessPercent >= 0 ? BrightnessService.brightnessPercent : 0
            onMoved: BrightnessService.setBrightness(value)
          }
        }

        Column {
          spacing: 8
          width: parent.width

          Text {
            text: "Blue light filter"
            color: Theme.textPrimary
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
          }

          Row {
            spacing: 4
            TabButton {
              text: "Off"
              active: BlueLightService.mode === BlueLightService.modeOff
              onTriggered: BlueLightService.setMode(BlueLightService.modeOff)
            }
            TabButton {
              text: "Low"
              active: BlueLightService.mode === BlueLightService.modeLow
              onTriggered: BlueLightService.setMode(BlueLightService.modeLow)
            }
            TabButton {
              text: "Auto"
              active: BlueLightService.mode === BlueLightService.modeAuto
              onTriggered: BlueLightService.setMode(BlueLightService.modeAuto)
            }
          }

          Column {
            spacing: 4
            width: parent.width

            Text {
              text: "Temperature  " + BlueLightService.activeTemperature + "K"
              color: Theme.textPrimary
              font.family: Theme.fontMainFamily
              font.pixelSize: Theme.fontSize
            }

            Slider {
              width: parent.width
              from: 2000
              to: 6500
              stepSize: 100
              value: BlueLightService.activeTemperature
              onMoved: BlueLightService.setActiveTemperature(value)
            }
          }

          Row {
            spacing: 8

            Text {
              text: "Start"
              width: 40
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.textMuted
              font.family: Theme.fontMainFamily
              font.pixelSize: Theme.fontSize
            }

            Stepper {
              value: BlueLightService.autoStartHour
              onDecrement: {
                BlueLightService.autoStartHour = (BlueLightService.autoStartHour + 23) % 24
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
              onIncrement: {
                BlueLightService.autoStartHour = (BlueLightService.autoStartHour + 1) % 24
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
            }

            Text {
              text: ":"
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.textMuted
              font.family: Theme.fontMainFamily
              font.pixelSize: Theme.fontSize
            }

            Stepper {
              value: BlueLightService.autoStartMinute
              onDecrement: {
                BlueLightService.autoStartMinute = (BlueLightService.autoStartMinute + 59) % 60
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
              onIncrement: {
                BlueLightService.autoStartMinute = (BlueLightService.autoStartMinute + 1) % 60
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
            }
          }

          Row {
            spacing: 8

            Text {
              text: "End"
              width: 40
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.textMuted
              font.family: Theme.fontMainFamily
              font.pixelSize: Theme.fontSize
            }

            Stepper {
              value: BlueLightService.autoEndHour
              onDecrement: {
                BlueLightService.autoEndHour = (BlueLightService.autoEndHour + 23) % 24
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
              onIncrement: {
                BlueLightService.autoEndHour = (BlueLightService.autoEndHour + 1) % 24
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
            }

            Text {
              text: ":"
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.textMuted
              font.family: Theme.fontMainFamily
              font.pixelSize: Theme.fontSize
            }

            Stepper {
              value: BlueLightService.autoEndMinute
              onDecrement: {
                BlueLightService.autoEndMinute = (BlueLightService.autoEndMinute + 59) % 60
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
              onIncrement: {
                BlueLightService.autoEndMinute = (BlueLightService.autoEndMinute + 1) % 60
                if (BlueLightService.mode === BlueLightService.modeAuto) {
                  BlueLightService.setMode(BlueLightService.modeAuto)
                }
              }
            }
          }
        }
      }

      Column {

        visible: ControlCenterState.activeTab === "volume"
        spacing: 6
        width: parent.width

        Text {
          text: "Volume"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        Row {
          spacing: 8
          width: parent.width

          Text {
            text: "Out"
            width: 30
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textMuted
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }

          Slider {
            width: parent.width - 110
            from: 0
            to: 150
            value: (VolumeService.sink && VolumeService.sink.audio) ? Math.round(VolumeService.sink.audio.volume * 100) : 0
            onMoved: VolumeService.setSinkVolume(value / 100)
          }

          Text {
            text: VolumeService.sink && VolumeService.sink.audio ? (VolumeService.sink.audio.muted ? "Muted" : Math.round(VolumeService.sink.audio.volume * 100) + "%") : "N/A"
            color: Theme.textPrimary
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }
        }

        Row {
          spacing: 8
          width: parent.width

          Text {
            text: "Mic"
            width: 30
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textMuted
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }

          Slider {
            width: parent.width - 110
            from: 0
            to: 150
            value: (VolumeService.source && VolumeService.source.audio) ? Math.round(VolumeService.source.audio.volume * 100) : 0
            onMoved: VolumeService.setSourceVolume(value / 100)
          }

          Text {
            text: VolumeService.source && VolumeService.source.audio ? (VolumeService.source.audio.muted ? "Muted" : Math.round(VolumeService.source.audio.volume * 100) + "%") : "N/A"
            color: Theme.textPrimary
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }
        }

        Row {
          spacing: 8

          ActionButton {
              text: "Mute mic"
              onClicked: VolumeService.toggleSourceMute()
          }

          ActionButton {
            text: "Mute out"
            onClicked: VolumeService.toggleSinkMute()
          }

          ActionButton {
            text: "Open mixer"
            onClicked: VolumeService.openMixer()
          }
        }
      }

      Column {

        visible: ControlCenterState.activeTab === "energy"
        spacing: 6
        width: parent.width

        Text {
          text: "Energy Mode"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        Row {
          spacing: 2

          TabButton {
            text: "Power Saver"
            implicitWidth: 96
            implicitHeight: 36
            active: TunedState.currentProfile === "power-saver"
            onTriggered: TunedState.setProfile("power-saver")
          }

          TabButton {
            text: "Balanced"
            implicitWidth: 96
            implicitHeight: 36
            active: TunedState.currentProfile === "balanced"
            onTriggered: TunedState.setProfile("balanced")
          }

          TabButton {
            text: "Performance"
            implicitWidth: 96
            implicitHeight: 36
            active: TunedState.currentProfile === "performance"
            onTriggered: TunedState.setProfile("performance")
          }
        }

        Row {
          spacing: 6
          width: parent.width

          Text {
            text: "All:"
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textMuted
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }

          ComboBox {
            id: profileCombo
            width: parent.width - 32
            model: TunedState.availableProfiles
            textRole: "name"

            currentIndex: {
              const arr = TunedState.availableProfiles
              for (let i = 0; i < arr.length; i++) {
                if (arr[i].name === TunedState.currentProfile) return i
              }
              return -1
            }

            popup.contentItem: ListView {
              clip: true
              implicitHeight: Math.min(contentHeight, 200)
              model: profileCombo.model
              currentIndex: profileCombo.highlightedIndex

              delegate: ItemDelegate {
                width: ListView.view.width
                text: modelData.name
                highlighted: ListView.isCurrentItem
                onClicked: {
                  TunedState.setProfile(profileCombo.model[index].name)
                  profileCombo.popup.close()
                }

                HoverHandler { id: itemHover }

                ToolTip {
                  text: modelData.description
                  visible: itemHover.hovered && profileCombo.popup.visible
                  delay: 400
                }
              }
            }
          }
        }
      }

      Column {

        visible: ControlCenterState.activeTab === "projection"
        spacing: 6
        width: parent.width

        Text {
          text: "Projection Mode"
          color: Theme.textPrimary
          font.family: Theme.fontMainFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        Row {
          spacing: 4

          TabButton {
            text: "Extend"
            active: ProjectionState.currentMode === "extend"
            onTriggered: ProjectionState.setMode("extend")
          }

          TabButton {
            text: "Mirror"
            active: ProjectionState.currentMode === "mirror"
            onTriggered: ProjectionState.setMode("mirror")
          }

          TabButton {
            text: "Single"
            active: ProjectionState.currentMode === "single"
            onTriggered: ProjectionState.setMode("single")
          }
        }

        Repeater {
          model: ProjectionState.outputs
          delegate: Text {
            text: (modelData.is_primary ? "★ " : "  ") + modelData.name + (modelData.model ? "  (" + modelData.model + ")" : "")
            color: modelData.is_primary ? Theme.accent : Theme.textMuted
            font.family: Theme.fontMainFamily
            font.pixelSize: Theme.fontSize
          }
        }
      }
    }
  }

  component Stepper: Row {
    property int value: 0
    signal decrement
    signal increment

    spacing: 2
    height: 18

    Rectangle {
      width: 18
      height: 18
      radius: 2
      color: Qt.darker(Theme.surface, 1.15)
      border.width: 1
      border.color: Theme.notificationBorder

      Text {
        anchors.centerIn: parent
        text: "−"
        color: Theme.textPrimary
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.parent.decrement()
      }
    }

    Text {
      text: String(parent.value).padStart(2, '0')
      color: Theme.textPrimary
      font.family: Theme.fontMainFamily
      font.pixelSize: Theme.fontSize
      height: 18
      width: 18
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
      width: 18
      height: 18
      radius: 2
      color: Qt.darker(Theme.surface, 1.15)
      border.width: 1
      border.color: Theme.notificationBorder

      Text {
        anchors.centerIn: parent
        text: "+"
        color: Theme.textPrimary
        font.family: Theme.fontMainFamily
        font.pixelSize: Theme.fontSize
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.parent.increment()
      }
    }
  }
}
