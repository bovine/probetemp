#!/bin/sh

RRDFILE=probetemp.rrd
IMAGEFILE3=~/public_html/probetemp3.png
IMAGEFILE14=~/public_html/probetemp14.png

if [ ! -f $RRDFILE ]; then
    echo "Could not access $RRDFILE"
    exit 1
fi


#DAYCOLOR="#aaaa00"
DAYCOLOR="#227722"
# needs rrdtool-1.2.9 or higher.
#export LANG=en_US.UTF-8
#    --vertical-label="Temperature (°F)"

rrdtool graph $IMAGEFILE3 \
    -A -w600 -h480 --imgformat=PNG \
    --title="Cowhouse Temperatures (last 3 days) ... $(date)" \
    --vertical-label="Temperature (F)" \
    --start="-3 day" \
    DEF:id1=$RRDFILE:id1:AVERAGE \
    DEF:id2=$RRDFILE:id2:AVERAGE \
    DEF:id3=$RRDFILE:id3:AVERAGE \
    CDEF:id1f=id1,9,5,/,*,32,+ \
    CDEF:id2f=id2,9,5,/,*,32,+ \
    CDEF:id3f=id3,9,5,/,*,32,+ \
    LINE1:id1f#ff0000:"attic" \
    LINE1:id2f#0000ff:"outside" \
    LINE1:id3f#00ffff:"datacenter" \
    HRULE:32$DAYCOLOR \
    VRULE:$(date -d 'today 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-1 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-2 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-3 day 0:00' +%s)$DAYCOLOR \
    COMMENT:"\\l" \
    COMMENT:"currently ..." \
    GPRINT:id1f:LAST:"attic %.1lf" \
    GPRINT:id2f:LAST:"outside %.1lf" \
    GPRINT:id3f:LAST:"datacenter %.1lf\\r" >/dev/null



rrdtool graph $IMAGEFILE14 \
    -A -w600 -h480 --imgformat=PNG \
    --title="Cowhouse Temperatures (last 14 days) ... $(date)" \
    --vertical-label="Temperature (F)" \
    --start="-14 day" \
    DEF:id1=$RRDFILE:id1:AVERAGE \
    DEF:id2=$RRDFILE:id2:AVERAGE \
    DEF:id3=$RRDFILE:id3:AVERAGE \
    CDEF:id1f=id1,9,5,/,*,32,+ \
    CDEF:id2f=id2,9,5,/,*,32,+ \
    CDEF:id3f=id3,9,5,/,*,32,+ \
    LINE1:id1f#ff0000:"attic" \
    LINE1:id2f#0000ff:"outside" \
    LINE1:id3f#00ffff:"datacenter" \
    HRULE:32$DAYCOLOR \
    VRULE:$(date -d 'today 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-1 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-2 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-3 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-4 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-5 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-6 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-7 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-8 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-9 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-10 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-11 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-12 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-13 day 0:00' +%s)$DAYCOLOR \
    VRULE:$(date -d '-14 day 0:00' +%s)$DAYCOLOR \
    COMMENT:"\\l" \
    COMMENT:"currently ..." \
    GPRINT:id1f:LAST:"attic %.1lf" \
    GPRINT:id2f:LAST:"outside %.1lf" \
    GPRINT:id3f:LAST:"datacenter %.1lf\\r" >/dev/null

chcon -t httpd_sys_content_t $IMAGEFILE3 $IMAGEFILE14

