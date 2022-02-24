#!/bin/sh
# Use of GMT 5.x.x
filen="out.ps"

r=-81/-71/2/12
j=M-75/5/12

# From gmt_default
gmt gmtset  FONT_LABEL  12              MAP_FRAME_PEN 1
gmt gmtset  FONT_ANNOT_PRIMARY 11       MAP_ANNOT_OFFSET 0.1
gmt gmtset  MAP_TICK_PEN 1              MAP_TICK_LENGTH -0.1
gmt gmtset  MAP_LABEL_OFFSET 0.5c       MAP_FRAME_TYPE PLAIN
gmt gmtset  FONT_ANNOT_SECONDARY 10
gmt gmtset  MAP_GRID_PEN_PRIMARY thinnest,-

gmt psbasemap -R$r -J$j -B2f1/2f1NsWe -K -P -Y2 -X2 > $filen

gmt makecpt -Cglobe -T-5000/5000/10 -Z > etopo.cpt
gmt grdgradient Colombia.grd -Gincl.int -A315 -Ne0.7 #angle of light
gmt grdimage Colombia.grd -J$j -R$r -Cetopo.cpt -Iincl.int -O -K -Q >> $filen

# Coast lines and political borders
gmt pscoast -R$r -J$j -Dh -W1 -N1/0.25p,- -O -K >> $filen

# Faults from Geological map 2015
awk '$1!="#" {print $1,$2}' Fallas_Mapa_Geolgico_de_Colombia_2015.gmt | gmt psxy -R$r -J$j -W0.5/black -O -K >> $filen

# Volcanoes
awk '$1!="#" {print $2,$1}' volcanosnorthernandes.txt | gmt psxy -R$r -J$j -Gwhite -St0.2 -W -O -K >> $filen

# Scale
gmt psbasemap -R$r -J$j -L-72.2/2.6/5/200 -O -K >> $filen

# Mutata EQ
gmt psxy -R$r -J$j -Gwhite -Sa0.6 -W0.75 -O -K << END >> $filen
-76.274539 7.236186
END

# Stations
gmt psxy -R$r -J$j -Gred -St0.3 -W1 -O -K << END >> $filen
-75.5288 6.1908
-76.0122 5.8643
-74.858 7.4923
-74.4563 6.5395
-74.8692 5.5635
-78.0147 8.5475
-76.2827 4.9052
-73.712 7.1072
END

gmt psxy -R -J -O -K -W1 << EOF >> $filen
-77 6
-75 6
-75 8
-77 8
-77 6
EOF

# Inset with Colombian map
gmt psxy -R-92/-58/-14/25 -JM-75/5/4 -O -K -W1 -Gwhite -Y-1 << EOF >> $filen
-92 -14
-58 -14
-58 25
-92 25
-92 -14
EOF
gmt pscoast -R-92/-58/-14/25 -JM-75/5/4 -Dh -W0.5 -N1/0.25p -O -K -Glightgray >> $filen
gmt psxy -R -J -O -K -W1 << EOF >> $filen
-81 2
-71 2
-71 12
-81 12
-81 2
EOF

r=-77/-75/6/8
j=M-76/7/6

gmt psbasemap -R$r -J$j -B1f0.5/1f0.5NswE -K -O -P -Y5.7 -X11 >> $filen
gmt grdgradient aster_merged.grd -Gincl.int -A315 -Ne0.7 #angle of light
gmt grdimage aster_merged.grd -J$j -R$r -Cetopo.cpt -Iincl.int -E300 -O -K -Q >> $filen
awk '{print $4,$5,$3/30}' EQdata_RSNC_1993_102016.txt | gmt psxy -R$r -J$j -W -Sc -Gyellow -O -K >> $filen

# Faults from Geological map 2015
awk '$1!="#" {print $1,$2}' Fallas_Mapa_Geolgico_de_Colombia_2015.gmt | gmt psxy -R$r -J$j -W0.75/black -O -K >> $filen
# Stations
gmt psxy -R$r -J$j -Gred -St0.3 -W1 -O -K << END >> $filen
-75.5288 6.1908
END
# Mutata EQ
gmt psxy -R$r -J$j -Gwhite -Sa0.6 -W0.75 -O -K << END >> $filen
-76.274539 7.236186
END
# Scale
gmt psbasemap -R$r -J$j -L-76.7/6.25/5/50 -O >> $filen

gmt psconvert out.ps -A -Tf -P -Fcolombia_mutata.pdf
rm out.ps incl.int col.legend

