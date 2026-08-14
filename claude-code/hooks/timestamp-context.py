#!/usr/bin/env python3
# UserPromptSubmit hook. Prints one <ctx> line carrying wall clock time, the
# gap since the last stamp in this session, and git state. Stays silent unless
# ten minutes have passed, so an idle-then-resumed session is visibly stale
# rather than reading as continuous.

import json
import os
import subprocess
import sys
import time

THRESHOLD_SECONDS = 600
PRUNE_SECONDS = 30 * 86400
STATE_DIR = os.path.join(
    os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"),
    "claude",
    "timestamp-hook",
)


def git(cwd, *arguments):
    try:
        result = subprocess.run(
            ("git", *arguments),
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=3,
        )
    except Exception:
        return None

    if result.returncode != 0:
        return None

    return result.stdout.strip()


try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

session_id = payload.get("session_id")
cwd = payload.get("cwd") or os.getcwd()

if not isinstance(session_id, str) or not session_id:
    sys.exit(0)

# One state file per session, so a second session running in parallel cannot
# suppress this one's stamp.
state_path = os.path.join(STATE_DIR, "".join(c for c in session_id if c.isalnum() or c in "-_"))
now = time.time()
previous = None

try:
    with open(state_path) as handle:
        previous = float(handle.read().strip())
except Exception:
    previous = None

if previous is not None and now - previous < THRESHOLD_SECONDS:
    sys.exit(0)

try:
    os.makedirs(STATE_DIR, exist_ok=True)

    with open(state_path, "w") as handle:
        handle.write("%d" % now)

    for name in os.listdir(STATE_DIR):
        stale = os.path.join(STATE_DIR, name)

        if now - os.path.getmtime(stale) > PRUNE_SECONDS:
            os.remove(stale)
except Exception:
    pass

gap = ""

if previous is not None:
    minutes = int((now - previous) // 60)
    hours, minutes = divmod(minutes, 60)
    days, hours = divmod(hours, 24)

    if days:
        gap = " +%dd%02dh" % (days, hours)
    elif hours:
        gap = " +%dh%02dm" % (hours, minutes)
    else:
        gap = " +%dm" % minutes

repo = ""

try:
    root = git(cwd, "rev-parse", "--show-toplevel")

    if root:
        branch = git(cwd, "symbolic-ref", "--quiet", "--short", "HEAD")
        parts = []

        if not branch:
            branch = git(cwd, "rev-parse", "--short", "HEAD") or "?"
            parts.append("detached")

        status = git(cwd, "status", "--porcelain")

        if status is None:
            parts.append("status unknown")
        elif status:
            parts.append("%d dirty" % len(status.splitlines()))
        else:
            parts.append("clean")

        counts = git(cwd, "rev-list", "--left-right", "--count", "@{upstream}...HEAD")

        if not counts:
            parts.append("no upstream")
        else:
            behind, ahead = counts.split()

            if ahead != "0":
                parts.append("%s ahead" % ahead)

            if behind != "0":
                parts.append("%s behind" % behind)

        repo = " | %s@%s %s" % (os.path.basename(root), branch, " ".join(parts))
except Exception:
    repo = ""

print("<ctx>%s%s%s</ctx>" % (time.strftime("%Y-%m-%d %H:%M %Z %a"), gap, repo))
