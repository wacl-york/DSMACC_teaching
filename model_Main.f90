! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Main Program File
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
! File                 : model_Main.f90
! Time                 : Wed Oct 28 11:54:56 2015
! Working directory    : /work/home/mje516/DSMACC_teaching
! Equation file        : model.kpp
! Output root filename : model
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! MAIN - Main program - driver routine
!   Arguments :
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Main Program File
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
! File                 : model_Main.f90
! Time                 : Mon Aug 31 12:06:07 2015
! Working directory    : /raid/user/home/mje516/DSMACC_teaching
! Equation file        : model.kpp
! Output root filename : model
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! MAIN - Main program - driver routine
!   Arguments :
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Main Program File
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
! File                 : model_Main.f90
! Time                 : Mon Aug 31 10:45:11 2015
! Working directory    : /raid/user/home/mje516/DSMACC_teaching
! Equation file        : model.kpp
! Output root filename : model
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! MAIN - Main program - driver routine
!   Arguments :
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROGRAM driver

  USE model_global
  USE model_Parameters  !ONLY: IND_*
  USE model_Rates,       ONLY: Update_SUN, Update_RCONST
  USE model_integrator,  ONLY: integrate!, IERR_NAMES
  USE model_monitor,     ONLY: spc_names
  USE model_Init
  USE model_Util
  USE constants

  IMPLICIT NONE
  REAL(dp) :: ENDSTATE(NVAR), total, RATIO, TNOX, TNOX_OLD
  REAL(dp) :: STARTSTATE(NVAR), TIMESCALE
  REAL(dp) :: RH
  REAL(dp) :: RSTATE(20)
  REAL(dp) :: DIURNAL_OLD(NVAR,3000), DIURNAL_NEW(NVAR,3000)
  REAL(dp) :: DIURNAL_RATES(NREACT, 3000)
  INTEGER  :: ERROR, IJ, PE
  LOGICAL :: SCREWED
  REAL(dp) :: FULL_CONCS(NVAR,999999)

! Photolysis calculation variables
  REAL(dp) :: Alta

  Integer  :: Daycounter, CONSTNOXSPEC, JK,counter, full_counter

  REAL(dp) :: NOXRATIO, NEW_TIME
  REAL(dp) :: Fracdiff, SpeedRatio, oldfracdiff, FRACCOUNT
 
  character(len=50) :: input_file, output_file

  call get_command_argument(1,input_file)
  call get_command_argument(2,output_file)

  write (6,*) 'Input file:', input_file
  write (6,*) 'Ouput file:', output_file
  STEPMIN = 0.0_dp
  STEPMAX = 0.0_dp
  RTOL(:) = 1.0e-7_dp
  ATOL(:) = 1.0_dp
  counter=0
  LAST_POINT=.FALSE.
 

!  IF YOU WANT TO CONSTRAIN THE NOX THEN
   CONSTRAIN_NOX=.FALSE.

   CALL INITVAL(0,input_file)
!This is the loop of different points in the Init_cons.dat file. Number of model simulation = Linecount-3

   do counter=1,LINECOUNT-3
      WRITE (6,*) 'Reading in point', counter
! Set up the output file for the new point
      CALL NEWINITSAVEDATA(counter, output_file)
! Read in the next initial conditions
      CALL InitVal(counter, input_file)

      M   = CFACTOR
      O2 = 0.21 * CFACTOR
      N2 = 0.78 * CFACTOR
      
      write (6,*) 'Starting Jday:',jday

! tstart is the starting time, variations due to day of year are dealt with somewhere else 
      tstart = (mod(jday,1.))*24.*60.*60.              ! time start

! convert tstart to local time
      tstart = tstart+LON/360.*24*60*60.

! tend is the end time. IntTime is determined from the Init_cons.dat file
      tend = tstart + IntTime    

!dt is the output timestep and the timestep between times rate constants and notably photolysis rates are calcualted
      dt = 600.                       

      write (6,*) 'Starting time:',tstart
      write (6,*) 'Ending time:', tend
      write (6,*) 'Time step:', dt
      
      !    Set up the photolysis rates
      !    First calculate pressure altitude from altitude
      WRITE (6,*) 'hvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhv'
      WRITE (6,*) 'Using TUV to calculate photolysis rates as a function of SZA'
      alta=(1-(press/1013.25)**0.190263)*288.15/0.00198122*0.304800/1000.
      write (6,*) 'Aerosol surface area', SAREA
      write (6,*) 'Aerosol particle radius 1', RP1
      write (6,*) 'Altitude =', alta
      write (6,*) 'Pressure =', Press
      write (6,*) 'Temperature =', Temp
      write (6,*) 'Latitude =', Lat
      write (6,*) 'Lon =', Lon
      write (6,*) 'Local Time =', Tstart/(60.*60.)
      write (6,*) 'SZA =',ZENANG(int(jday),Tstart/(60.*60.),lat)*180./(4*ATAN(1.))
      if (o3col .eq. 0) then 
         o3col=260.
         write (6,*) 'Ozone column not specified using 260 Dobsons'
      else
         write (6,*) 'Ozone column =', o3col
      endif
      
      if (albedo .eq. 0) then 
         albedo=0.1
         write (6,*) 'Albedo not specified using 0.1'
      else
         write (6,*) 'Albedo =', albedo
      endif
      !    Calculate the photolysis rates for the run

      IF (JREPEAT .EQ. 0 .OR. COUNTER .EQ. 1) THEN 
         call set_up_photol(O3col,Albedo, alta, temp, bs,cs,ds,szas,svj_tj)
      ELSE
         WRITE (6,*) 'Using previously calculated photolysis params'
      ENDIF
      
      WRITE (6,*) 'Photolysis rates calculated'
      WRITE (6,*) 'hvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhv'
      time = tstart
      
! Define the initial state of the model 
      DO I=1,NVAR
         STARTSTATE(I)=C(I)
         DO IJ=1,3000
            DIURNAL_OLD(I,IJ)=0.
         ENDDO
      ENDDO
      
! Calculate clear sky photolysis rates
      JFACTNO2=1.
      JFACTO1D=1.
      
! Update the rate constants
      CALL Update_RCONST()

      WRITE (6,*) 'JO1D Calc=', J(1)
      WRITE (6,*) 'JO1D Measre =', JO1D
      WRITE (6,*) 'Correction JO1D and JNO2 by', JFACTO1D,JFACTNO2

 ! Output the model initial conditions so they are there in the file
      CALL NEWSAVEDATA()

!  Loop until the model time is great than the end time 
      time_loop: DO WHILE (time < TEND)

! Update the rate constants
         CALL Update_RCONST()
                
! Integrate the model forwards 1 timestep
         CALL INTEGRATE( TIN = time, TOUT = time+DT, RSTATUS_U = RSTATE, &
              ICNTRL_U = (/ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /),&
              IERR_U=ERROR)
         

! Update the time to reflect the integration has taken place and 
         time = RSTATE(1)
         Daycounter=Daycounter+1
         
         CALL NEWSAVEDATA()
         
      ENDDO time_loop
      Call newclosedata()

      WRITE (6,*) 'Outputed point', counter

   enddo
END PROGRAM driver


! End of MAIN function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


! End of MAIN function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


! End of MAIN function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


