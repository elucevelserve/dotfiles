#!/usr/bin/env python3

import json
import subprocess
import sys
import os

# Configuration
TEMP_NIGHT = 4000  # Night temperature (warmer/redder)
TEMP_DAY = 6000    # Day temperature (cooler/bluer)
STATE_FILE = os.path.expanduser("~/.config/waybar/.lightfilter_state")

def is_hyprsunset_running():
    """Check if hyprsunset is currently running"""
    try:
        result = subprocess.run(['pgrep', 'hyprsunset'], capture_output=True, text=True)
        return result.returncode == 0
    except:
        return False

def get_current_state():
    """Get the current state from state file"""
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, 'r') as f:
                return f.read().strip() == "on"
        except:
            pass
    return False

def set_state(enabled):
    """Save the current state to state file"""
    try:
        with open(STATE_FILE, 'w') as f:
            f.write("on" if enabled else "off")
    except:
        pass

def toggle_lightfilter():
    """Toggle the light filter state"""
    current_state = get_current_state()
    
    if current_state:
        # Turn off - kill hyprsunset
        try:
            subprocess.run(['pkill', 'hyprsunset'], check=False)
            set_state(False)
        except:
            pass
    else:
        # Turn on - start hyprsunset
        try:
            subprocess.run(['hyprsunset', '-t', str(TEMP_NIGHT)], check=False)
            set_state(True)
        except:
            pass

def get_status():
    """Get current status for waybar"""
    is_running = is_hyprsunset_running()
    state = get_current_state()
    
    # Sync state with actual process
    if is_running != state:
        set_state(is_running)
        state = is_running
    
    if state:
        # Light filter is ON - single warm icon
        return {
            "text": "🞋",
            "tooltip": f"Light filter ON ({TEMP_NIGHT}K) - Click to disable",
            "class": "lightfilter-on"
        }
    else:
        # Light filter is OFF - single bright icon
        return {
            "text": "🞅",
            "tooltip": f"Light filter OFF ({TEMP_DAY}K) - Click to enable",
            "class": "lightfilter-off"
        }

def main():
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        toggle_lightfilter()
    else:
        status = get_status()
        print(json.dumps(status))

if __name__ == "__main__":
    main()
