;NCL code to convert the URI Hurricane Boundary Model's wind output from vortex following moving mesh to a fixed mesh.
; usage: ncl wind_regrid.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

setfileoption("nc","Format","NetCDF4Classic")


latmin = 26                                                                                  ; define the corner points here
latmax = 40
lonmin = -82
lonmax = -67

nx     = 1202                                                                                ; number of grid points in X-direction                      
ny     = 1202                                                                                ; number of grid points in Y-direction

f1     = addfile("ram_forecast.nc","r")                                                      ; define input file name

system("rm -rf ram_fixed.nc")                                                        

ncdf   = addfile("ram_fixed.nc" ,"c")                                                        ; output regridded file name



;-------------------------------------------no need to change anything below this line------------------------------------------------;
;-------------------------------------------------------------------------------------------------------------------------------------;


u         = f1->ubot
v         = f1->vbot
x         = f1->x_center
lon_cents = new((/dimsizes(x),1/),"float")
lat_cents = new((/dimsizes(x),1/),"float")
lons      = f1->x_center
lats      = f1->y_center

do nt     = 0,dimsizes(x)-1,1

  lon_cents(nt,:) = lons(nt)
  lat_cents(nt,:) = lats(nt)

end do

u              = f1->ubot
v              = f1->vbot
X              = f1->x
Y              = f1->y
	       
stepx          = 1.0e3
stepy          = 1.0e3
rearth         = 6.37122e+06
d2r            = 3.14159265/180
nlon           = dimsizes(X)
nlat           = dimsizes(Y)
res_lat        = stepy/(d2r*rearth)
res_lon        = stepx/(d2r*rearth*cos(lat_cents*d2r))
lat_cent_value = abs(lat_cents)
lon_cent_value = abs(lon_cents)
latgrid_center = fspan( (-floor(nlat/2)+1),floor(nlat/2), ny)
latgrid_center = latgrid_center *  res_lat
lat = new((/dimsizes(x),ny/),"float")

do nt = 0,dimsizes(x)-1,1

  lat(nt,:)    = latgrid_center+ lat_cent_value(nt,0)

end do

lat = abs(lat)

longrid_centers = fspan( (-floor(nlon/2)+1),floor(nlon/2), nx)
longrid_centers = longrid_centers*-1
longrid_center  = new((/dimsizes(x),nx/),"float")

do nt = 0,dimsizes(x)-1,1
longrid_center(nt,:) = longrid_centers *  res_lon(nt,0)
end do

lon = new((/dimsizes(x),nx/),"float")

do nt = 0,dimsizes(x)-1,1

lon(nt,:) = longrid_center(nt,:) + lon_cent_value(nt,0)

end do

lon      = abs(lon)
lon      = lon*(-1)
;latmin   = min(lat)
;latmax   = max(lat)
;lonmin   = min(lon)
;lonmax   = max(lon)

latint   = lat(0,1)-lat(0,0)
lonint   = lon(0,1)-lon(0,0)
lati     = testspan(latmin,latmax,latint)
loni     = testspan(lonmin,lonmax,lonint)
nLatGrid = dimsizes(lati)
nLonGrid = dimsizes(loni)

;print(latmin+" "+latmax+" "+lonmin+" "+lonmax)

u_regrid   =  new( (/dimsizes(x),nLatGrid,nLonGrid/), "float")
v_regrid   =  new( (/dimsizes(x),nLatGrid,nLonGrid/), "float")

do nt = 0,dimsizes(x)-1,1

u_regrid(nt,:,:)    =  linint2_Wrap (lon(nt,:), lat(nt,:), u(nt,:,:),  False, loni, lati, 0)
v_regrid(nt,:,:)    =  linint2_Wrap (lon(nt,:), lat(nt,:), v(nt,:,:),  False, loni, lati, 0)

print("Now interpolating hour"+nt)

end do

 u_regrid!0 = "time"
 u_regrid!1 = "lati"
 u_regrid!2 = "loni"
 u_regrid&lati=lati
 u_regrid&loni=loni

 v_regrid!0 = "time"
 v_regrid!1 = "lati"
 v_regrid!2 = "loni"
 v_regrid&lati=lati
 v_regrid&loni=loni
 
  ncdf->u_regrid=u_regrid
  ncdf->v_regrid=v_regrid

