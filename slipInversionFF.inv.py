'''
Diego Melgar, 03/2017

Parameter file for inverse problem
Project: Mutata 2016 Earthquake

'''

from mudpy import runslip
import numpy as np
from obspy.core import UTCDateTime

########                            GLOBALS                             ########
home="/Users/jeanbaptistetary/Documents/SSI/"
project_name='FarField'
run_name="mutata"
################################################################################


#####              What-do-you-want-to-do flags, 1=do, 0=leave be          #####close

init=0 #Initalize project
make_green=0 #Do not compute GFs
make_synthetics=0 #Do not compute synthetics for a given model at given stations
G_from_file=0# =0 read GFs and create a new G, =1 load G from file
invert=1  # =1 runs inversion, =0 does nothing
###############################################################################

###############          view  Green function parameters               #############
ncpus=2
static=0
coord_type=1 #=0 for cartesian, =1 for lat/lon(flat earth)
hot_start=0 #Start at a certain subfault number
model_name='FF-VelMod.mod' #Velocity model
fault_name='mutata.fault'    #Fault geometry
station_file='mutata.sta'
GF_list='mutata.gflist'
tgf_file=None
G_name='mutata' #Either name of GF matrix to load or name to save GF matrix with
# Displacement and velocity wcloseaveform parameters
NFFT=2048; dt=0.5
#Tsunami deformation parameters
tsunNFFT=64 ; tsun_dt=2.0
#fk-parameters
dk=0.2 ; pmin=0 ; pmax=1 ; kmax=10
custom_stf=None
################################################################################

#############               Inversion Parameters               #################
time_epi=UTCDateTime('2016-09-14T01:58:31')
epicenter=np.array([ -76.275 , 7.236 ,20])
rupture_speed=1.5 #Fastest rupture allowed in km/s
num_windows=10 #
reg_spatial=np.logspace(-6,0,num=10)#Set to False if you don't want to use it
reg_temporal=np.logspace(-8,2,num=20)#Set to False if don't want to use it
nstrike=17 ; ndip=17 ; nfaults=(nstrike,ndip) #set nstrike to total no. of faults and ndip to 1 if using Tikh
beta=0 #Rotational offset (in degrees) applied to rake (0 for normal)
Ltype=2 # 0 for Tikhonov and 2 for Laplacian
solver='nnls' # 'lstsq','nnls'
top='locked' ; bottom='locked' ; left='locked' ; right='locked' #'locked' or 'free'
bounds=(top,bottom,left,right)
################################################################################e=

########      Run-time modifications to the time series             ############
weight=True
decimate=None#  #Decimate by constant (=None for NO decimation)
# #Corner frequencies in Hz =None if no filter is desired
 # [0.5] is a low pass filter
 # [0.02,0.5] is a band pass filter
 # [0.02,np.inf] is a high pass filter
displacement_bandpass=np.array([0.03,0.09])
velocity_bandpass=None
tsunami_bandpass=None
bandpass=[displacement_bandpass,velocity_bandpass,tsunami_bandpass]
################################################################################

#Initalize project folders
if init==1:
    runslip.init(home,project_name)

# Run green functions
if make_green==1 or make_synthetics==1:
    runslip.inversionGFs(home,project_name,GF_list,tgf_file,fault_name,model_name,
        dt,tsun_dt,NFFT,tsunNFFT,make_green,make_synthetics,dk,pmin,
        pmax,kmax,beta,time_epi,hot_start,ncpus,custom_stf)

#Run inversion
if invert==1:
    runslip.run_inversion(home,project_name,run_name,fault_name,model_name,GF_list,G_from_file,
            G_name,epicenter,rupture_speed,num_windows,reg_spatial,reg_temporal,
            nfaults,beta,decimate,bandpass,solver,bounds,weight,Ltype)
