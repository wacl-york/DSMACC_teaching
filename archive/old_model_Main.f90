! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Main Program File
! 
! Generated by KPP-2.2 symbolic chemistry Kinetics PreProcessor
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
! Time                 : Wed Feb  2 10:56:21 2011
! Working directory    : /nfs/see-archive-06_a43/chm0pe/methods/DSMACC_Repository_I_f
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
  INTEGER  :: ERROR, IJ
  LOGICAL :: SCREWED

! Photolysis calculation variables
  REAL(dp) :: Alta

  Integer  :: Daycounter, CONSTNOXSPEC, JK,counter

  REAL(dp) :: NOXRATIO, NEW_TIME
  REAL(dp) :: Fracdiff, SpeedRatio, oldfracdiff, FRACCOUNT
 
  STEPMIN = 0.0_dp
  STEPMAX = 0.0_dp
  RTOL(:) = 1.0e-7_dp
  ATOL(:) = 1.0_dp
  counter=0
  LAST_POINT=.FALSE.
 

!  IF YOU WANT TO CONSTRAIN THE NOX THEN
   CONSTRAIN_NOX=.FALSE.

!  If we are running a constrained run we want one file with the final points calculated
   IF (CONSTRAIN_RUN .EQ. .TRUE. .AND. OUTPUT_LAST .EQ. .FALSE.) THEN 
      call newinitsavedata(1)
   ENDIF


CALL INITVAL(0)
!This is the loop of different points in the Init_cons.dat file

!$OMP PARALLEL
!$OMP DO

do counter=1,LINECOUNT-3
!100 counter=counter+1

! If we are running a non-constrained run then we want one file per input in the Init_cons.dat file
   IF (CONSTRAIN_RUN .EQ. .FALSE. .OR. OUTPUT_LAST .EQ. .TRUE.) THEN 
      CALL NEWINITSAVEDATA(COUNTER)
   ENDIF
   
! Read in the next initial conditions
     WRITE (6,*) 'Reading in point', counter
!$OMP CRITICAL
     CALL InitVal(counter)
!$OMP END CRITICAL 
! Set up the output files file

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
!$OMP CRITICAL 
	IF (JREPEAT .EQ. 0 .OR. COUNTER .EQ. 1) THEN 
        call set_up_photol(O3col,Albedo, alta, temp, bs,cs,ds,szas,svj_tj)
	ELSE
	WRITE (6,*) 'Using previously calculated photolysis params'
	ENDIF
!$OMP END CRITICAL
     WRITE (6,*) 'Photolysis rates calculated'
     WRITE (6,*) 'hvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhvhv'
     time = tstart


     OLDFRACDIFF=0.
    
! If NOx is being constrained calculate the total NOx in the model 
     IF (CONSTRAIN_NOX) THEN 
      TNOX_OLD=0.
      DO JK=1,NVAR
         TNOX_OLD=TNOX_OLD+C(JK)*NOX(JK)
      ENDDO
     ENDIF

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
! Calcualte correction factors for the model photolysis rates
     IF (JO1D .NE. 0. .AND. J(1) .GT. 0.) THEN
        JFACTO1D=JO1D/J(1)
     ENDIF

     IF (JNO2 .NE. 0. .AND. J(4) .GT. 0.) THEN
        JFACTNO2=JNO2/J(4)
     ENDIF

     IF (JNO2 .EQ. 0. .AND. JO1D .NE. 0.) THEN 
        JFACTNO2=JFACTO1D
     ENDIF

     IF (JO1D .EQ. 0. .AND. JNO2 .NE. 0.) THEN 
        JFACTO1D=JFACTNO2
     ENDIF

     WRITE (6,*) 'Correction JO1D and JNO2 by', JFACTO1D,JFACTNO2

! If we are running a free running model output the initial condition so T=0 of the output file gives the initial condition
     IF (CONSTRAIN_RUN .EQ. .FALSE.) THEN 
           CALL NEWSAVEDATA()
     ENDIF



! Set up a counter to count the number time that the model has been run for 
     Daycounter=0

! This is the main loop for integrations
     time_loop: DO WHILE (time < TEND)

! Update the rate constants
        CALL Update_RCONST()
                
! Integrate the model forwards 1 timestep
        CALL INTEGRATE( TIN = time, TOUT = time+DT, RSTATUS_U = RSTATE, &
             ICNTRL_U = (/ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /),&
             IERR_U=ERROR)

        IF (ERROR .NE. 1) THEN 
           WRITE (6,*) 'Integration error.'
           WRITE (6,*) 'Skipping point'
           DO I=1,NVAR
              C(I)=0.
           ENDDO
           GOTO 1000
        ENDIF
! Traps for NaN
        SCREWED=.FALSE.
        DO I=1,NVAR
           IF (ISNAN(C(I))) SCREWED=.TRUE.
        ENDDO

        IF (SCREWED) THEN 
           SCREWED=.FALSE.
           DO i=1,NVAR
              C(I)=0.
           ENDDO
           GOTO 1000
        ENDIF
! Update the time to reflect the integration has taken place and 
        time = RSTATE(1)
 Daycounter=Daycounter+1

! If we are constraining NOx then:
        IF (CONSTRAIN_NOX) THEN 
           WRITE (6,*) 'Constraining NOx'

! Calcualte the total NOx in the box
           TNOX=0
           DO I=1,NVAR
              IF (NOX(I) .NE. 0) THEN 
                 TNOX=TNOX+C(I)*NOX(I)
              ENDIF
           ENDDO
           
! Update all NOx variables so that the total NOx in the box is the same as it was
           DO I=1,NVAR
              IF (NOX(I) .NE. 0) THEN 
                 C(I)=C(I)*TNOX_OLD/TNOX
              ENDIF
           ENDDO
        ENDIF

! If constrain species concentALrations if necessary
        DO I=1,NVAR
           IF (CONSTRAIN(I) .GT. 0) THEN             
              C(I)=CONSTRAIN(I)
           ENDIF
        ENDDO
        
! If we are not doing a constrained run then output the concentrations
        IF (CONSTRAIN_RUN .EQ. .FALSE.) THEN 
           CALL NEWSAVEDATA()
        ENDIF

! If we are doing a constrained run we need to store the diurnal profile of all the species
        IF (CONSTRAIN_RUN .EQ. .TRUE.) THEN
           DO I=1,NVAR
              DIURNAL_NEW(I,DAYCOUNTER)=C(I)
           ENDDO

           DO I=1,NREACT
              DIURNAL_RATES(I,DAYCOUNTER)=RCONST(I)
           ENDDO
           
! Are we at the end of a day?
! If so we need to 
!   1) fiddle with the NOX to ensure it has the right concentrations see if we have reached a steady state
           IF (DAYCOUNTER*DT .GE. 24.*60.*60.) THEN

! Sort out the NOx. Need to increase the NOx concentration so that the constrained species is right
! What is  the constrained NOx species? Put result into CONSTNOXSPEC
           DO I=1,NVAR
              IF (NOX(I) .NE. 0) THEN 
                 IF (CONSTRAIN(I) .LT. 0) THEN 
                    CONSTNOXSPEC=I
                 ENDIF
              ENDIF
           ENDDO

! Calculate the ratio between the value we the constrained NOx species and what we have
! Remember the constrained NOx species is given by the negative constrained value
    NOXRATIO=-CONSTRAIN(CONSTNOXSPEC)/C(CONSTNOXSPEC)
 
    ! Multiply all the NOx species by the ratio so 
    DO I=1,NVAR
       IF (NOX(I) .NE. 0) THEN 
          C(I)=C(I)*NOXRATIO
       ENDIF
    ENDDO
    
! Update the total amount of NOx in box
    TNOX_OLD=TNOX_OLD*NOXRATIO
 


! Lets see how much the diurnal ratios have changed since the last itteration

! Frac diff is our metric for how much it has changed 
              FRACDIFF=0.
              FRACCOUNT=0.
! Add up for all species and for each time point in the day
              DO I=1,NVAR
                 DO JK=1,DAYCOUNTER

!If there is a concentration calculated
                    IF (DIURNAL_NEW(I,JK) .GT. 1.e2 .AND. &
                         TRIM(SPC_NAMES(I)) .NE. 'DUMMY') THEN 

!Calculate the absolute value of the fractional difference and add it on
! Increment the counter to calculate the average
                       FRACDIFF=FRACDIFF+&
                            ABS(DIURNAL_OLD(I,JK)-DIURNAL_NEW(I,JK))/&
                            DIURNAL_NEW(I,JK)
                       FRACCOUNT=FRACCOUNT+1
                    ENDIF
                     
                 ENDDO
              ENDDO

! Calculate the average fractional difference
              FRACDIFF=FRACDIFF/FRACCOUNT

! Output the diagnostic
              WRITE (6,*) 'Fraction difference in the diurnal profile:', FRACDIFF


! Store the new diurnal profile as the old one so we can compare with the next day

              DO I=1,NVAR
                 DO JK=1,DAYCOUNTER
                    DIURNAL_OLD(I,JK)=DIURNAL_NEW(I,JK)
                 ENDDO
              ENDDO

! reset the day counter to 0
             

! if the system has converged then end the simulation for this point

              IF (FRACDIFF .LE. 1e-3) THEN
                 GOTO 1000
              ENDIF
              DAYCOUNTER=0
              OLDFRACDIFF=FRACDIFF
           ENDIF
        ENDIF
     ENDDO time_loop


1000  IF (CONSTRAIN_RUN .EQ. .TRUE. .AND. OUTPUT_LAST .EQ. .FALSE.) THEN 
   call newsavedata()
ENDIF

IF (OUTPUT_LAST .EQ. .TRUE.) THEN 
   DO I=1,DAYCOUNTER
      NEW_TIME=I*DT
      WRITE (10,999) NEW_TIME,LAT, LON, PRESS, TEMP,H2O, CFACTOR, RO2, &
           (DIURNAL_NEW(JK,I),JK=1,NVAR)
      WRITE (12,999) NEW_TIME,LAT, LON, PRESS, TEMP,H2O, CFACTOR,& 
           (DIURNAL_RATES(JK,I),JK=1,NREACT)
   ENDDO
999 FORMAT(E24.16,100000(1X,E24.16))
ENDIF

IF (CONSTRAIN_RUN .EQ. .FALSE.) THEN
   ! close output file
   call newclosedata()
ENDIF
WRITE (6,*) 'Outputed point', counter

enddo
!$OMP END DO NOWAIT
!$OMP END PARALLEL 

!if (.NOT. LAST_POINT) goto 100

IF (CONSTRAIN_RUN .EQ. .TRUE.) THEN 
   call Newclosedata()
ENDIF

END PROGRAM driver


! End of MAIN function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

