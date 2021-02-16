#!/bin/bash
## Job Name
#SBATCH --job-name=sp_0
#SBATCH --account=chem-ckpt
#SBATCH --partition=ckpt
## Resources
## Nodes
#SBATCH --nodes=1
## Tasks per node (28 is Slurm default)
#SBATCH --ntasks-per-node=28
## Walltime (days-HH:MM:SS)
#SBATCH --time=4:00:00
## Memory per node
#SBATCH --mem=100G
##Output file
#SBTACH --output cfs.out

module load anaconda3_4.3.1
yarray=(-21 -11  -1   9  19 -21 -11  -1   9  19 -21 -11  -1   9  19 -21 -11  -1
   9  19)
zarray=(-21 -21 -21 -21 -21 -11 -11 -11 -11 -11  -1  -1  -1  -1  -1   9   9   9
   9   9)

for ((i=0;i<${#yarray[@]};++i)); do
	y=${yarray[i]}; z=${zarray[i]}
	cd y${y}_z${z}
	/gscratch/chem/masiello_group/e-dda/source_code/ddscat
	cd ../
done
