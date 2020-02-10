#! /usr/bin/env python

import re
import sys
import math

def main():
    """\
    """
    from argparse import ArgumentParser, RawDescriptionHelpFormatter
    from textwrap import dedent
    parser = ArgumentParser(description=dedent(main.__doc__),
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    parser.add_argument('-d', '--ddscat', action='store_const', const='ddscat',
                        dest='mode', help='Generate the ddscat.par file.')
    parser.add_argument('-v', '--var', action='store_const', const='var',
                        dest='mode', help='Generate the var.par file.')
    parser.add_argument('parIn', help='The parameter.input file.')
    parser.add_argument('sInit', help='The shape_init.dat file.')

    args = parser.parse_args()
    
    # Obtain all the parameters
    par = []
    val = []
    with open(args.parIn) as file:
         for line in file:
             if "#" not in line and len(line.split()) is not 0:
                par.append(line.split()[0][:-1])
                if 'theta_info' in line:
                   val.append(line.split()[1:4])
                else:
                   val.append(line.split()[1])
    
    # Template files to be used
    shape_init = args.sInit

    # ddscatpar
    if args.mode == 'ddscat':
       ddscat_out = generate_ddscat(par, val, shape_init)
       # write to file
       with open('ddscat.par', 'w') as file:
            file.writelines(ddscat_out)

    # varpar
    if args.mode == 'var':
       var_out = generate_var(par, val, shape_init)
       # write to file
       with open('var.par', 'w') as file:
            file.writelines(var_out)

### Generate "ddscat.par" based on "shape_init.dat" ###
def generate_ddscat(par, val, shape_init):
    in_freq    = val[par.index("in_freq")]
    dc_dir     = val[par.index("dc_dir")]
    nearfield  = val[par.index("nearfield")] 
    gaussian   = val[par.index("gaussian")] 
    nambient   = val[par.index("nambient")] 
    inc_pol    = val[par.index("inc_pol")] 
    dip_space  = val[par.index("dip_space")]

    # memory allocation 
    x = []
    y = []
    z = []
    with open(shape_init) as file:
         data = file.readlines ()
    for line in data:
        line = line.split()
        if len(line) == 7 and '=' not in line:
           x.append(int(line[1]))
           y.append(int(line[2]))
           z.append(int(line[3]))
    mem_allo_x = max(x) - min(x) + 10
    mem_allo_y = max(y) - min(y) + 10
    mem_allo_z = max(z) - min(z) + 10

    # Gaussian beam pump waist (this is half of the FWHM or the waist radius of the beam) in dipole spacing
    NA = 1.25
    waist = float(in_freq) * 10**3 * 0.6 / (NA) / int(dip_space)  
    waist = "{0:.4f}".format(waist)

    # effective radius
    effR = (3 * len(x) / (4 * math.pi))**(1 / 3.0) * int(dip_space) * 10**(-3)
    effR = "{0:.4f}".format(effR)
    
    str =  (" ' ========== Parameter file for v7.3 ==================='\n")
    str += (" '**** Preliminaries ****'\n")
    str += (" 'NOTORQ' = CMTORQ*6 (DOTORQ, NOTORQ) -- either do or skip torque calculations\n")
    str += (" 'PBCGS2' = CMDSOL*6 (PBCGS2, PBCGST, GPBICG, QMRCCG, PETRKP) -- CCG method\n")
    str += (" 'GPFAFT' = CMETHD*6 (GPFAFT, FFTMKL) -- FFT method\n")
    str += (" 'GKDLDR' = CALPHA*6 (GKDLDR, LATTDR, FLTRCD) -- DDA method\n")
    str += (" 'NOTBIN' = CBINFLAG (NOTBIN, ORIBIN, ALLBIN)\n")
    str += (" '**** Initial Memory Allocation ****'\n")
    str += (" %r %r %r = dimensioning allowance for target generation\n" % (mem_allo_x, mem_allo_y, mem_allo_z))
    str += (" '**** Target Geometry and Composition ****'\n")
    str += (" 'FROM_FILE' = CSHAPE*9 shape directive\n")
    str += (" no SHPAR parameters needed\n")
    str += (" 1         = NCOMP = number of dielectric materials\n")
    str += (" '%s' = file with refractive index 1\n" % dc_dir)
    str += (" '**** Additional Nearfield calculation? ****'\n")
    str += (" %r = NRFLD (=0 to skip nearfield calc., =1 to calculate nearfield E, =2 to calculate nearfield E and B)\n" % (int(nearfield)))
    str += (" 0.0 0.0 0.0 0.0 0.0 0.0 (fract. extens. of calc. vol. in -x,+x,-y,+y,-z,+z)\n")
    str += (" '**** Error Tolerance ****'\n")
    str += (" 1.00e-5 = TOL = MAX ALLOWED (NORM OF |G>=AC|E>-ACA|X>)/(NORM OF AC|E>)\n")
    str += (" '**** Maximum number of iterations ****'\n")
    str += (" 2370     = MXITER\n")
    str += (" '**** Integration cutoff parameter for PBC calculations ****'\n")
    str += (" 1.00e-2 = GAMMA (1e-2 is normal, 3e-3 for greater accuracy)\n")
    str += (" '**** Angular resolution for calculation of <cos>, etc. ****'\n")
    str += (" 0.5    = ETASCA (number of angles is proportional to [(3+x)/ETASCA]^2 )\n")
    str += (" '**** Vacuum wavelengths (micron) ****'\n")
    str += (" %r %r 1 'INV' = wavelengths (first,last,how many,how=LIN,INV,LOG)\n" % (float(in_freq), float(in_freq)))
    str += (" '**** Gaussian beam parameters (unit = dipole spacing)'\n")
    str += (" %r  = FLGWAV: Option for wavefront: 0 -- Plane wave; 1 -- Gaussian beam\n" % (int(gaussian)))
    str += (" 0.00, 0.00, 0.00 = xyzc0, center of Gaussian beam waist, unit = dipole spacing\n")
    str += (" %r = w0, Gaussian beam waist, unit = dipole spacing\n" % (float(waist)))
    str += (" '**** Refractive index of ambient medium'\n")
    str += (" %r = NAMBIENT\n" % (float(nambient)))
    str += (" '**** Effective Radii (micron) **** '\n")
    str += (" %r %r 1 'LIN' = eff. radii (first, last, how many, how=LIN,INV,LOG)\n" % (float(effR), float(effR)))
    str += (" '**** Define Incident Polarizations ****'\n")
    if inc_pol == "y":
       str += ( " (0,0) (1.,0.) (0.,0.) = Polarization state e01 (k along x axis)\n")
    elif inc_pol == "z":
       str += ( " (0,0) (0.,0.) (1.,0.) = Polarization state e01 (k along x axis)\n")
    elif inc_pol == 'circ':
        str += ( " (0,0) (1.,0.) (0.,1.) = Polarization state e01 (k along x axis)\n")
    str += (" 1 = IORTH  (=1 to do only pol. state e01; =2 to also do orth. pol. state)\n")
    str += (" '**** Specify which output files to write ****'\n")
    str += (" 0 = IWRKSC (=0 to suppress, =1 to write \".sca\" file for each target orient.\n")
    str += (" '**** Specify Target Rotations ****'\n")
    str += (" 0.    0.   1  = BETAMI, BETAMX, NBETA  (beta=rotation around a1)\n")
    str += (" 0.    0.   1  = THETMI, THETMX, NTHETA (theta=angle between a1 and k)\n")
    str += (" 0.    0.   1  = PHIMIN, PHIMAX, NPHI (phi=rotation angle of a1 around k)\n")
    str += (" '**** Specify first IWAV, IRAD, IORI (normally 0 0 0) ****'\n")
    str += (" 0   0   0    = first IWAV, first IRAD, first IORI (0 0 0 to begin fresh)\n")
    str += (" '**** Select Elements of S_ij Matrix to Print ****'\n")
    str += (" 6       = NSMELTS = number of elements of S_ij to print (not more than 9)\n")
    str += (" 11 12 21 22 31 41       = indices ij of elements to print\n")
    str += (" '**** Specify Scattered Directions ****'\n")
    str += (" 'LFRAME' = CMDFRM (LFRAME, TFRAME for Lab Frame or Target Frame)\n")
    str += ("0 = NPLANES = number of scattering planes\n")
    
    return str

# Generate "var.par" based on "shape_init.dat" 
def generate_var(par, val, shape_init):
    num_k     = val[par.index("num_k")]
    k_out     = val[par.index("k_out")] 
    k_in      = val[par.index("k_in")]
    k_sub     = val[par.index("k_sub")]
    lambda_   = val[par.index("in_freq")]
    n_m       = val[par.index("n_m")]
    P_0       = val[par.index("P_0")]
    unit      = val[par.index("dip_space")]

    # tDDA window
    x = []
    y = []
    z = []
    with open(shape_init) as file:
         data = file.readlines ()
    for line in data:
        line = line.split()
        if len(line) == 7 and '=' not in line:
           x.append(int(line[1]))
           y.append(int(line[2]))
           z.append(int(line[3]))
    window = 2 # since we're not making glycerol shells, no need to extend target
    x_min = min(x) - int(window) / int(unit) 
    x_max = max(x) + int(window) / int(unit) 
    y_min = min(y) - int(window) / int(unit)
    y_max = max(y) + int(window) / int(unit) 
    z_min = min(z) - int(window) / int(unit) 
    z_max = max(z) + int(window) / int(unit) 
    x_plane_max = int( (x_max+x_min) / 2)
    x_plane_min = int( (x_max+x_min)/ 2)
    
    in_freq    = val[par.index("in_freq")]
    dip_space  = val[par.index("dip_space")]
    NA = 1.25
    # waist of pump beam
#    waist = float(in_freq) * 10**3 * 0.6 / (NA) / int(dip_space)
#    waist = float(waist) #    I_0 = float(P_0) / ( math.pi * (waist * int(dip_space) * 10**-9)**2 )*10**-9 #units of nW/m^2, then will get converted to W/m^2 for var.par
    I_0 = float(4.2e+6)

    I_0 = "{:.4E}".format(I_0)

    str =  ("num_k: %r\n" % int(num_k))
    str += ("k_out: %r\n" % float(k_out))
    str += ("k_in: %r\n" % float(k_in))
    str += ("k_sub: %r\n" % float(k_sub))
    str += ("lambda: %r\n" % (float(lambda_)*1e-6))
    str += ("n_m: %r\n" % float(n_m))
    str += ("I_0: %re+9\n" % float(I_0))
    str += ("unit: %r\n\n" % float(unit))
    str += ("d: 1\n")
    str += ("x_min: %r\n" % int(x_min))
    str += ("x_max: %r\n" % int(x_max))
    str += ("y_min: %r\n" % int(y_min))
    str += ("y_max: %r\n" % int(y_max))
    str += ("z_min: %r\n" % int(z_min))
    str += ("z_max: %r\n\n" % int(z_max))
    str += ("x_plane_min: %r\n" % int(x_plane_min))
    str += ("x_plane_max: %r\n" % int(x_plane_max))
    
    return str 


### End program (?) ###
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)
