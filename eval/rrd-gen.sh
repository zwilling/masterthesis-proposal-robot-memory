#!/bin/bash

EXPERIMENT="rcll-rs-net"
DURATION="14m"

OUTPUT_PATH="/home/fzwilling/masterthesis-proposal-robot-memory/eval/res"
INPUT="/home/fzwilling/fawkes-masterarbeit/bin"

MEMORY_SCALE=10000000
MEMCALC=10000

mkdir -p $OUTPUT_PATH/$EXPERIMENT
rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/cpu-mem.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
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
	"DEF:mem_fawkes=$INPUT/fawkes.rrd:mem_curvirt:AVERAGE" \
	"CDEF:memavgS_fawkes=mem_fawkes,$MEMCALC,/" \
	"DEF:cpu_mongod_local=$INPUT/mongod_local.rrd:cpu_usage:AVERAGE" \
	"DEF:mem_mongod_local=$INPUT/mongod_local.rrd:mem_curvirt:AVERAGE" \
	"CDEF:memavgS_mongod_local=mem_mongod_local,$MEMCALC,/" \
	"DEF:cpu_mongod_repl=$INPUT/mongod_repl.rrd:cpu_usage:AVERAGE" \
	"DEF:mem_mongod_repl=$INPUT/mongod_repl.rrd:mem_curvirt:AVERAGE" \
	"CDEF:memavgS_mongod_repl=mem_mongod_repl,$MEMCALC,/" \
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
	
rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/operations.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="MongoDB Operation Counters (Average)" \
	--vertical-label "Ops/sec" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:insert=$INPUT/opcounters.rrd:insert:AVERAGE" \
	"DEF:query=$INPUT/opcounters.rrd:query:AVERAGE" \
	"DEF:update=$INPUT/opcounters.rrd:update:AVERAGE" \
	"DEF:delete=$INPUT/opcounters.rrd:delete:AVERAGE" \
	"DEF:getmore=$INPUT/opcounters.rrd:getmore:AVERAGE" \
	"DEF:command=$INPUT/opcounters.rrd:command:AVERAGE" \
	"LINE1:insert#eeee00:Insert" \
	"LINE1:query#3399ff:Query" \
	"LINE1:update#FF7200:Update" \
	"LINE1:command#00ff00:Command" \
	"LINE1:delete#ff0000:Delete" \
	"LINE1:getmore#cc00ff:Getmore" \
	"COMMENT:\\n" \
	
rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/file-size.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="MongoDB File Sizes" \
	--vertical-label "Size (Bytes)" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:size=$INPUT/dbstats_syncedrobmem.rrd:fileSize:AVERAGE" \
	"LINE1:size#FF7200:File Size" \
	"COMMENT:\\n" \
	
rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/network.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="Network Throughput" \
	--vertical-label "Bytes/sec" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:receive=$INPUT/network.rrd:net_recv_bytes:AVERAGE" \
	"DEF:transmit=$INPUT/network.rrd:net_trans_bytes:AVERAGE" \
	"LINE1:receive#FF7200:Receive" \
	"LINE1:transmit#00ff00:Transmit" \
	"COMMENT:\\n" \

rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/rsnetwork.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="Replica Set Network Usage" \
	--vertical-label "Bytes/sec" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:bytes=$INPUT/rsnetwork.rrd:bytes:AVERAGE" \
	"LINE1:bytes#FF7200:Bytes" \
	"COMMENT:\\n" \
	


rrdtool graph "$OUTPUT_PATH/$EXPERIMENT/rsnetwork-ops.pdf" --imgformat="PDF" \
	--start="-$DURATION" --end="now" --step=5 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="Replica Set Network Usage" \
	--vertical-label "Bytes/sec" \
	--right-axis "0.001:0" \
	--right-axis-label "Ops/sec" \
	--alt-autoscale \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:bytes=$INPUT/rsnetwork.rrd:bytes:AVERAGE" \
	"DEF:ops=$INPUT/rsnetwork.rrd:ops:AVERAGE" \
	"CDEF:memavgS_ops=ops,1000,*" \
	"LINE1:bytes#FF7200:Bytes" \
	"LINE1:memavgS_ops#b72921:Ops" \
	"COMMENT:\\n" \
	
