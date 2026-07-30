#!/usr/bin/env bash
# Temps engagé par session, depuis .claude/activity.log (horodatages epoch + tag).
#
# « Engagé » = somme des intervalles entre événements consécutifs SOUS le seuil
# d'idle ; un intervalle plus long = pause (exclue). Approxime le temps de présence
# active (réflexion + échange + tests + code), pas le temps de cerveau pur.
# Les sessions sont délimitées par les lignes `session-start`.
#
# Usage : bin/engaged-time.sh [idle_seconds=600] [logfile]
set -euo pipefail
idle="${1:-600}"
log="${2:-${CLAUDE_PROJECT_DIR:-.}/.claude/activity.log}"
[ -f "$log" ] || { echo "pas de journal d'activité : $log"; exit 0; }

awk -v idle="$idle" '
  function fmt(s){ return sprintf("%dh%02d", int(s/3600), int((s%3600)/60)) }
  function when(e){ cmd="date -d @"e" +\"%Y-%m-%d %H:%M\""; cmd|getline t; close(cmd); return t }
  function report(){ printf "session %s | engagé %s | span %s | %d évts\n", when(first), fmt(eng), fmt(last-first), n }
  $2=="session-start" && n>0 { report(); tot+=eng }
  $2=="session-start" { first=$1; prev=$1; eng=0; n=0 }
  { if(first==""){first=$1; prev=$1} n++; last=$1; g=$1-prev; if(g<=idle) eng+=g; prev=$1 }
  END { if(n>0){ report(); tot+=eng }
        if(NR>0) printf "----\ntotal engagé (toutes sessions) : %s\n", fmt(tot) }
' "$log"
