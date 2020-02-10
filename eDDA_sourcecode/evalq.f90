!*************************Alex Vaschillo and Nicholas Bigelow 2012*************************  
!Modified to output the parameter Gamma as described in:
!"Optical Excitations in electron microscopy", Rev. Mod. Phys. v. 82 p. 234 equation (46)
!using the original code for extinction. Normalized to units of /per eV
    SUBROUTINE EVALQ(CXADIA,CXAOFF,NAT3,CXE,CXP,CABS,CEXT,CPHA,IMETHD,MXN3,h_bar,h_bar2,MXRAD,AEFFA, &
                     NAT0,c,MXWAV,WAVEA)
     !All arguments h_bar and after added, some arguments removed by NWB 7/11/12
      USE DDPRECISION,ONLY: WP
      IMPLICIT NONE

!*** Arguments:
      INTEGER :: IMETHD, MXN3, NAT3, NAT0, MXRAD, MXWAV
      REAL(WP) :: CABS, CEXT, CPHA, h_bar, h_bar2, AEFFA(MXRAD), AK(3), &
                  c, WAVEA(MXWAV)
      COMPLEX(WP) :: CXE(MXN3), CXP(MXN3), CXADIA(MXN3), CXAOFF(MXN3)

!*** Local variables:
      COMPLEX(WP) :: CXA, CXI, DCXA, RABS, POL(3)
      REAL(WP) :: PI, DS, omega
      INTEGER :: J1, J2, J3, NAT

!*** Intrinsic functions:
      INTRINSIC AIMAG, CONJG, REAL, SQRT

!*** SAVE statements:
      SAVE CXI

!*** Data statements:
      DATA CXI/(0._WP,1._WP)/

!***********************************************************************

! Given: NAT3 = 3*number of dipoles
!        CXADIA(J,1-3)=(a_11,a_22,a_33) for dipoles J=1-NAT,
!                  where symmetric 3x3 matrix a_ij is inverse of complex
!                  polarizability tensor alpha_ij for dipole J
!        CXAOFF(J,1-3)=(a_23,a_31,a_12) for dipoles J=1-NAT
!        CXE(1-NAT3) = components of E field at each dipole, in order
!                      E_1x,E_2x,...,E_NATx,E_1y,E_2y,...,E_NATy,
!                      E_1z,E_2z,...,E_NATz
!        CXP(1-NAT3) = components of polarization vector at each dipole,
!                      in order
!                      P_1x,P_2x,...,P_NATx,P_1y,P_2y,...,P_NATy,
!                      P_1z,P_2z,...,P_NATz
!        IMETHD = 0 or 1
! Finds:
!        CEXT = loss probability, Gamma, in units of eV^-1
!  and, if IMETHD=1, also computes
!        CPHA = 0
!        CABS = 0
!Inputs and outputs updated by NWB, 7/11/12

! B.T.Draine, Princeton Univ. Obs., 87/1/4

! History:
! 88.04.28 (BTD): modifications
! 90.11.02 (BTD): modified to allow use of vacuum sites (now pass E02
!                 from calling routine instead of evaluating it here)
! 90.12.13 (BTD): modified to use IMETHD flag, to allow "fast" calls
!                 in which only CEXT is computed.
! 97.12.26 (BTD): removed CXALPH from argument list; replaced with
!                 CXADIA and CXAOFF.
!                 CXADIA and CXAOFF are diagonal and off-diagonal
!                 elements of alpha^{-1} for each dipole.
!                 Modified to properly evaluate CABS
! 98.01.01 (BTD): Correct inconsistencies in assumed data ordering.
! 98.01.13 (BTD): Examine for possible error in evaluation of Qabs
! 98.04.27 (BTD): Minor polishing.
! 08.01.13 (BTD): cosmetic changes to f90 version
! End history

! Copyright (C) 1993,1997,1998,2008 B.T. Draine and P.J. Flatau
! This code is covered by the GNU General Public License.
!***********************************************************************

      !Zero out variables and define internal constants
      CEXT = 0._WP
      CABS = 0._WP
      CPHA = 0._WP
      CXA = 0._WP
      PI = 4._WP * ATAN(1._WP) !Pi

!*** Compute dipole spacing in meters
      !DS = 1E-6_WP * AEFFA(1) * (4._WP * PI / (3._WP * NAT0) )**(1._WP/3._WP)
      !ZH, compute dipole spacing in centimeters
      DS = 1E-4_WP * AEFFA(1) * (4._WP * PI / (3._WP * NAT0) )**(1._WP/3._WP)

      IF ( IMETHD==0 ) THEN

         !*** Compute CEXT:
         DO J1=1,NAT3
            CEXT = CEXT + AIMAG(CXP(J1)) * REAL(CXE(J1)) - &
            REAL(CXP(J1)) * AIMAG(CXE(J1)) !ORIGINAL CODE, Eapp* dot P
         ENDDO
         
         !Compute Gamma using CEXT NWB 7/11/12
         !CEXT = CEXT * ((PI * h_bar * h_bar2) ** (-1._WP)) * 1.E-18_WP !(10^6)^3 correction factor for um/m  
         CEXT = CEXT * ((PI * h_bar * h_bar2) ** (-1._WP)) 

         !Renormalize for dipole spacing
         !CEXT = CEXT * (DS * 1.E9_WP)**3._WP
         !CEXT = CEXT * DS**3._WP 
         ! ZH, this conversion is needed for unit correction
         CEXT = CEXT / DS

      ELSEIF (IMETHD == 1) THEN

         ! Compute CABS 
         ! C_abs=(4*pi*k/|E_0|^2)*
         !       sum_J { Im[P_J*conjg(a_J*P_J)] - (2/3)*k^3*|P_J|^2 }
         !      =(4*pi*k/|E_0|^2)*
         !       sum_J {-Im[conjg(P_J)*a_J*P_J] - Im[i*(2/3)*k^3*P_J*conjg(P_J)]}
         !      =-(4*pi*k/|E_0|^2)*
         !       Im{ sum_J [ conjg(P_J)*(a_J*P_J + i*(2/3)*k^3*P_J) ] }

         NAT = NAT3 / 3
         CXA = (0._WP, 0._WP)
         omega = 2._WP * PI * c / (WAVEA(1) * 1E-4_WP)
         RABS = CXI * 2._WP * (omega**3._WP) / (3._WP * (c**3._WP))
         DO J1=1,NAT
            J2=J1+NAT
            J3=J2+NAT
            DCXA=CONJG(CXP(J1))*((CXADIA(J1)+RABS*(DS**3._WP))*CXP(J1)+   &
                                 CXAOFF(J2)*CXP(J3)+CXAOFF(J3)*CXP(J2))+  &
                 CONJG(CXP(J2))*((CXADIA(J2)+RABS*(DS**3._WP))*CXP(J2)+   &
                                 CXAOFF(J3)*CXP(J1)+CXAOFF(J1)*CXP(J3))+  &
                 CONJG(CXP(J3))*((CXADIA(J3)+RABS*(DS**3._WP))*CXP(J3)+   &
                                 CXAOFF(J1)*CXP(J2)+CXAOFF(J2)*CXP(J1))
            CXA=CXA+DCXA
         ENDDO
         CABS = -AIMAG(CXA) * ((PI * h_bar * h_bar2) ** (-1._WP))
         CABS = CABS / DS
         PRINT *,'CABS in EVALQ = ',CABS

         ! Compute CEXT (EELS) 
         CXA = (0._WP, 0._WP)
         DO J1 = 1, NAT3
            CXA = CXA + CXP(J1) * CONJG(CXE(J1))
         ENDDO
         CEXT = AIMAG(CXA) * ((PI * h_bar * h_bar2) ** (-1._WP)) 
         CEXT = CEXT / DS

         ! Compute CSCA (CL)
         CABS = CEXT - CABS
      ENDIF
      RETURN
    END SUBROUTINE EVALQ
