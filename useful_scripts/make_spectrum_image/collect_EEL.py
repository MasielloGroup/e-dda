import numpy as np
import os.path

def collect_points():
    file = open(str('spectrum_image.txt'),'w')
    file.write(str('Wave') + '\t' + str('y') + '\t' + str('z') + '\t' + str('Gamma [eV^-1]') + '\n')
    pnts_ran = np.loadtxt('run_these_points.txt')
    for point in range(0, len(pnts_ran)):
        valy = int(pnts_ran[point,0])
        valz = int(pnts_ran[point,1])
        filename = str('y')+str(valy) + str('_z') + str(valz) + str('/gammatable')
        if os.path.isfile(filename) == True and os.stat(filename).st_size != 690:
            data = np.loadtxt(filename,skiprows=14)
            wave_um = data[0]
            Gamma = data[2]
            ebeam_y = valy
            ebeam_z = valz
            file.write(str(wave_um) + '\t' + str(ebeam_y) + '\t' + str(ebeam_z) + '\t' + str(Gamma) + '\n')
    file.close()

collect_points()
