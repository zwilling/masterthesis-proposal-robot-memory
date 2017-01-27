#!/bin/bash

EXPERIMENT="test"
DURATION="30m"

OUTPUT_PATH="/home/fzwilling/masterthesis-proposal-robot-memory/eval/res"
INPUT="/home/fzwilling/fawkes-masterarbeit/bin"

MEMORY_SCALE=100000000

mkdir -p $OUTPUT_PATH/$EXPERIMENT
rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/cpu-mem.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=10 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="CPU and Memory Usage of Recording Processes" \
	--vertical-label "CPU Usage (%)" \
	--right-axis "$MEMORY_SCALE:0" \
	--right-axis-label "Memory Usage (Bytes)" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:cpu_fawkes=$INPUT/fawkes.rrd:cpu_usage:AVERAGE" \
	"DEF:mem_fawkes=$INPUT/fawkes.rrd:mem_rss:AVERAGE" \
	"CDEF:memavgS_fawkes=mem_fawkes,$MEMORY_SCALE,/" \
	"DEF:cpu_mongod_local=$INPUT/mongod_local.rrd:cpu_usage:AVERAGE" \
	"DEF:mem_mongod_local=$INPUT/mongod_local.rrd:mem_rss:AVERAGE" \
	"CDEF:memavgS_mongod_local=mem_mongod_local,$MEMORY_SCALE,/" \
	"DEF:cpu_mongod_repl=$INPUT/mongod_repl.rrd:cpu_usage:AVERAGE" \
	"DEF:mem_mongod_repl=$INPUT/mongod_repl.rrd:mem_rss:AVERAGE" \
	"CDEF:memavgS_mongod_repl=mem_mongod_repl,$MEMORY_SCALE,/" \
	"COMMENT:<b>CPU</b>" \
	"LINE1:cpu_fawkes#FF7200:fawkes" \
	"LINE1:cpu_mongod_local#b72921:mongod_local" \
	"LINE1:cpu_mongod_repl#fa0d00:mongod_repl" \
	"COMMENT:\\n" \
	"COMMENT:<b>Mem</b>" \
	"LINE1:memavgS_fawkes#EDAC00:fawkes" \
	"LINE1:memavgS_mongod_local#001894:mongod_local" \
	"LINE1:memavgS_mongod_repl#506100:mongod_repl" \
	"COMMENT:\\n" \
