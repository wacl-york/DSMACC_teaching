#===============================================================================
#
#===============================================================================

# COMPILER FLAGS --------------------------------------------------------------- 
FC        = gfortran
FCFLAGS   = -cpp -mcmodel=medium -g

# SOURCES, DEPENDENCIES, OBJECTS -----------------------------------------------
SRCS1 = $(wildcard model_*.f90) constants.f90
SRCS2 = $(wildcard tuv_old/*.f)

OBJS1 := $(SRCS1:.f90=.o) 
OBJS2 := $(SRCS2:.f=.o)

DEPENDENCY_LIST = depend.mk

GEN_DEPENDENCIES = ./sfmakedepend --file=$(DEPENDENCY_LIST)

# OUTPUT EXECUTABLE ------------------------------------------------------------
PROG = model 

# MAKE TARGETS -----------------------------------------------------------------
$(PROG): dependencies $(OBJS1) $(OBJS2)
	$(FC) $(FCFLAGS) $(OBJS1) $(OBJS2) -o $@

dependencies $(DEPENDENCY_LIST): $(SRCS1) $(SRCS2)
	$(GEN_DEPENDENCIES) $(SRCS1) $(SRCS2)

%.o: %.f90
	$(FC) $(FCFLAGS) -c $<
tuv_old/%.o: %.f
	$(FC) $(FCFLAGS) -c $<

.PHONY: clean
clean:
	rm -f $(PROG)
	rm -f $(OBJS1)
	rm -f $(OBJS2)
	rm -f *.mod
	rm -f *.log 
	rm -f *~
	rm -f depend.mk
	rm -f fort.*
	rm -f tuvlog.txt
	rm -f *.nc
	rm -f *.dat

include depend.mk
