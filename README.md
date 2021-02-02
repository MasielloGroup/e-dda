# Electron Beam Driven Discrete Dipole Approximation

The following code is a modified verison of Draine's Discrete Dipole Approximation (DDA) code version 7.1. We have modified the code to to allow for an electron beam excitation source. The following code computes the electron energy loss spectroscopy (EELS) and angle-resolved cathodoluminescence (CL) for both aloof and internal geometries. 

## Instructions
# General 
* Delete all executables within source_code by typeing "make clean; make veryclean"
* Compile the fortran code my typing "make all"
* Running this code works nearly the same as DDA 7.1, however the input file, "ddscat.par" now has two new lines indicating the electron beam position and velocity
* See the folder "useful_scripts" in order to run spectra and spectrum images on the cluster.


## Citations
If you use e-DDA to compute EELS, we request you cite: https://doi.org/10.1021/nn302980u.

If you use e-DDA to compute CL, we request you additionally cite https://doi.org/10.1021/nn401161n.
