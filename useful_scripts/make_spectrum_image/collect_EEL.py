import numpy as np
import os.path

ybegin=-90
yend=90

zbegin=-70
zend=70
ss=10

file = open(str('spectral_image'),'w')
file.write(str('Wave') + '\t' + str('y') + '\t' + str('z') + '\t' + str('Gamma [eV^-1]') + '\n')
for valy in range(ybegin,yend,ss):
    for valz in range(zbegin,zend,ss): 
        filename = str('y')+str(valy) + str('_z') + str(valz) + str('/gammatable')
        if os.path.isfile(filename) == True and os.stat(filename).st_size != 690:
            data = np.loadtxt(filename,skiprows=14)
            wave_um = data[0]
            Gamma = data[2]
            ebeam_y = valy
            ebeam_z = valz
            file.write(str(wave_um) + '\t' + str(ebeam_y) + '\t' + str(ebeam_z) + '\t' + str(Gamma) + '\n')
file.close()
