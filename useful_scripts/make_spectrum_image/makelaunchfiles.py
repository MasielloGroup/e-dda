import numpy as np
import os.path
import string

folders = np.loadtxt('spec_image_points.txt')
batch_size = 20
for i in range(0,int(len(folders)/batch_size)+1):
    yvals = folders[batch_size*i:batch_size*(i+1),0].astype(int)
    zvals = folders[batch_size*i:batch_size*(i+1),1].astype(int)
    writefile = open(str('launch')+str(i)+str('.slurm'),'w')
    writefile.write(str('#!/bin/bash') + '\n' + str('## Job Name') + '\n')
    writefile.write(str('#SBATCH --job-name=') + str('sp_')+str(i)+'\n')
    writefile.write(str('#SBATCH --account=chem-ckpt') + '\n')
    writefile.write(str('#SBATCH --partition=ckpt') + '\n')
    writefile.write(str('## Resources') + '\n' + str('## Nodes') + '\n')
    writefile.write(str('#SBATCH --nodes=1') + '\n')
    writefile.write(str('## Tasks per node (28 is Slurm default)') + '\n')
    writefile.write(str('#SBATCH --ntasks-per-node=28') + '\n')
    writefile.write(str('## Walltime (days-HH:MM:SS)') + '\n')
    writefile.write(str('#SBATCH --time=4:00:00') + '\n')
    writefile.write(str('## Memory per node') + '\n')
    writefile.write(str('#SBATCH --mem=100G') + '\n')
    writefile.write(str('##Output file') + '\n')
    writefile.write(str('#SBTACH --output cfs.out') + '\n' + '\n')

    writefile.write(str('module load anaconda3_4.3.1') + '\n')
    writefile.write(str('yarray=(')+str(yvals)[1:-1] + str(')')+'\n')
    writefile.write(str('zarray=(')+str(zvals)[1:-1] + str(')')+'\n'+'\n')
    writefile.write(str('for ((i=0;i<${#yarray[@]};++i)); do') + '\n')
    writefile.write('\t' + str('y=${yarray[i]}; z=${zarray[i]}') + '\n')
    writefile.write('\t' + str('cd y${y}_z${z}')+'\n')
    writefile.write('\t' + str('/gscratch/chem/masiello_group/srcEELS_fixUnit_fixCL_exc_abs_diff/ddscat'+'\n'))
    writefile.write('\t' + str('cd ../')+'\n')
    writefile.write(str('done')+'\n')
    writefile.close()
