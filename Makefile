FC        = gfortran
FCFLAGS   = -cpp -mcmodel=medium -g
##############################################################################

PROG = model 

# complete list of all f90 source files
SRCS1 = $(wildcard model_*.f90) constants.f90
SRCS2 = $(wildcard tuv_old/*.f)

# the object files are the same as the source files but with suffix ".o"
OBJS1 := $(SRCS1:.f90=.o) 
OBJS2 := $(SRCS2:.f=.o)

MAKEFILE_INC = depend.mk

# If you don't have the perl script sfmakedepend, get it from:
# http://www.arsc.edu/~kate/Perl
F_makedepend = ./sfmakedepend --file=$(MAKEFILE_INC)

all: $(PROG)

# the dependencies depend on the link
# the executable depends on depend and also on all objects
# the executable is created by linking all objects
$(PROG): depend $(OBJS1) $(OBJS2)
	$(FC) $(FCFLAGS) $(OBJS1) $(OBJS2) -o $@

# update file dependencies
depend $(MAKEFILE_INC): $(SRCS1) $(SRCS2)
	$(F_makedepend) $(SRCS1) $(SRCS2)

clean:
	rm -f $(PROG) $(OBJS1) $(OBJS2) *.mod *.log *~ depend.mk.old fort.* tuvlog.txt

distclean: clean
	rm -f $(PROG)
	rm -f depend.mk* 
	rm -f *.nc
	rm -f *.dat

# all object files *.o depend on their source files *.f90
# the object files are created with the "-c" compiler option
%.o: %.f90
	$(FC) $(FCFLAGS) -c $<
tuv_old/%.o: %.f
	$(FC) $(FCFLAGS) -c $<
# list of dependencies (via USE statements)
include depend.mk
