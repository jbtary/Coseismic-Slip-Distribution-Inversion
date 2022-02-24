#!/bin/sh

filen="out.ps"

#awk '{print $1,-$2,$3}' SSI_Results/3.2_1.1_mutata.0112.xyz > slip.xyz
awk '{print $1,-$2,$4}' SSI_Results/2.5_1.1_mutata.01114.txt > slip.xyz

gmt gmtset  FONT_LABEL  12              MAP_FRAME_PEN 1
gmt gmtset  FONT_ANNOT_PRIMARY 11       MAP_ANNOT_OFFSET 0.1
gmt gmtset  MAP_TICK_PEN 1              MAP_TICK_LENGTH -0.1
gmt gmtset  MAP_LABEL_OFFSET 0.5c       MAP_FRAME_TYPE PLAIN
gmt gmtset  FONT_ANNOT_SECONDARY 10
gmt gmtset  MAP_GRID_PEN_PRIMARY thinnest,-

# Fault plane
gmt makecpt -Cno_green -T0/0.25/0.01 > slip.cpt
drange="0/50"
depth="-50/0"
dds="0.05/0.05"
r="${drange}/${depth}"
j=X7/7

gmt surface slip.xyz -R$r -I${dds} -Gslip.grd
gmt grdimage slip.grd -R$r -J$j -Cslip.cpt -K > $filen

gmt psbasemap -R$rr -J$j -O -K -B10:"Distance along strike (km)":/10:"Depth along dip (km)":nSWe >> $filen
# Position of hypocenter
gmt psxy -R$r -J$j -Gred -Sa0.4 -W -O -K << END >> $filen
25 -25
END
gmt psscale -Cslip.cpt -D7.5/1.5/3/0.3 -B0.1:"Slip (m)": -O >> $filen

gmt psconvert out.ps -A -Tf -P -Fslip.pdf
rm out.ps slip.xyz slip.grd slip.cpt
