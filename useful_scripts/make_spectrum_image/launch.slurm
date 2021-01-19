#!/bin/bash
## Job Name
#SBATCH --job-name=test
## Allocation Definition
#SBATCH --account=chem-ckpt
#SBATCH --partition=ckpt
## Resources
## Nodes
#SBATCH --nodes=1
## Tasks per node (28 is Slurm default)
#SBATCH --ntasks-per-node=28
## Walltime (days-HH:MM:SS)
#SBATCH --time=15:00:00
## Memory per node
#SBATCH --mem=80G
##Output file
#SBTACH --output cfs.out

ystart=-110
yend=100
z=0

ss=20

for ((y=$ystart;y<=$yend;y+=$ss));do
    mkdir y${y}_z${z}; cd y${y}_z${z}
    ln -s ../shape.dat ./
    cp ../ddscat.par ./
    sed -i "s/0.0 0.0 0.0 = x, y, z/0.0 ${y} ${z} = x, y, z/g" ddscat.par
    /gscratch/chem/masiello_group/e-dda/source_code/ddscat
    cd ../
done
