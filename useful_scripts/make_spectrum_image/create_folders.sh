#!/bin/bash
module load anaconda3_5.3

python -c 'import find_points; find_points.find_raster(extent=10, raster_ss=10)'
input="spec_image_points.txt"

IFS='\t' # space is set as delimiter 

while IFS= read -r line
do
    y=$(echo "$line" | awk '{print $1}')
    z=$(echo "$line" | awk '{print $2}')
    mkdir y${y}_z${z}; cd y${y}_z${z}
    ln -s ../shape.dat ./
    cp ../ddscat.par ./
    sed -i "s/0.0 0.0 0.0 = x, y, z/0.0 ${y} ${z} = x, y, z/g" ddscat.par
    cd ../

done < "$input"
 
rm -r __pycache__

