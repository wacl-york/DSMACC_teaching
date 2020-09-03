FROM dsmacc_base:latest
#===============================================================================
# METADATA
#===============================================================================
LABEL "maintainer"="killian.murphy@york.ac.uk"
LABEL "version"="0.1.0"
LABEL "description"="Containerised DSMACC for teaching at UoY"
#===============================================================================
# BUILD THE IMAGE
#===============================================================================
#RUN dnf update -y
#RUN dnf group install -y "Development Tools"
#RUN dnf install -y git
#RUN dnf install -y gcc-gfortran
#===============================================================================
# SET UP MODEL
#===============================================================================
WORKDIR /usr/local/dsmacc
