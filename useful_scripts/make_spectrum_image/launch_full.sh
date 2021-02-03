#!/bin/bash

zstart=-110
zend=110
ss=20

for ((z=$zstart;z<=$zend;z+=$ss));do
    cp launch.slurm launch_${z}.slurm
    sed -i "s/name=test/name=sp_${z}/g" launch_${z}.slurm
    sed -i "s/z=0/z=${z}/g" launch_${z}.slurm
    sbatch launch_${z}.slurm
done 
