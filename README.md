# Electron Beam Driven Discrete Dipole Approximation

The following code is a modified verison of Draine's Discrete Dipole Approximation (DDA) code version 7.1. We have modified the code to to allow for an electron beam excitation source. The following code computes the electron energy loss spectroscopy (EELS) and angle-resolved cathodoluminescence (CL) for both aloof and internal geometries. 

## Instructions
### General 
* Delete all executables within source_code by typeing "make clean; make veryclean"
* Compile the fortran code my typing "make all"
* Running this code works nearly the same as DDA 7.1, however the input file, "ddscat.par" now has two new lines indicating the electron beam position and velocity
* See the folder "useful_scripts" in order to run spectra and spectrum images on the cluster.

### Useful Scripts 
#### Make spectrum images 
This folder will launch many scattering calculations to form a 2-D spectrum image by raster scanning the electron beam.
* Replace shape.dat with your shape file. You can use the given shape.f90 file as a template to make your shape if you'd like.
* Update ddscat.par as you would for a normal e-dda calculation, except DO NOT change the electron beam position. It should always read: " 0.0 0.0 0.0 " exactly.
* Launch an interactive node ( type in command line: `srun -p build --time=2:00:00 --mem=100G --pty /bin/bash` )
* Define the extend and raster step size in `create_folders.sh`. Then bash this script.
* Type in the command line:` module load anaconda3_5.3; python makelaunchfiles.py`
* Submit all the jobs by typing in command line: bash submit_jobs.sh

## Citations
If you use e-DDA to compute EELS, we request you cite: https://doi.org/10.1021/nn302980u.

If you use e-DDA to compute CL, we request you additionally cite https://doi.org/10.1021/nn401161n.
