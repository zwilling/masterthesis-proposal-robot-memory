#!/bin/bash

DATE=20120719
START_TIME="$DATE 12\\:00"

rrdcreate() {
	WHAT=$1
	# remember that we always need to add the previous RRA time range
	# hence number of rows is not directly calculated by desired time frame
	rrdtool create "iobw_$WHAT.rrd" --step 10 --start 0 \
		"RRA:AVERAGE:0.5:1:720" \
		"RRA:AVERAGE:0.5:3:1680" \
		"RRA:AVERAGE:0.5:30:456" \
		"RRA:AVERAGE:0.5:180:412" \
		"RRA:AVERAGE:0.5:720:439" \
		"RRA:AVERAGE:0.5:8640:402" \
		"RRA:MIN:0.5:1:720" \
		"RRA:MIN:0.5:3:1680" \
		"RRA:MIN:0.5:30:456" \
		"RRA:MIN:0.5:180:412" \
		"RRA:MIN:0.5:720:439" \
		"RRA:MIN:0.5:8640:402" \
		"RRA:MAX:0.5:1:720" \
		"RRA:MAX:0.5:3:1680" \
		"RRA:MAX:0.5:30:456" \
		"RRA:MAX:0.5:180:412" \
		"RRA:MAX:0.5:720:439" \
		"RRA:MAX:0.5:8640:402" \
		"DS:read:GAUGE:30:0:U" \
		"DS:write:GAUGE:30:0:U"
}

rrdupdate() {
    WHAT=$1
    for l in $(awk '{ print $1 ";" $13 ";" $5 ";" $6 ";" $7 ";" $8 }' iobw_$WHAT.txt); do
        IFS=';' read -ra DATA <<< "$l"
        if [ ${DATA[3]} == "K/s" ]; then
            DATA[2]=$(echo "${DATA[2]}*1024" | bc)
        elif [ ${DATA[3]} == "M/s" ]; then
            DATA[2]=$(echo "${DATA[2]}*1024*1024" | bc)
        fi

        if [ ${DATA[5]} == "K/s" ]; then
            DATA[4]=$(echo "${DATA[4]}*1024" | bc)
        elif [ ${DATA[5]} == "M/s" ]; then
            DATA[4]=$(echo "${DATA[4]}*1024*1024" | bc)
        fi

        DATA[0]=$(date -d "$DATE ${DATA[0]}" "+%s")

    #echo ts: ${DATA[0]} proc: ${DATA[1]} read: ${DATA[2]} write: ${DATA[4]}

        #echo rrdtool update iobw_$WHAT.rrd "${DATA[0]}:${DATA[2]}:${DATA[4]}"
        rrdtool update iobw_$WHAT.rrd "${DATA[0]}:${DATA[2]}:${DATA[4]}"
    done
}

rrdgraph() {
    WHAT=$1
    rrdtool graph "iobw_$WHAT.pdf" --imgformat="PDF" \
	--start="$START_TIME" --end="start+1h" --step=10 \
	--disable-rrdtool-tag --width=560 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="Storage I/O Throughput" \
	--vertical-label "Throughput (Bytes/sec)" \
	--pango-markup \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:read=iobw_$WHAT.rrd:read:AVERAGE" \
	"DEF:write=iobw_$WHAT.rrd:write:AVERAGE" \
	"LINE1:read#FF7200:Read" \
	"LINE1:write#EDAC00:Write" \
	"COMMENT:\\n"
}

rrdgraph_combined() {
    rrdtool graph "iobw_combined.pdf" --imgformat="PDF" \
	--start="$START_TIME" --end="start+1h" --step=10 \
	--disable-rrdtool-tag --width=622 \
	--font "LEGEND:10:" --font "UNIT:10:" \
	--font "TITLE:12:" --font "AXIS:8:" \
	--title="Storage I/O Writing Throughput (Average)" \
	--vertical-label "Throughput (Bytes/sec)" \
	--pango-markup --lower-limit 0 \
	--grid-dash 1:2 --color "GRID#BBBBBBC4" \
	"DEF:write_mongod=iobw_mongod.rrd:write:AVERAGE" \
	"DEF:write_record=iobw_record.rrd:write:AVERAGE" \
        "COMMENT:     " \
	"LINE1.5:write_mongod#EDAC00:MongoDB (2 topics)" \
	"GPRINT:write_mongod:AVERAGE:Average\\: %6.2lf %sB/sec" \
	"GPRINT:write_mongod:MAX:Maximum\\: %6.2lf %sB/sec\\n" \
        "COMMENT:     " \
	"LINE1.5:write_record#b72921:rosbag  (1 topic) " \
	"GPRINT:write_record:AVERAGE:Average\\: %6.2lf %sB/sec" \
	"GPRINT:write_record:MAX:Maximum\\: %6.2lf %sB/sec\\n" \

#    rrdtool graph "iobw_combined.pdf" --imgformat="PDF" \
#	--start="$START_TIME" --end="start+1h" --step=10 \
#	--disable-rrdtool-tag --width=560 \
#	--font "LEGEND:10:" --font "UNIT:10:" \
#	--font "TITLE:12:" --font "AXIS:8:" \
#	--title="Storage I/O Writing Throughput (Average)" \
#	--vertical-label "Throughput (Bytes/sec)" \
#	--pango-markup \
#	"DEF:read_mongod=iobw_mongod.rrd:read:AVERAGE" \
#	"DEF:write_mongod=iobw_mongod.rrd:write:AVERAGE" \
#	"DEF:read_record=iobw_record.rrd:read:AVERAGE" \
#	"DEF:write_record=iobw_record.rrd:write:AVERAGE" \
#	"LINE1:read_mongod#FF7200:MongoDB read" \
#	"LINE1:write_mongod#EDAC00:MongoDB write" \
#	"LINE1:read_record#001894:rosbag read" \
#	"LINE1:write_record#b72921:rosbag write" \
#	"COMMENT:\\n"

}

#rrdcreate mongod
#rrdcreate record

#rrdupdate mongod
#rrdupdate record

rrdgraph mongod
rrdgraph record

rrdgraph_combined
