#!/usr/bin/env python3

import json
import os
import subprocess
import sys

move_script = os.path.join(os.path.dirname(__file__), "sway-swap-workspaces.sh")
if len(sys.argv) != 2 or sys.argv[1] not in ["next", "prev"]:
    print(f"usage: {sys.argv[0]} [workspace]")
    exit(1)

workspaces = json.loads(subprocess.check_output(["swaymsg", "-t", "get_workspaces"]))
current_workspace = next(workspace for workspace in workspaces if workspace["focused"])
output_workspaces = [workspace for workspace in workspaces
                     if workspace["output"] == current_workspace["output"]]

direction = 1 if sys.argv[1] == "next" else -1
target_index = workspaces.index(current_workspace) + direction
target_workspace = workspaces[target_index % len(workspaces)]
subprocess.run([move_script, target_workspace["name"]])
