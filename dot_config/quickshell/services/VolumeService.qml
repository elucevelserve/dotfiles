pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
  id: root

  readonly property bool ready: Pipewire.ready
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property bool micActive: !!root.source && micLinks.linkGroups.length > 0

  function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value))
  }

  function openMixer() {
    Quickshell.execDetached(["kitty", "-e", "alsamixer"])
  }

  function toggleSinkMute() {
    if (root.sink && root.sink.audio) {
      root.sink.audio.muted = !root.sink.audio.muted
    }
  }

  function toggleSourceMute() {
    if (root.source && root.source.audio) {
      root.source.audio.muted = !root.source.audio.muted
    }
  }

  function adjustSinkVolume(delta) {
    if (!root.sink || !root.sink.audio) {
      return
    }

    const step = delta > 0 ? 0.01 : -0.01
    root.sink.audio.volume = root.clamp(root.sink.audio.volume + step, 0.0, 1.5)
  }

  function adjustSourceVolume(delta) {
    if (!root.source || !root.source.audio) {
      return
    }

    const step = delta > 0 ? 0.01 : -0.01
    root.source.audio.volume = root.clamp(root.source.audio.volume + step, 0.0, 1.5)
  }

  function setSinkVolume(value) {
    if (!root.sink || !root.sink.audio) {
      return
    }
    root.sink.audio.volume = root.clamp(value, 0.0, 1.5)
  }

  function setSourceVolume(value) {
    if (!root.source || !root.source.audio) {
      return
    }
    root.source.audio.volume = root.clamp(value, 0.0, 1.5)
  }

  PwObjectTracker {
    objects: [root.sink, root.source]
  }

  PwNodeLinkTracker {
    id: micLinks
    node: root.source
  }
}
