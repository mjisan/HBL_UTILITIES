;howto execute: type following command. change the fname, lonv and latv based on the coordinate of the observation. fname is the output file name, lonv is longitude and latv is the latitude of the observation stations

;usage: ncl 'fname="8727520_HBL.txt"' 'lonv=-83.01917' 'latv=29.13361' extract_wind_hbl.ncl 



system("echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!HOWDY ${USER^^}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ")
begTime = get_cpu_time()

;this code extract wind speed from HWRF model output for any fixed point / stations using bilinear interpolation.

print("this code extract wind speed from HBL model output for any fixed point / stations using bilinear interpolation. written by Mansur Ali Jisan (mansur@uri.edu)")

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"


setfileoption("nc","Format","NetCDF4Classic")

; start date

syyyy = 2018
smm = 10
sdd = 09
shh = 00

;end date

eyyyy = 2018
emm = 10
edd = 10
ehh = 22


timeUnits = "hours since 2018-10-09 00:00:00"

sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)

edate = cd_inv_calendar(eyyyy,emm,edd,ehh,40,00,timeUnits,0)    ;puts ending time into same time units as CFSR data

ntimes = toint((edate-sdate)/.0166671)+1

times = new( (/ntimes/), "float")

times@units = timeUnits

do n=0,ntimes-1
   times(n) = tofloat(sdate + (.0166671*1*n))
 end do


 ttme = cd_string(times,"%N/%D/%Y %H:%M")



;---------------------------------change the below three lines----------------------------------------------------------------------------

output_file_name                 = fname                                               ; output filename
lon_NDBC                         = (/lonv/)                                            ; location of observations
lat_NDBC                         = (/latv/)

;---------------------------------------------------------------------------------------------------------------------------------------------
print("--removing any pre-existing output file--")
system("/bin/rm -f "+output_file_name)


print("--Reading Input Model File--")

u                                = addfile("michael_u_wind_component.nc","r")   ; File Input
v                                = addfile("michael_v_wind_component.nc","r")   ; File Input
u10                              = u->u10
v10                              = v->v10
lat                              = u->lat                      ; read lat var
lon                              = u->lon                      ; read lon var
nLatGrid                         = dimsizes(lat_NDBC)          ; dimsizes of observation points
nLonGrid                         = dimsizes(lon_NDBC)



print("--Initializing Interpolation--")

u_rg                         =  new( (/dimsizes(u10(:,0,0)),nLatGrid,nLonGrid/), "float")                      ; Creating new variable to hold interpolated wind
v_rg                         =  new( (/dimsizes(v10(:,0,0)),nLatGrid,nLonGrid/), "float")

do nt = 0, dimsizes(u10(:,0,0))-1, 1                                                                                 ; interpolation loop

u_rg(nt,:,:)                         =  linint2_Wrap (lon, lat, u10(nt,:,:),  False, lon_NDBC, lat_NDBC, 0)

end do

do nt = 0, dimsizes(v10(:,0,0))-1, 1                                                                                 ; interpolation loop

v_rg(nt,:,:)                         =  linint2_Wrap (lon, lat, v10(nt,:,:),  False, lon_NDBC, lat_NDBC, 0)

end do

wsmag       = sqrt((u_rg(:,0,0))^2 + (v_rg(:,0,0))^2)
av          = runave_n_Wrap(wsmag,8,0,0)
line_format = ttme+" "+av



print("--Creating output--")

asciiwrite(output_file_name,line_format)                                                                 ; write out in text format

print("--Output File Generated--")
print("Plot generation time: " + (get_cpu_time() - begTime))
