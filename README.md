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
* Make the conventional `shape.dat` file.
* Update all parameters in `ddscat.par`, however do not change line 9, the position of the electron beam. 
* The computation is organized to group all y slices (z = constant, y = varying) under one job listing. The `launch.slurm` file defines the y bounds and step size in units of lattice spacing. Do not change line 21, this gets updated in `launch_full.sh`.
* Lastly, update the z bounds and step size in `launch_full.sh`.
* To run the many calculations, type `bash launch_full.sh`.

## Citations
If you use e-DDA to compute EELS, we request you cite: https://doi.org/10.1021/nn302980u.

If you use e-DDA to compute CL, we request you additionally cite https://doi.org/10.1021/nn401161n.
