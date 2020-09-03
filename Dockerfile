FROM centos:8
#===============================================================================
# 
#===============================================================================
RUN dnf update -y
RUN dnf group install -y "Development Tools"
RUN dnf install -y git
RUN dnf install -y gcc-gfortran
RUN git clone https://github.com/wacl-york/DSMACC_teaching.git
RUN cd DSMACC_teaching && make
