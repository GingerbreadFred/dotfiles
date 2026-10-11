#!/bin/sh
# PLANNOTATOR_BROWSER on macOS: open Plannotator in a new Firefox window instead
# of a tab in an existing one. -n is needed, otherwise `open` drops --args when
# Firefox is already running.
exec open -na Firefox --args -new-window "$1"
