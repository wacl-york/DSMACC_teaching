! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Initialization File
! 
! Generated by KPP-2.0 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     Gratefully acknowledged are contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 7
! File                 : mcm_Init.f90
! Time                 : Wed Mar  9 14:32:20 2005
! Working directory    : /home/sander/kpp/mcm/boxmodel
! Equation file        : mcm.kpp
! Output root filen7ame : mcm
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE model_Init

  IMPLICIT NONE

CONTAINS


! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! InitVal - function to initialize concentrations
!   Arguments :
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SUBROUTINE InitVal (counter, Inputfile )

  USE model_Global
  use model_Monitor

  CHARACTER(LEN=50) :: Inputfile
  INTEGER :: i,j,found, counter
  REAL(kind=dp) :: x
  CHARACTER(LEN=10000) :: line
  CHARACTER(LEN=15) :: test
  REAL(kind=dp) :: concs(10000)
  REAL(kind=dp) :: oldvar(10000)
  LOGICAL :: SPECIAL
  INTEGER :: COUNT_NOX_CONSTRAINTS

! Open the file with the info

  write (6,*) 'Initializing model point', counter
  call flush(6)


  DO I=1,NVAR
     OLDVAR(I)=C(I)
     VAR(I)=0.
     C(I)=0.
  ENDDO
  SAREA=0.
  ALBEDO=0.
  RP1=0.

  if (counter .eq. 0) then 
     open(UNIT=21,FILE=InputFile)

! set everything to zero for the first iteration
! after that if doing a constrained run don't
     LINECOUNT=0
     DO WHILE (NOT(EOF(21)))
	READ (21,*)
	LINECOUNT=LINECOUNT+1
     ENDDO
     CLOSE(21)
     WRITE (6,*) 'Input file has ',LINECOUNT,' lines'
  endif

  IF (COUNTER .EQ. 1) THEN 
	open(UNIT=21,FILE=InputFile)
  ENDIF	
  time=tstart
! Set everything to zero
  
  if (counter .eq. 1) then 
     SPEC_CH4=.FALSE.
     SPEC_H2=.FALSE.
     READ(21,'(i10)') IntTime
     CONSTRAIN_RUN=.FALSE.

     IF (INTTIME .LE. 0) THEN 
        SPECIAL=.TRUE.
     ENDIF

     IF (INTTIME .EQ. -1) THEN 
        WRITE (6,*) 'Integration to convergence'
        CONSTRAIN_RUN=.TRUE.
        INTTIME=4380*24.*60.*60.
        OUTPUT_LAST=.FALSE.
        SPECIAL=.FALSE.
     ENDIF

     IF (INTTIME .EQ. -2) THEN 
        WRITE (6,*) 'Integration to convergence'
        CONSTRAIN_RUN=.TRUE.
        INTTIME=50*24.*60.*60.
        OUTPUT_LAST=.TRUE.
        SPECIAL=.FALSE.
     ENDIF

     IF (SPECIAL .EQ. .TRUE.) THEN
        WRITE (6,*) 'Negative Integration Time'
        WRITE (6,*) 'But not a special case'
        STOP
     ENDIF

     
     READ(21,'(10000(a15,x))') spec_name
     READ(21,'(10000(i15,x))') const_method     
  endif

  IF (COUNTER .NE. 0) THEN 

  READ (21,'(10000(e15.4,x))') concs
  IF (EOF(21)) THEN
     LAST_POINT=.TRUE.
  endif
  DO I=1,10000
     FOUND=0
     IF (SPEC_NAME(I) .NE. '') THEN
        
        DO J=1,NVAR 
           
           SPEC_NAME(I)=ADJUSTL(SPEC_NAME(I))
           
           IF (TRIM(SPEC_NAME(I)) .EQ. TRIM(SPC_NAMES(J))) THEN 
              FOUND=1
              VAR(J)=CONCS(I)
              IF (const_method(i) .EQ. 1) THEN 
                         CONSTRAIN(J)=CONCS(I)
              IF (SPEC_NAME(I) .EQ. 'CH4') SPEC_CH4=.TRUE.
              IF (SPEC_NAME(I) .EQ. 'H2') SPEC_H2=.TRUE.
              ENDIF
           ENDIF
        ENDDO

        IF (TRIM(SPEC_NAME(I)) .EQ. 'H2O') THEN
           FOUND=1
           H2O=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'PRESS') THEN 
           FOUND=1
           PRESS=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'NOx') THEN
           FOUND=1
           CONSTRAIN_NOX=.TRUE.
           WRITE (6,*) 'Constraining total NOx concentation'
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'LAT') THEN
           FOUND=1
           LAT=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'BLH') THEN
           FOUND=1
           BLH=CONCS(I)
        ENDIF 
 
        IF (TRIM(SPEC_NAME(I)) .EQ. 'DEPVEL') THEN 
           FOUND=1
           DEPVEL=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'LON') THEN 
           FOUND=1
           LON=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'TEMP') THEN
           FOUND=1
           TEMP=CONCS(I)
        ENDIF
        
        IF (TRIM(SPEC_NAME(I)) .EQ. 'JDAY') THEN 
           FOUND=1
           JDAY=CONCS(I)
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'TIME(GMTs)') THEN
           FOUND=1
           
        ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'O3COL') THEN
           FOUND=1
           O3COL=CONCS(I)
        ENDIF

	IF (TRIM(SPEC_NAME(I)) .EQ. 'ALBEDO') THEN 
	   FOUND=1
           ALBEDO=CONCS(I)
	ENDIF

	IF (TRIM(SPEC_NAME(I)) .EQ. 'SAREA') THEN 
	   FOUND=1
           SAREA=CONCS(I)
	ENDIF
        
	IF (TRIM(SPEC_NAME(I)) .EQ. 'RP1') THEN 
	   FOUND=1
           RP1=CONCS(I)
	ENDIF

        IF (TRIM(SPEC_NAME(I)) .EQ. 'JNO2') THEN
	   FOUND=1
           IF (CONST_METHOD(I) .GE. 1) THEN 
           	JNO2=CONCS(I)
	   ENDIF 
           JREPEAT=0
	   IF (CONST_METHOD(I) .EQ. 2) THEN 
		JREPEAT=1
	   ENDIF		
	ENDIF
        
	IF (TRIM(SPEC_NAME(I)) .EQ. 'JO1D') THEN
	   FOUND=1
	   IF (CONST_METHOD(I) .GE. 1) THEN 
		   JO1D=CONCS(I)
	   ENDIF
	   JREPEAT=0
	   IF (CONST_METHOD(I) .EQ. 2) THEN 
	       JREPEAT=1
           ENDIF	
        ENDIF
     ENDIF
      IF (TRIM(SPEC_NAME(I)) .NE. '' .AND. FOUND .EQ. 0) THEN
         WRITE (6,*) SPEC_NAME(I),' NOT FOUND'
         IF (SPEC_NAME(I)(1:1) .NE. 'X') STOP
         WRITE (6,*) 'Starts with an X so ignored and continued'   
      ENDIF
  ENDDO
     
  CFACTOR=PRESS*1e2*1e-6/(8.314*TEMP)*6.022E23
  
  H2O=H2O*CFACTOR 
  DO I=1,NVAR
     IF (SPC_NAMES(I)(1:3) .NE. 'EM_') THEN
        VAR(I)=VAR(I)*CFACTOR
     ENDIF
  ENDDO

 DO I=1,NVAR
!    C(I)=0.
!     IF (VAR(I) .EQ. 0) VAR(I)=OLDVAR(I)  
  ENDDO

! FIND NOX species
  IF (CONSTRAIN_NOX) THEN 
  COUNT_NOX_CONSTRAINTS=0
  DO I=1,NVAR 
     IF (TRIM(SPC_NAMES(I)) .EQ. 'NO2') THEN
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
        IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF 

     IF (TRIM(SPC_NAMES(I)) .EQ. 'NO') THEN
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
        IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'NO3') THEN 
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
          IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'N2O5') THEN
        NOX(I)=2
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
          IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'HONO') THEN
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
          IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'HNO2') THEN
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
          IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'HO2NO2') THEN
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
          IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'PNA') THEN 
        NOX(I)=1
        CONSTRAIN(I)=-1*CONSTRAIN(I)
     ENDIF

     IF (TRIM(SPC_NAMES(I)) .EQ. 'HNO4') THEN 
        NOX(I)=1
        CONSTRAIN(I)=-1.*CONSTRAIN(I)
        IF (CONSTRAIN(I) .NE. 0) THEN 
           COUNT_NOX_CONSTRAINTS=COUNT_NOX_CONSTRAINTS+1
        ENDIF
     ENDIF

     IF (NOX(I) .NE. 0) WRITE (6,*) SPC_NAMES(I),' IN NOX FAMILY'
  ENDDO
  
  IF (COUNT_NOX_CONSTRAINTS .GT. 1) THEN 
     WRITE (6,*) 'You can not contrains multiple NOX species'
     STOP
  ENDIF
  ENDIF

! FIND CH4 and H2 species
  !DO I=1,NVAR 
  !   IF (TRIM(SPC_NAMES(I)) .EQ. 'CH4' .AND. SPEC_CH4 .EQ. .FALSE.) THEN
  !      WRITE (6,*) 'No CH4 specified assuming 1770 ppbv'
  !      VAR(I)=1770e-9*CFACTOR
  !      CONSTRAIN(I)=VAR(I)
  !   ENDIF

  !   IF (TRIM(SPC_NAMES(I)) .EQ. 'H2' .AND. SPEC_H2 .EQ. .FALSE.) THEN 
  !      WRITE (6,*) 'No H2 specified assuming 550 ppbv'
  !      VAR(I)= 550e-9*CFACTOR
  !      CONSTRAIN(I)=VAR(I)
  !   ENDIF
  !ENDDO
! INLINED initialisations

! End INLINED initialisations

  ENDIF
      
END SUBROUTINE Initval

! End of InitVal function
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



END MODULE model_Init

