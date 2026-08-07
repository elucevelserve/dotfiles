pragma Singleton
import Quickshell
import QtQuick
import "../services"

Singleton {
  readonly property string currentProfile: TunedService.currentProfile
  readonly property var availableProfiles: TunedService.availableProfiles

  function setProfile(name) {
    TunedService.setProfile(name)
  }
}
