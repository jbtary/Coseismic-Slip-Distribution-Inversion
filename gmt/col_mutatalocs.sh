#!/bin/sh

# Use of ASTER GDEM 2 data
# Citation "ASTER GDEM is a product of METI and NASA."
# From https://earthexplorer.usgs.gov
# Conversion of GeoTiff images to grid:
# See http://science-codes.blogspot.com.co/2012/03/making-gmt-maps-with-aster-gdem-tif.html

# Load the earthquake location file from NLLOC: Lat Lon Depth ERH ERZ
# Select events based of uncertainties
awk 'NR>1{print $7,$8,$9,$14/2,$15/2,$16;}' LocsMutata_forgmt | awk '{ if ($4 <= 20 && $5 <= 10) print $0 }' > eqsequence.txt

r=-76.55/-76/7/7.5
j=M-76/7/10

gmt gmtset  FONT_LABEL  10              MAP_FRAME_PEN 1
gmt gmtset  FONT_ANNOT_PRIMARY 10       MAP_ANNOT_OFFSET 0.1
gmt gmtset  MAP_TICK_PEN 1              MAP_TICK_LENGTH -0.1
gmt gmtset  MAP_LABEL_OFFSET 0.5c       MAP_FRAME_TYPE PLAIN
gmt gmtset  FONT_ANNOT_SECONDARY 10
#gmt gmtset  MAP_GRID_PEN_PRIMARY thinnest,-

gmt psbasemap -R$r -J$j -B0.25f0.05/0.25f0.05nSWe -K -P -Y12 -X2 > mutata.ps

gmt makecpt -CDEM_poster -T0/8000/10 > relief.cpt
gmt grdgradient aster_merged.grd -Gincl.int -A315 -Ne0.7 #angle of light
gmt grdimage aster_merged.grd -J$j -R$r -Crelief.cpt -Iincl.int -O -K -E300 -Q >> mutata.ps

#Fault plane line
gmt psxy -R -J -O -K -W1,white,- << EOF >> mutata.ps
-76.32919 7.4927534
-76.53941 7.2626584
-76.22059 6.9779393
-76.01195 7.2093246
-76.32919 7.4927534
EOF

# USGS
#-76.169 7.374

# Faults from Geological map 2015
awk '$1!="#" {print $1,$2}' Fallas_Mapa_Geolgico_de_Colombia_2015.gmt | gmt psxy -R$r -J$j -W1 -O -K >> mutata.ps
awk '{print $2,$1,$4/111,$4/111}' eqsequence.txt | gmt psxy -R$r -J$j -Sc0.01 -W -Gcyan -O -K -Exy0.08/0.5p >> mutata.ps
awk '{print $2,$1,$6/15}' eqsequence.txt | gmt psxy -R$r -J$j -Sc -W -Gcyan -O -K >> mutata.ps
awk 'NR==2{print $2,$1}' eqsequence.txt | gmt psxy -R$r -J$j -Sa0.5 -W -Gwhite -O -K >> mutata.ps
# Position of hypocenter - SGC
gmt psxy -R$r -J$j -Gred -Sa0.5 -W -O -K << END >> mutata.ps
-76.234 7.238
END

# Scale
gmt psbasemap -R$r -J$j -L-76.1/7.05/5/10+fwhite -O -K >> mutata.ps

#W-E profile
lonrange="-76.55/-76"
depth="0/35"
r="${lonrange}/${depth}"
j=X10/-3.2

awk '{print $2,$3,$5}' eqsequence.txt | gmt psxy -R$r -J$j -W -K -Ey0.08/0.5p,100/100/100 -Gcyan -O -Sc.01 -Y-4 >> mutata.ps
awk '{print $2,$3,$6/15}' eqsequence.txt | gmt psxy -R$r -J$j -W -K -Gcyan -O -Sc >> mutata.ps
awk 'NR==2{print $2,$3}' eqsequence.txt | gmt psxy -R$r -J$j -Sa.5 -W -Gwhite -O -K >> mutata.ps
gmt psxy -R$r -J$j -Gred -Sa0.5 -W -O -K << END >> mutata.ps
-76.234 0.0
END

gmt psbasemap -R$rr -J$j -O -B0.25:"Longitude":/10g10:"Depth (km)":nsWe >> mutata.ps

gmt psconvert mutata.ps -A -Tf -P -Fmutatalocations.pdf
rm mutata.ps incl.int relief.cpt

