! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Global Data Module File
! 
! Generated by KPP-2.2.3 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 
! File                 : model_Global.f90
! Time                 : Wed Oct 28 11:54:56 2015
! Working directory    : /work/home/mje516/DSMACC_teaching
! Equation file        : model.kpp
! Output root filename : model
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE model_Global

  USE model_Parameters, ONLY: dp, NSPEC, NVAR, NFIX, NREACT
  PUBLIC
  SAVE


! Declaration of global variables

! C - Concentration of all species
  REAL(kind=dp) :: C(NSPEC)
! VAR - Concentrations of variable species (global)
  REAL(kind=dp) :: VAR(NVAR)
! FIX - Concentrations of fixed species (global)
  REAL(kind=dp) :: FIX(NFIX)
! VAR, FIX are chunks of array C
      EQUIVALENCE( C(1),VAR(1) )
! RCONST - Rate constants (global)
  REAL(kind=dp) :: RCONST(NREACT)
! TIME - Current integration time
  REAL(kind=dp) :: TIME
! SUN - Sunlight intensity between [0,1]
  REAL(kind=dp) :: SUN
! TEMP - Temperature
  REAL(kind=dp) :: TEMP
! RTOLS - (scalar) Relative tolerance
  REAL(kind=dp) :: RTOLS
! TSTART - Integration start time
  REAL(kind=dp) :: TSTART
! TEND - Integration end time
  REAL(kind=dp) :: TEND
! DT - Integration step
  REAL(kind=dp) :: DT
! ATOL - Absolute tolerance
  REAL(kind=dp) :: ATOL(NVAR)
! RTOL - Relative tolerance
  REAL(kind=dp) :: RTOL(NVAR)
! STEPMIN - Lower bound for integration step
  REAL(kind=dp) :: STEPMIN
! STEPMAX - Upper bound for integration step
  REAL(kind=dp) :: STEPMAX
! CFACTOR - Conversion factor for concentration units
  REAL(kind=dp) :: CFACTOR

! INLINED global variable declarations
 
 REAL(dp)::M, N2, O2, RO2, H2O 
 
  REAL(dp) :: PRESS, LAT, LON, O3COL, JO1D, JNO2
  REAL(dp) :: JDAY, JREPEAT, ALBEDO, SAREA, RP1
  REAL(dp) :: BLH, DEPVEL
  INTEGER :: INIT_TIME, NOX(NVAR)
  REAL(dp):: CONSTRAIN(NVAR)
  LOGICAL :: SPEC_CH4, SPEC_H2
  INTEGER :: IntTime
  LOGICAL :: CONSTRAIN_NOX
  LOGICAL :: CONSTRAIN_RUN, LAST_POINT, OUTPUT_LAST
  CHARACTER(LEN=15) :: spec_name(10000)
  INTEGER :: const_method(10000), LINECOUNT
!Photolysis variables
  include 'params'
  REAL*8::bs(19,kj), cs(19,kj),ds(19,kj)
  REAL::svj_tj(kt,kj), szas(kt), jfactno2, jfacto1d
!End photolysis variables

! INLINED global variable declarations


END MODULE model_Global

