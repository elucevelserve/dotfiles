pragma Singleton
import Quickshell
import PidExe
import QtQuick

Singleton {
  id: root

  // Bumped when desktop entries (re)load.
  // Widgets read this in their bindings to re-evaluate after the async scan.
  property int revision: 0

  function resolveIconPath(appId, pid) {
    if (!appId) return ""

    const result = (function() {
      // 1. Standard desktop entry lookup
      const entry = DesktopEntries.heuristicLookup(appId)
      let icon = Quickshell.iconPath(entry?.icon, true)
      if (icon) return icon

      // 2. The app_id itself as an icon name
      icon = Quickshell.iconPath(appId, true)
      if (icon) return icon

      // 3. Variations: lowercase, kebab-case, last dot-part, last dot-part lowercase
      const variants = [appId.toLowerCase(), appId.toLowerCase().replace(/\s+/g, "-")]
      const lastPart = appId.split(".").pop()
      if (lastPart && lastPart !== appId) {
        variants.push(lastPart, lastPart.toLowerCase())
      }
      for (const v of variants) {
        icon = Quickshell.iconPath(v, true)
        if (icon) return icon
      }

      // 4. Deep search: entry id/name/exec contains the app_id.
      //    Guarded: short ids ("vim" matches nvim, "code" matches
      //    code-insiders) and the empty string (matches everything) are
      //    unsafe, and QHash iteration order is randomized per process, so
      //    the winner would be nondeterministic.
      const stripped = appId.replace(/-bin$/, "").toLowerCase()
      const entries = DesktopEntries.applications.values
      if (stripped.length >= 3) {
        for (const e of entries) {
          const eId = (e.id || "").toLowerCase()
          const eName = (e.name || "").toLowerCase()
          const eExec = (e.execString || "").toLowerCase()
          if (eId.includes(stripped) || eName.includes(stripped) || eExec.includes(stripped)) {
            icon = Quickshell.iconPath(e.icon, true)
            if (icon) return icon
          }
        }
      }

      // 5. Word match: any word of the app_id equals an entry id/name
      //    ("VirtualBox Machine" -> "virtualbox" -> virtualbox.desktop)
      const words = stripped.split(/[^a-z0-9]+/).filter(w => w.length >= 2)
      for (const w of words) {
        for (const e of entries) {
          const eId = (e.id || "").toLowerCase()
          const eName = (e.name || "").toLowerCase()
          if (w === eId || w === eName) {
            icon = Quickshell.iconPath(e.icon, true)
            if (icon) return icon
          }
        }
      }

      // 6. KDE-style: window pid -> /proc/<pid>/exe -> match entry
      //    Exec/command/StartupWMClass
      //    ("org.godotengine.ProjectManager" pid -> /usr/bin/godot -> godot.desktop)
      //    Synchronous readlink via the PidExe C++ plugin; "" (dead pid) is
      //    terminal, fall through to the fallback.
      if (pid) {
        const exeName = PidExe.resolve(pid).split("/").pop().toLowerCase()
        if (exeName) {
          for (const e of entries) {
            const execFirst = (e.execString || "").split(/\s+/)[0].toLowerCase().split("/").pop()
            const execCmd = (e.command && e.command.length > 0 ? String(e.command[0]) : "").toLowerCase().split("/").pop()
            const eClass = (e.startupClass || "").toLowerCase()
            if (exeName === execFirst || exeName === execCmd || exeName === eClass) {
              icon = Quickshell.iconPath(e.icon, true)
              if (icon) return icon
            }
          }
        }
      }

      // 7. Last resort: generic "unknown application" icon
      //    (present in both breeze-icons and adwaita-icon-theme, both
      //    guaranteed by the packages.toml dependency closure)
      return Quickshell.iconPath("application-x-executable")
    })()
    return result
  }

  Connections {
    target: DesktopEntries
    function onApplicationsChanged() {
      root.revision++
    }
  }
}
