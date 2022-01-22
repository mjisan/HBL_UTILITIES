# HBL_UTILITIES
A collection of NCL codes to process URI Hurricane Boundary Layer Wind Model Data.  

- HBL_to_ADCIRC_fort22.ncl: This code convert HBL wind file in to ADCIRC's Meteorological Forcing File (fort.22)

- extract_wind_hbl.ncl: This code is used to extract wind data from the HBL model for any given coordinate points using bilinear interpolation.

  usage: ncl 'fname="8727520_HBL.txt"' 'lonv=-83.01917' 'latv=29.13361' extract_wind_hbl.ncl

- wind_regrid.ncl: This code converts HBL's moving mesh wind output in to a fixed mesh.





