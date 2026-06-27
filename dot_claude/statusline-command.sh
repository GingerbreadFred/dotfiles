#!/usr/bin/env bash
input=$(cat)

# Single jq pass — this script re-runs on a 1s refreshInterval, so keep the
# per-render cost to one process spawn. Fields are tab-separated; spaces inside
# a field (e.g. "VISUAL LINE") survive because IFS is just the tab.
IFS=$'\t' read -r model effort used five_pct five_reset week_pct week_reset vim_mode <<< "$(
  printf '%s' "$input" | jq -r '[
    (.model.display_name // "Claude"),
    (.effort.level // ""),
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // ""),
    (.vim.mode // "")
  ] | @tsv'
)"

now=$(date +%s)

fg() { printf '\033[38;2;%d;%d;%dm' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
reset=$(printf '\033[0m')

C_SUBTEXT="a6adc8"
C_MAUVE="cba6f7"
C_BLUE="89b4fa"
C_SAPPHIRE="74c7ec"
C_GREEN="a6e3a1"
C_PEACH="fab387"
C_RED="f38ba8"

bar_color() {
  local pct="$1"
  if [ "$pct" -ge 90 ]; then printf '%s' "$C_RED"
  elif [ "$pct" -ge 75 ]; then printf '%s' "$C_PEACH"
  else printf '%s' "$C_GREEN"; fi
}

fmt_left() {
  local secs="$1"
  [ "$secs" -lt 0 ] && secs=0
  local d=$(( secs / 86400 )) h=$(( (secs % 86400) / 3600 )) m=$(( (secs % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

make_bar() {
  local pct="$1" width=10
  local filled=$(( pct * width / 100 ))
  [ $filled -gt $width ] && filled=$width
  local b="" i=0
  while [ $i -lt $filled ]; do b="${b}█"; i=$((i+1)); done
  while [ $i -lt $width ];  do b="${b}░"; i=$((i+1)); done
  printf '%s' "$b"
}

# Left segment: vim mode, model, effort. Built into a string plus a running
# visible-column count (w_left). The bars are right-justified against this, so
# we must track widths in display columns, not bytes — every piece added here
# is plain ASCII, so ${#...} is the column count.
out_left=""
w_left=0

if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    INSERT)        vm_fg="$C_GREEN";    vm_label="INSERT" ;;
    NORMAL)        vm_fg="$C_BLUE";     vm_label="NORMAL" ;;
    VISUAL)        vm_fg="$C_MAUVE";    vm_label="VISUAL" ;;
    "VISUAL LINE") vm_fg="$C_MAUVE";    vm_label="V-LINE" ;;
    *)             vm_fg="$C_SAPPHIRE"; vm_label="$vim_mode" ;;
  esac
  out_left+="$(fg "$vm_fg")${vm_label}${reset}  "
  w_left=$(( w_left + ${#vm_label} + 2 ))
fi

out_left+="$(fg "$C_MAUVE")${model}${reset}"
w_left=$(( w_left + ${#model} ))

if [ -n "$effort" ]; then
  case "$effort" in
    low)       eff_fg="$C_GREEN" ;;
    medium)    eff_fg="$C_SAPPHIRE" ;;
    high)      eff_fg="$C_PEACH" ;;
    xhigh|max) eff_fg="$C_RED" ;;
    *)         eff_fg="$C_BLUE" ;;
  esac
  out_left+=" $(fg "$eff_fg")${effort}${reset}"
  w_left=$(( w_left + 1 + ${#effort} ))
fi

# Context bar — left-justified, right after the effort.
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  out_left+="  $(fg "$C_SUBTEXT")ctx $(fg "$(bar_color "$used_int")")$(make_bar "$used_int")${reset}"
  w_left=$(( w_left + 2 + 4 + 10 ))
fi

# Right segment: rate-limit bars only (5h, 7d), right-justified. Each bar is
# exactly 10 columns; labels are fixed width. sep is the 2-column gap between
# bar groups.
out_right=""
w_right=0
sep=""

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  out_right+="${sep}$(fg "$C_SUBTEXT")5h $(fg "$(bar_color "$five_int")")$(make_bar "$five_int")${reset}"
  w_right=$(( w_right + ${#sep} + 3 + 10 ))
  if [ -n "$five_reset" ]; then
    five_reset_int=$(printf '%.0f' "$five_reset")
    secs_left=$(( five_reset_int - now ))
    ftxt=$(fmt_left "$secs_left")
    out_right+=" $(fg "$C_SUBTEXT")${ftxt}${reset}"
    w_right=$(( w_right + 1 + ${#ftxt} ))
  fi
  sep="  "
fi

if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct")
  out_right+="${sep}$(fg "$C_SUBTEXT")7d $(fg "$(bar_color "$week_int")")$(make_bar "$week_int")${reset}"
  w_right=$(( w_right + ${#sep} + 3 + 10 ))
  if [ -n "$week_reset" ]; then
    week_reset_int=$(printf '%.0f' "$week_reset")
    secs_left=$(( week_reset_int - now ))
    wtxt=$(fmt_left "$secs_left")
    out_right+=" $(fg "$C_SUBTEXT")${wtxt}${reset}"
    w_right=$(( w_right + 1 + ${#wtxt} ))
  fi
  sep="  "
fi

# Right-justify the limit bars, leaving a margin so the tail isn't clipped:
# Claude Code renders notifications / the verbose token counter on the right of
# this same row, so usable width is a few columns short of COLUMNS. Bump
# rmargin if the rightmost value still clips. COLUMNS is set by Claude Code
# (v2.1.153+); if it's missing or the line is too narrow, fall back to a
# left-aligned 2-column gap.
cols="${COLUMNS:-0}"
rmargin=4
if [ -n "$out_right" ]; then
  pad=$(( cols - rmargin - w_left - w_right ))
  if [ "$cols" -gt 0 ] && [ "$pad" -ge 1 ]; then
    printf '%s%*s%s' "$out_left" "$pad" "" "$out_right"
  else
    printf '%s  %s' "$out_left" "$out_right"
  fi
else
  printf '%s' "$out_left"
fi
