pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
  id: root

  property var outputs: []
  property string mode: "extend"
  property bool mirroring: false

  function refresh() {
    if (readProc.running) {
      return
    }
    readProc.running = true
  }

  function primary() {
    let best = null
    let bestKey = null
    let bestScore = Infinity
    for (const name in outputsRaw) {
      const o = outputsRaw[name]
      if (!o.logical) {
        continue
      }
      const score = o.logical.x + o.logical.y
      if (score < bestScore) {
        bestScore = score
        best = o
        bestKey = name
      }
    }
    return best ? { name: bestKey, output: best } : null
  }

  function deriveMode() {
    if (mirroring) {
      mode = "mirror"
      return
    }
    const prim = primary()
    if (!prim || !prim.output.logical) {
      mode = "extend"
      return
    }
    const nonPrimary = []
    for (const name in outputsRaw) {
      if (name !== prim.name) {
        nonPrimary.push(outputsRaw[name])
      }
    }
    if (nonPrimary.length === 0) {
      mode = "extend"
      return
    }
    const allOff = nonPrimary.every(o => !o.logical)
    if (allOff) {
      mode = "single"
      return
    }
    mode = "extend"
  }

  function secondaryForMirror() {
    const prim = primary()
    if (!prim) {
      return null
    }
    for (const name in outputsRaw) {
      if (name !== prim.name) {
        return name
      }
    }
    return null
  }

  function runNiriCommands(cmds) {
    if (cmds.length === 0) {
      return
    }
    applyProc.command = ["sh", "-c", cmds.join("; ")]
    applyProc.running = true
  }

  function setMode(targetMode) {
    if (targetMode === "mirror") {
      const prim = primary()
      const secondary = secondaryForMirror()
      if (!prim || !secondary) {
        return
      }
      const turnOn = []
      if (!outputsRaw[secondary] || !outputsRaw[secondary].logical) {
        turnOn.push("niri msg output " + secondary + " on")
      }
      runNiriCommands(turnOn)
      wlMirrorProc.command = ["wl-mirror", "--fullscreen-output", secondary, prim.name]
      wlMirrorProc.running = true
      mirroring = true
      mode = "mirror"
      return
    }

    if (wlMirrorProc.running) {
      wlMirrorProc.running = false
    }
    mirroring = false

    const prim = primary()
    if (!prim) {
      return
    }
    const cmds = []
    for (const name in outputsRaw) {
      if (name === prim.name) {
        continue
      }
      if (targetMode === "single") {
        cmds.push("niri msg output " + name + " off")
      } else if (targetMode === "extend") {
        cmds.push("niri msg output " + name + " on")
        const rightX = prim.output.logical.x + (prim.output.logical.width || 0)
        cmds.push("niri msg output " + name + " position set " + rightX + " " + prim.output.logical.y)
      }
    }
    runNiriCommands(cmds)
    refresh()
  }

  property var outputsRaw: ({})

  Component.onCompleted: refresh()

  Timer {
    interval: 5000
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Process {
    id: readProc
    command: ["niri", "msg", "-j", "outputs"]

    stdout: StdioCollector {
      id: readStdout
    }

    onExited: {
      const raw = readStdout.text.trim()
      if (!raw) {
        return
      }
      try {
        const data = JSON.parse(raw)
        if (data && typeof data === "object") {
          outputsRaw = data
          const arr = []
          const prim = root.primary()
          for (const name in data) {
            arr.push({
              name: name,
              make: data[name].make || "",
              model: data[name].model || "",
              logical: data[name].logical || null,
              is_primary: prim ? name === prim.name : false
            })
          }
          arr.sort((a, b) => a.name.localeCompare(b.name))
          outputs = arr
          root.deriveMode()
        }
      } catch (_) {}
    }
  }

  Process {
    id: applyProc
  }

  Process {
    id: wlMirrorProc

    onExited: {
      root.mirroring = false
      root.deriveMode()
    }
  }
}
