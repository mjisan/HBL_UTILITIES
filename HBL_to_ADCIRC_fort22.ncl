f1         = addfile("output_u_wind.nc","r") ; define input wind file. File should include u-wind and v-wind components.
f2         = addfile("output_v_wind.nc","r")

u          = f1->u10
printVarSummary(u)
u11        = ndtooned(u)
u@_FillValue = 0
u11@_FillValue = 0
u12        = where(u11.ge.1000000, 0, u11)
delete([/u,u11/])

v          = f2->v10
printVarSummary(v)
v11        = ndtooned(v)
v@_FillValue = 0
v11@_FillValue = 0
v12        = where(v11.ge.1000000, 0, v11)
delete(v)


slp        = new((/dimsizes(v11)/),float)
slp        = 100998
slp11      = ndtooned(slp)
delete(slp)
slp12      = where(slp11.ge.1000000, 0, slp11)
delete([/v11,slp11/])


;;;;;;;;;;;;uncomment below lines for  fort22 info file.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;lat        = f1->lati
;lon        = f1->loni

;NWLAT      = dimsizes(lat)
;NWLON      = dimsizes(lon)
;WLATMAX    = max(lat) 
;WLONMIN    = min(lon) 
;WLATINC    = abs(lat(1)-lat(0)) 
;WLONINC    = abs(lon(1)-lon(0)) 

;print(NWLAT)
;print(NWLON)
;print(WLATMAX)
;print(WLONMIN)
;print(WLATINC)
;print(WLONINC)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

write_table("fort22.txt","a",[/u12,v12,slp12/]," %.2f  %.2f  %.2f")
