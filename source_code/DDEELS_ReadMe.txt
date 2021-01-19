A USERS' GUIDE TO DDEELS
NWB and AV 2012


INTRODUCTION

The copy of the DDA source code in this directory has been modified to simulate Electron
Energy Loss Spectroscopy (EELS) experiments. In this context, the code is called 
'DDEELS', after the nomenclature of Geuquet and Henrard, 2010.

The code supplants the incident plane-wave Electric field in the original code with that
of a fast-moving electron. The form of the new E-field can be found on page 213 of the
EELS review by De Abajo, 2010. Computed values include the electric field and the energy
loss probability, Gamma (in progress). Currently, all electron paths are along the z-axis.

At present, the B-field calculations are unmodified and presumed to be non-functional.


USING THE DDEELS CODE:

Setup:
The parfile is similar the original DDA, with the only difference being the addition
of the x, y, z center of the e-beam. This number is input just below the
dimensioning allowances in 'ddscat.par'. The wavevector k no longer plays a role, so 
the polarization line is now functionless. All other parameters are unchanged.

The shape file input is unmodified from the original DDA code.

Instructions on how to use the original DDA code can be found in the users' guide,
located at:

http://arXiv.org/abs/1202.3424

The relevent EELS parameters are:

-- electron speed
-- electron path centroid in x, y (in eelsfield only)
-- dipole spacing (in eelsfield only)

The electron speed is hard coded and must be changed by editing the relevant fortran codes
and recompiling the program. The second two are hard coded in eelsfield, but are passed in
via the .par file for ddeels.

For electron speed:
in DDFIELD.f90 change the variable 'velocity'. It is currently written in units of the speed of
light (in m/s), c.

For electron path:
in DDFIELD.f90 change the variable 'Center'. Center is a vector and has x, y, z components, in 
units of the dipole spacing. Note that in EVALE.f90 only, center has a 'recentering' variable 
'X0' after the user-defined centroid. Do not change or remove X0.

For dipole spacing:
in DDFIELD.f90, modify the variable DS (in units of meters).

After the variables are properly set, the code (both ddeels and eelsfield) must be recompiled.
The code is now ready to run.

Compiling the code is accomplished by typing "make ddeels" and "make eelsfield" into the 
command line while in the directory "src".


MODIFICATIONS

Modified files:

DDSCAT.f90
Outer program for ddeels. Modified to write out 'Gamma' instead of 'Q_ext' to the
'qtable' file, in the 'formatting' section of the code.

EVALE.f90:
Computes the incident E-field for ddeels. The original plane-wave excitation has been
commented out and a new fast-electron field has been written in, both for field points at
the dipoles and not at the dipoles. Variables to accomplish this have been added to the
top of the file and a large number of print statements for debugging have been added.
Four variables not previously used in evale AEFFA, WAVEA, MXRAD, and MXWAV, (the 
effective radii, the wavelengths, and their sizing data), have been added. Should the
e-beam center fall on a field evaluation point, the radius is shifted slightly there to
avoid a singularity. Evale is called by getfml.

DDFIELD.f90
Computes the field at selected locations by adding the contribution from all the 
polarizations calculated in ddeels to an analytical solution for the incident field.
The current version of ddfield calculates only the scattered field. Incident field code
is commented out and must be commented in for total field calculations. Further, the
code that sets CXE to zero must be commented out. Modifications are similar to EVALE.f90.
A new analytical solution for the incident field using a fast-electron E-field has been
added. New variables are defined in the header. No new variables are imported. Several
new print statements are added.

GETFML.f90
Computes scattering properties for ddeels. Calls evale and evalq. Calls to evale
have been modified to include the new input variables, which have also been added to
getfml's argument list. Normalization of QEXT is removed such that QEXT reported is
now only CEXT.

EVALQ.f90
Computes scattering and absorbance. Extinction cross-section, CEXT, has been modified
to be the electron loss probability, Gamma, as described on pgs. 214 and 233 of De Abajo,
2010 and pg. 1076 of Geuquet and Henrard, 2010. This is modified in several places where
CEXT is calculated. A new variable for h-bar has been added. No new variables are
imported to the file. Called by getfml.

DDSCAT.f90
Outer program for ddeels. Calls GETFML. No new variables are computed, but previously
existing variables have been added to the function call for getfml.

MAKEFILE
The makefile has been modified to build DDSCAT.f90 and dependencies as "ddeels" and 
DDFIELD.f90 and dependencies as "eelsfield".


PROCESS TREE

             DDSCAT.f90                   DDFIELDf90
	         |                            |
		 |                            |
	     GETFML.f90                  electron speed,
	      |     |                    e-beam center,
	      |     |                    dipole spacing,
	EVALE.f90  EVALQ.f90        incident or total field
	   |
	   |
     electron speed,
     e-beam center


BIBLIOGRAPHY

De Abajo, F. J. G. "Optical Excitations in Electron Microscopy".
Rev. Mod. Phys. Vol. 82, 2010.

Geuquet, N and Henrard, L. "EELS and Optical Response of a Noble Metal Nanoparticle
in the Frame of a Discrete Dipole Approximation".
Ultramicroscopy, 110, 2010.

Draine, B. T. and Flatau, P. J. "Discrete dipole approximation for scattering calculations".
J. Opt. Soc. Am. A, 11, 1994.

Draine, B. T. and Flatau, P. J. "User Guide to the Discrete Dipole Approximation Code DDCAT 7.2".
http://arXiv.org/abs/1202.3424
