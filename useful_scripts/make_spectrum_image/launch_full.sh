#!/bin/bash

zstart=-110
zend=110
ss=20

for ((z=$zstart;z<=$zend;z+=$ss));do
    cp launch_temp launch_temp_${z}
    sed -i "s/name=test/name=sp_${z}/g" launch_temp_${z}
    sed -i "s/z=0/z=${z}/g" launch_temp_${z}
    sbatch launch_temp_${z}
done 
