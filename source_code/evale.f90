!*************************Alex Vaschillo and Nicholas Bigelow 2012*************************
!Incorporated code that models a fast electron's interaction with a group of dipoles as in 
!"Optical Excitations in electron microscopy", Rev. Mod. Phys. v. 82 p. 213 equations (4) and (5)
    SUBROUTINE EVALE(CXE00,AKD,DX,X0,IXYZ0,MXNAT,MXN3,NAT,NAT0,NX,NY,NZ,CXE,AEFFA, &
                     WAVEA,MXRAD,MXWAV,Center,c,velocity,      &
                     e_charge,DielectricConst,XLR,YLR,ZLR,RM)
      !Arguments AEFFA and after added by NWB 3/8/12
      !CenterX0 added by SMC 14.5.13
      !XLR, YLR, ZLR, CenterX0R added by SMC 15.5.13
      USE DDPRECISION,ONLY : WP
      IMPLICIT NONE

!*** Arguments:
      INTEGER :: MXN3, MXNAT, NAT, NAT0, NX, NY, NZ, MXRAD, MXWAV
      !MXRAD, MXWAV added by NWB 3/8/12
      INTEGER :: IXYZ0(NAT0,3)
      REAL(WP) :: AKD(3), DX(3), X0(3), AEFFA(MXRAD), WAVEA(MXWAV), Center(3), CenterX0(3), &
                  CenterX0R(3), XLR(3), YLR(3), ZLR(3), RM(3,3)
         !AEFFA and after added by NWB 3/8/12
         !CenterX0 added by SMC 14.5.13
         !CenterX0R, XLR, YLR, ZLR added by SMC 15.5.13

! Note: CXE should be dimensioned to CXE(NAT,3) in this routine
!       so that first 3*NAT elements of CXE are employed.
!       XYZ0 should be dimensioned to
      COMPLEX(WP) :: CXE(NAT,3), CXE00(3)

!***  Local variables:
      COMPLEX(WP) :: CXFAC, CXI, CXE_temp(3)
      REAL(WP) :: X, X1, X2, DVEC(3), R, XP, YP, ZP !, CenterX0(3) !Edited out SMC, !DIST added by SMC 15.5.13
      INTEGER :: IA, IX, IY, IZ, M, JJ

!*** Variables added by Alex Vaschillo:
      REAL(WP) :: c, e_charge, EFieldConstant, omega, gamma, k_mag, DS, PI, &
                  BesselArg, DielectricConst, velocity
      REAL(WP) :: Radius, XPe, YPe, ZPe !This serves the exact same purpose as the array R() but is used in a different scope (only in the else statement, see below)
!Added XPe, YPe, ZPe for else statement SMC 15.5.13
      REAL(WP) :: besselk0, besselk1 !Values of Bessel functions K0 and K1
      REAL(WP) :: besseli1, besseli0 !Values of Bessel functions I0 and I0, necessary for K0 and K1 routines
      INTEGER :: i !For indexing do loops

!*** Intrinsic functions and constants:
      INTRINSIC EXP, REAL
      INTRINSIC ATAN2, DCOS, DSIN, AIMAG, DOT_PRODUCT
      PI = 4._WP*ATAN(1._WP)          !Pi


!***********************************************************************
! subroutine EVALE

! Given:   CXE00(1-3)=Incident E field at origin (complex) at t=0
!          AKD(1-3)=(kx,ky,kz)*d for incident wave (d=effective
!                    lattice spacing)
!          DX(1-3)=(dx/d,dy/d,dz/d) for lattice (dx,dy,dz=lattice
!                   spacings in x,y,z directions, d=(dx*dy*dz)**(1/3)
!          X0(1-3)=(x,y,z)location/(d*DX(1-3)) in TF of lattice site
!                  with IX=0,IY=0,IZ=0
!          IXYZ0(1-NAT0,3)=[x-x0(1)]/dx, [y-x0(2)]/dy, [z-x0(3)]/dz
!                  for each of NAT0 physical dipoles
!          MXNAT,MXN3=dimensioning information
!          NAT0=number of dipoles in physical target
!          NAT=number of locations at which to calculate CXE

! Returns: CXE(1-NAT,3)=incident E field at NAT locations at t=0

! B.T.Draine, Princeton Univ. Obs., 88.05.09
! History:
! 90.11.06 (BTD): Modified to pass array dimension.
! 90.11.29 (BTD): Modified to allow option for either
!                   physical locations only (NAT=NAT0), or
!                   extended dipole array (NAT>NAT0)
! 90.11.30 (BTD): Corrected error for case NAT>NAT0
! 90.11.30 (BTD): Corrected another error for case NAT>NAT0
! 90.12.03 (BTD): Change ordering of XYZ0 and CXE
! 90.12.05 (BTD): Corrected error in dimensioning of CXE
! 90.12.10 (BTD): Remove XYZ0, replace with IXYZ0
! 97.11.02 (BTD): Add DX to argument list to allow use with
!                 noncubic lattices.
! 07.06.20 (BTD): Add X0 to the argument list to specify location
!                 in TF corresponding to IX=0,IY=0,IZ=0
! 07.09.11 (BTD): Changed IXYZ0 from INTEGER*2 to INTEGER
! 08.03.14 (BTD): v7.05
!                 corrected dimensioning
!                 IXYZ0(MXNAT,3) -> IXYZO(NAT0,3)
! Copyright (C) 1993,1997,2007 B.T. Draine and P.J. Flatau
! This code is covered by the GNU General Public License.
!***********************************************************************

      CXI=(0._WP,1._WP)

! Evaluate electric field vector at each dipole location.

! If NAT=NAT0, then evaluate E only at occupied sites.
! If NAT>NAT0, then evaluate E at all sites.


!*** Compute dipole spacing in meters
      !DS = 1E-6_WP * AEFFA(1) * (4._WP * PI / (3._WP * NAT0) )**(1._WP/3._WP)
      ! ZH, compute dipole spacing in centimeters
      DS = 1E-4_WP * AEFFA(1) * (4._WP * PI / (3._WP * NAT0) )**(1._WP/3._WP)

!*** Compute omega
      !omega = 2._WP * PI * c / (WAVEA(1) * 1E-6_WP) !Conversion from microns to meters
      omega = 2._WP * PI * c / (WAVEA(1) * 1E-4_WP) !ZH, Conversion from microns to centimeters

!*** Calculate EFieldConstant - the constant that g(r) is multiplied by
      gamma = (1._WP - DielectricConst * (velocity / c) ** 2._WP) ** (-0.5_WP)
      EFieldConstant = 2._WP * e_charge * omega / (velocity ** 2._WP * gamma &
                       * DielectricConst)

!*** ZH, Convert statC-s/cm^2 to statc-s-DS^2 
      EFieldConstant = EFieldConstant * DS**2._WP 
       
      CALL PROD3(RM,Center,CenterX0)
      !CenterX0R(:) = CenterX0(:) - X0(:)
      ! Z. Hu, make it work correctly for DX(3)
      CenterX0R(:) = CenterX0(:) - X0(:) * DX(:)

      PRINT *, 'CenterX0R', CenterX0R
      PRINT *, 'X0', X0
      PRINT *, 'CenterX0', CenterX0
      PRINT *, 'Relative coordinates of beam:', Center !Spelling correction SMC 8.5.13
      PRINT *, 'Target rotated coordinates of beam:', CenterX0R!Diagnostic added by SMC 14.5.13
      PRINT *, 'Rotated coordinates of beam:' , CenterX0 !Diagnostic added by SMC 15.5.13
      PRINT *, 'Target lattice offset:', X0 !Diagnostic added by SMC 14.5.13
      PRINT *, 'Electron speed:', velocity
      PRINT *, 'XLR:', XLR !Diagnostic added by SMC 15.5.13
      PRINT *, 'YLR:', YLR
      PRINT *, 'ZLR:', ZLR
      PRINT *, 'RM:', RM
      PRINT *, 'AEFFA:', AEFFA(1)
      PRINT *, 'NAT0:', NAT0
      PRINT *, 'WAVEA:', WAVEA(1)
      PRINT *, 'DS:', DS
      PRINT *, 'omega:', omega
      PRINT *, 'gamma:', gamma
      PRINT *, 'EFieldConstant', EFieldConstant
IF (NAT == NAT0) THEN
   !*** Calculate radius and prevent divide by zero errors
   DO i = 1, NAT0
      !DVEC(1) = IXYZ0(i, 1) - CenterX0R(1)
      !DVEC(2) = IXYZ0(i, 2) - CenterX0R(2)
      !DVEC(3) = IXYZ0(i, 3) - CenterX0R(3)
      ! Z. Hu, make it work correctly for DX(3)
      DVEC(1) = IXYZ0(i, 1) * DX(1) - CenterX0R(1)
      DVEC(2) = IXYZ0(i, 2) * DX(2) - CenterX0R(2)
      DVEC(3) = IXYZ0(i, 3) * DX(3) - CenterX0R(3)
      PRINT *, 'DVEC: ', DVEC
      XP = DOT_PRODUCT(DVEC,XLR)
      YP = DOT_PRODUCT(DVEC,YLR)
      ZP = DOT_PRODUCT(DVEC,ZLR)
!            PRINT *, 'x: ', XP
!            PRINT *, 'y: ', YP
!            PRINT *, 'z: ', ZP
      R = (ZP ** 2._WP) + (YP ** 2._WP)
!            PRINT *, 'R: ', SQRT(R)
!            PRINT *, 'x: ', IXYZ0(i,1)
!            PRINT *, 'y: ', IXYZ0(i,2)
!            PRINT *, 'z: ', IXYZ0(i,3)
      R = SQRT(R) * DS

      IF (R .LE. 1._WP*DS) THEN !If the radius is zero, set to a small, but finite distance
         R = DS
         PRINT *, 'WARNING: RADIUS <= DS! Re-set to DS!'
         PRINT *, 'IX, IY, IZ:', IX, IY, IZ
      END IF
     
      !*** Calculate g(r)
      BesselArg = omega * R / (velocity * gamma) !The argument of the Bessel functions
      CXE_temp(3) = EXP(CXI * omega * DS * (XP) / velocity)
      
      !*** Calculate electric field components at point i
      CXE_temp(1) = EFieldConstant * CXE_temp(3) * (CXI * besselk0(BesselArg) &
           / gamma)
      CXE_temp(2) = EFieldConstant * CXE_temp(3) * (-1._WP * besselk1(BesselArg)) * &
           DSIN(ATAN2((DBLE(YP)) , (DBLE(ZP))))
      CXE_temp(3) = EFieldConstant * CXE_temp(3) * (-1._WP * besselk1(BesselArg)) * &
           DCOS(ATAN2((DBLE(YP)) , (DBLE(ZP))))
      !Modified 15.5.13 by SMC
      CALL PROD3C(RM,CXE_temp,CXE(i,:))
      !IF (i .EQ. 5) THEN
      !PRINT *, 'Before rotation:'
      !PRINT *, 'Ex: ', CXE_temp(1)
      !PRINT *, 'Ey: ', CXE_temp(2)
      !PRINT *, 'Ez: ', CXE_temp(3)
      !PRINT *, 'After rotation:'
      !PRINT *, 'Ex: ', CXE(i,1)
      !PRINT *, 'Ey: ', CXE(i,2)
      !PRINT *, 'Ez: ', CXE(i,3)
      CXE_temp(1) = SQRT( (CXE_temp(1) ** 2._WP) + (CXE_temp(2) ** 2._WP) + (CXE_temp(3) ** 2._WP))
      !PRINT *, 'Magnitude: ', CXE_temp(1)
            !END IF

   END DO
ELSE
   IA=0 !Index that labels each unique point at which the field is calculated
   DO IZ=1,NZ
      DO IY=1,NY
         DO IX=1,NX
            
            IA = IA + 1 !Advance IA
            
            !*** Calculate Radius and prevent divide by zero errors
            !DVEC(1) = IX - CenterX0R(1)
            !DVEC(2) = IY- CenterX0R(2)
            !DVEC(3) = IZ - CenterX0R(3)
            ! Z. Hu, make it work correctly for DX(3)
            DVEC(1) = IX * DX(1) - CenterX0R(1)
            DVEC(2) = IY * DX(2) - CenterX0R(2)
            DVEC(3) = IZ * DX(3) - CenterX0R(3)
            
            XPe = DOT_PRODUCT(DVEC,XLR)
            YPe = DOT_PRODUCT(DVEC,YLR)
            ZPe = DOT_PRODUCT(DVEC,ZLR)
            Radius = (ZPe) ** 2._WP + &
                 (YPe) ** 2._WP
            Radius = SQRT(Radius) * DS
            !IF (IA == 1) THEN                       !Diagnostic
               !PRINT *, 'Rad(1) NEW:', Radius
               !PRINT *, 'XPe:', XPe
               !PRINT *, 'Check:', DVEC(1)
               !PRINT *, 'YPe:', YPe
               !PRINT *, 'Check:', DVEC(2)
               !PRINT *, 'ZPe:', ZPe
               !PRINT *, 'Check:', DVEC(3)
            !ENDIF
            IF (Radius .LE. 1._WP*DS) THEN !If the radius is zero, set to a small, but finite distance
               Radius = DS
               PRINT *, 'WARNING: RADIUS <= DS! Re-set to DS!'
               PRINT *, 'IX, IY, IZ:', IX, IY, IZ
            END IF
            
            !*** Calculate g(r)
            BesselArg = omega * Radius / (velocity * gamma) !The argument of the Bessel functions
            CXE_temp(3) = EXP(CXI * omega * DS * (XPe) / velocity)
            ! ZH: test the code
            IF (IA == 1) THEN
               PRINT *, 'Rad(1) NEW:', Radius
               PRINT *, 'XPe:', XPe
               PRINT *, 'YPe:', YPe
               PRINT *, 'ZPe:', ZPe
               PRINT *, 'BesselArg', BesselArg
               PRINT *, 'CXE_temp(3)', CXE_temp(3)
            END IF
                                  
            !*** Calculate electric field components at point IA
            CXE_temp(1) = EFieldConstant * CXE_temp(3) * (CXI * besselk0(BesselArg) &
                 / gamma)
            CXE_temp(2) = EFieldConstant * CXE_temp(3) * (-1._WP * besselk1(BesselArg)) * &
                 DSIN(ATAN2((DBLE(YPe)) , (DBLE(ZPe))))
            CXE_temp(3) = EFieldConstant * CXE_temp(3) * (-1._WP * besselk1(BesselArg)) * &
                 DCOS(ATAN2((DBLE(YPe)) , (DBLE((ZPe)))))

            ! ZH: test the code
            IF (IA == 1) THEN
               PRINT *, 'CXE_temp(1)', CXE_temp(1)
               PRINT *, 'CXE_temp(2)', CXE_temp(2)
               PRINT *, 'CXE_temp(3)', CXE_temp(3)
            END IF
                  
            CALL PROD3C(RM,CXE_temp,CXE(IA,:))
         END DO
      END DO
   END DO
   
   PRINT *, "IA is: ", IA
ENDIF

RETURN
END SUBROUTINE EVALE

