#!/bin/bash
## Job Name
#SBATCH --job-name=eel_26to50
## Allocation Definition
#SBATCH --account=chem
#SBATCH --partition=chem
## Resources
## Nodes
#SBATCH --nodes=1
## Tasks per node (28 is Slurm default)
#SBATCH --ntasks-per-node=28
## Walltime (days-HH:MM:SS)
#SBATCH --time=24:00:00
## Memory per node
#SBATCH --mem=100G
##Output file
#SBTACH --output cfs.out

for ((i=26;i<=50;i++));
    do 
    cd W$i
    /gscratch/chem/masiello_group/e-dda/source_code/ddscat
    cd ..
    done
wait
       
