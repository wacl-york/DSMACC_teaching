#===============================================================================
# SET UP BASE IMAGE
#===============================================================================
FROM centos:8 AS dsmacc_base
RUN dnf update -y && \
    dnf group install -y "Development Tools" && \
    dnf install -y git gcc-gfortran 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install &&
    aws --version
#===============================================================================
# SET UP MODEL
#===============================================================================
FROM dsmacc_base
#-------------------------------------------------------------------------------
# METADATA
#-------------------------------------------------------------------------------
LABEL "maintainer"="killian.murphy@york.ac.uk"
LABEL "version"="0.1.0"
LABEL "description"="Containerised DSMACC for teaching at UoY"
#-------------------------------------------------------------------------------
# COPY MODEL SOURCE AND INPUTS
#-------------------------------------------------------------------------------
WORKDIR /usr/local/dsmacc
COPY DATAE1 ./DATAE1
COPY DATAJ1 ./DATAJ1
COPY DATAS1 ./DATAS1
COPY Makefile *.f90 *.f *.kpp usrinp params sfmakedepend ./
#-------------------------------------------------------------------------------
# BUILD MODEL AND SET CONTAINER TO RUN IT
#-------------------------------------------------------------------------------
RUN make
ENTRYPOINT ["./model"]
