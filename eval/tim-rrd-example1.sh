#!/bin/bash

START_TIME="20120719 12\\:00"
MEMORY_SCALE=100000000

rrdtool graph "proc.pdf" --imgformat="PDF" \
	--start="$START_TIME" --end="start+1h" --step=10 \
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
	"DEF:cpu_rosbag=proc_rosbag.rrd:cpu:AVERAGE" \
	"DEF:mem_rosbag=proc_rosbag.rrd:mem:AVERAGE" \
	"DEF:io_in_rosbag=proc_rosbag.rrd:io_in:AVERAGE" \
	"DEF:io_out_rosbag=proc_rosbag.rrd:io_out:AVERAGE" \
	"CDEF:memavgS_rosbag=mem_rosbag,$MEMORY_SCALE,/" \
	"DEF:cpu_mlog_cpp=proc_mongolog_cpp.rrd:cpu:AVERAGE" \
	"DEF:mem_mlog_cpp=proc_mongolog_cpp.rrd:mem:AVERAGE" \
	"DEF:io_in_mlog_cpp=proc_mongolog_cpp.rrd:io_in:AVERAGE" \
	"DEF:io_out_mlog_cpp=proc_mongolog_cpp.rrd:io_out:AVERAGE" \
	"CDEF:memavgS_mlog_cpp=mem_mlog_cpp,$MEMORY_SCALE,/" \
	"DEF:cpu_mlog_py=proc_mongolog_py.rrd:cpu:AVERAGE" \
	"DEF:mem_mlog_py=proc_mongolog_py.rrd:mem:AVERAGE" \
	"DEF:io_in_mlog_py=proc_mongolog_py.rrd:io_in:AVERAGE" \
	"DEF:io_out_mlog_py=proc_mongolog_py.rrd:io_out:AVERAGE" \
	"CDEF:memavgS_mlog_py=mem_mlog_py,$MEMORY_SCALE,/" \
	"DEF:cpu_mongod=proc_mongod.rrd:cpu:AVERAGE" \
	"DEF:mem_mongod=proc_mongod.rrd:mem:AVERAGE" \
	"DEF:io_in_mongod=proc_mongod.rrd:io_in:AVERAGE" \
	"DEF:io_out_mongod=proc_mongod.rrd:io_out:AVERAGE" \
	"CDEF:memavgS_mongod=mem_mongod,$MEMORY_SCALE,/" \
	"CDEF:cpu_mongod_half=cpu_mongod,2,/" \
	"CDEF:memavgS_mongod_half=memavgS_mongod,2,/" \
	"COMMENT:<b>CPU</b>" \
	"LINE1:cpu_rosbag#FF7200:rosbag" \
	"LINE1:cpu_mlog_cpp#b72921:mlog/C++" \
	"LINE1:cpu_mongod_half#fa0d00:mlog/C++ + MongoDB:STACK" \
	"LINE1:cpu_mlog_py#330088:mlog/Py" \
	"LINE1:cpu_mongod_half#853cff:mlog/Py + MongoDB:STACK" \
	"COMMENT:\\n" \
	"COMMENT:<b>Mem</b>" \
	"LINE1:memavgS_rosbag#EDAC00:rosbag" \
	"LINE1:memavgS_mlog_cpp#001894:mlog/C++" \
	"LINE1:memavgS_mlog_py#98b800:mlog/Py" \
	"LINE1:memavgS_mongod#506100:MongoDB" \
	"COMMENT:\\n" \

