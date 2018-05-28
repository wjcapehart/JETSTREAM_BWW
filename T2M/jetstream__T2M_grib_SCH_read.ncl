load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;
  ; Code Processes Through the BWW GRIB ensemble data storage on Jetstream
  ;
  ;   Extracts one field for bulk-scale processing for a given subset.


  ; start_date_string = "2017-02-01"  ;; commented out for batch script
  ; end_date_string   = "2017-02-28"  ;; commented out for batch script
  ; localle           = "alb"         ;; commented out for batch script

  variable_ID_label = "T2M"  ; Single Value Title Label for File

  variable_file_id  = "Temperature_height_above_ground" ; Variable as named on server

  standard_name_for_variable = "air_temperature"
  long_name_for_variable     = "2-m Air Temperature"
  units_for_variable         = "K"

  vertical_coordinate_for_variable     = "height_above_ground"
  vertical_coordinate_value            = (/ 2.0 /)
  vertical_coordinate_units            = "m"
  vertical_coordinates_posdir          = "up"
  vertical_coordinates_long_name       = "Observed Height Above Ground"
  vertical_coordinates_standard_name   = "height"



  latitude_file_id  = "latitude_-90_to_and90_surface"   ; Latitude as named on server
  longitude_file_id = "east_longitude_0-360_surface"    ; Longitude as named on server

  directory = "./"           ; directory for processing [keep me local!]

  ;;; local region to clip
  lat_min = 34. ; degrees North
  lat_max = 55. ; degrees North

  lon_min = 247. ; degrees East
  lon_max = 268. ; degrees East

  ; URL or direct file system path to archive directory/THREDDS server.

  url_root  = "http://149.165.157.204/thredds/dodsC/archive"

  ; Thredds Fixed URL for generic metadata extractoin. (don't change)

  initital_setup_url = "http://149.165.157.204/thredds/dodsC/archive/alb10/180319/alb10_18031900_post.grib"


  ;  Projection Information for NetCDF Files (customized for BWW community domain)

  Lambert_Conformal = toint(0)
     Lambert_Conformal!0 =  "ncl_scalar"
     Lambert_Conformal@grid_mapping_name = "lambert_conformal_conic";
     Lambert_Conformal@standard_parallel = 39.5;
     Lambert_Conformal@longitude_of_central_meridian = 360.0-98.50000762939453;
     Lambert_Conformal@latitude_of_projection_origin = 39.5;



 setfileoption("nc", "Format",          "NetCDF4")
 setfileoption("nc", "CompressionLevel",        6)
  ;;;localle = "alb" ; change this one...

  title_string      = "bww_" + localle + "_" + variable_ID_label + "_"
  file_output_name = "./" + title_string + start_date_string + "_" + end_date_string + ".nc"

  print("Processing "+file_output_name)

  start_time          = 0
    start_time@units  = "days since " + start_date_string + " 00:00:00"
  end_time            = 0
    end_time@units    = "days since " +  end_date_string  + " 00:00:00"

  time_units = "days since 2016-01-01 00:00:00"


   member_table_name = (/ "alb", \
                          "csu", \
                          "psu", \
                          "smt", \
                          "ttu", \
                          "und", \
                          "uwm" /)

   member_table_nens = (/ 13, \
                          01, \
                          09, \
                          03, \
                          08, \
                          04, \
                          09 /)

   member_table_pinterval = (/ 01, \
                               01, \
                               03, \
                               03, \
                               03, \
                               03, \
                               03 /)

   ne = member_table_nens(ind(member_table_name .eq. localle))

   product_interval = member_table_pinterval(ind(member_table_name .eq. localle))
      product_interval@units = "day"

  start_time_arch = cd_convert(start_time, time_units)
  end_time_arch   = cd_convert(end_time,   time_units)

  nt = toint(end_time_arch-start_time_arch)+1

  ; Crack open a temporary wrf file and grab our study area.  (This will be bigger than our acutal area.)


  f = addfile(initital_setup_url, "r")


  latw = f->$$latitude_file_id$(0,:,:)
  lonw = f->longitude_file_id(0,:,:)


  wrf_region_ind = region_ind(latw,lonw,lat_min,lat_max,lon_min,lon_max)

  i_min = wrf_region_ind(2)
  i_max = wrf_region_ind(3)
  j_min = wrf_region_ind(0)
  j_max = wrf_region_ind(1)

  delete(latw)
  delete(lonw)

  longitude = f->$latitude_file_id$(  0, j_min:j_max, i_min:i_max)
  latitude  = f->$longitude_file_id$( 0, j_min:j_max, i_min:i_max)

  delete(f)

    delete(latitude@_ChunkSizes)
    delete(latitude@stagger)
    delete(latitude@MemoryOrder)
    delete(latitude@coordinates)
    delete(latitude@FieldType)

    delete(longitude@_ChunkSizes)
    delete(longitude@stagger)
    delete(longitude@MemoryOrder)
    delete(longitude@coordinates)
    delete(longitude@FieldType)

  longitude@description = "Longitude"
  latitude@description  = "Latitude"

  longitude@long_name = "Longitude"
  latitude@long_name  = "Latitude"

  longitude@standard_name = "longitude"
  latitude@standard_name  = "latitude"


   nx_wrf = i_max - i_min + 1
   ny_wrf = j_max - j_min + 1


   forecast_time               = ispan(0, 84, 3)
   forecast_time!0             = "forecast_time"
   forecast_time&forecast_time = forecast_time
   forecast_time@units         = "hours"
   forecast_time@description   = "Hours Into Forecast"
   forecast_time@long_name     = forecast_time@description

   nt_wrf = dimsizes(forecast_time)

   time_steps = ispan(0, nt_wrf-1, 1)
print(forecast_time)
   ensemble_member = localle+sprinti("%0.2i",ispan(1,ne,1))
   ensemble_member!0 = "ensemble_member"
   ensemble_member&ensemble_member = ensemble_member
   ensemble_member@description = "Ensemble ID"
   ensemble_member@long_name   = "Ensemble ID"

   height_above_ground                     = vertical_coordinate_value
   height_above_ground!0                   = vertical_coordinate_for_variable
   height_above_ground&height_above_ground = vertical_coordinate_value
   height_above_ground@description         = vertical_coordinates_long_name
   height_above_ground@long_name           = height_above_ground@description
   height_above_ground@standard_name       = vertical_coordinates_standard_name
   height_above_ground@positive            = vertical_coordinates_posdir
   height_above_ground@unit                = vertical_coordinate_units
   height_above_ground@axis                = "Z"




   time = fspan(start_time_arch, end_time_arch, nt)
      time@description   = "time"
      time@long_name     = "time"
      time@standard_name = "time"
      time@calendar      = "standard"
      time@units         = time_units
      time!0             = "time"
      time&time          = time




   thredd_var = new((/ nt, ne, nt_wrf, 1, ny_wrf, nx_wrf /), float)
      thredd_var!0                   = "time"
      thredd_var!1                   = "ensemble_member"
      thredd_var!2                   = "forecast_time"
      thredd_var!3                   = vertical_coordinate_for_variable
      thredd_var!4                   = "y"
      thredd_var!5                   = "x"
      thredd_var&time                = time
      thredd_var&ensemble_member     = ensemble_member
      thredd_var&forecast_time       = forecast_time
      thredd_var&height_above_ground = height_above_ground
      thredd_var@description     =  long_name_for_variable
      thredd_var@long_name       =  thredd_var@description
      thredd_var@standard_name   = standard_name_for_variable
      thredd_var@coordinates     = "time " + vertical_coordinate_for_variable + "latitude longitude"
      thredd_var@units           = units_for_variable
      ;delete(thredd_var@Isobaric)
      delete(thredd_var@Grib1_Level_Type)
      delete(thredd_var@Grib1_Parameter_Name)
      delete(thredd_var@Grib1_Parameter)
      delete(thredd_var@Grib1_TableVersion)
      delete(thredd_var@Grib1_Subcenter)
      delete(thredd_var@Grib1_Center)
      delete(thredd_var@Grib_Variable_Id)
      delete(thredd_var@coordinates)
      delete(thredd_var@isobaric1)
      delete(thredd_var@_FillValue)
      delete(thredd_var@missing_value)
      delete(thredd_var@grid_mapping)
      print(getFillValue(thredd_var))
      thredd_var@_FillValue           = getFillValue(new((/10/), float))
      thredd_var@coordinates = "time height_above_ground longitude latitude"
      thredd_var@grid_mapping = "Lambert_Conformal"
      printVarSummary(thredd_var)


   delete(latitude@missing_value)
   delete(latitude@grid_mapping)
   delete(latitude@Grib1_Level_Desc)
   delete(latitude@Grib1_Parameter_Name)
   delete(latitude@Grib1_Parameter)
   delete(latitude@Grib1_TableVersion)
   delete(latitude@Grib1_Subcenter)
   delete(latitude@Grib1_Center)
   delete(latitude@Grib_Variable_Id)
   delete(latitude@Grib1_Level_Type)
   delete(latitude@coordinates)
   delete(latitude@time1)
   delete(latitude@time2)
   delete(latitude@_FillValue)
   latitude@units = "degrees north"


   delete(latitude@missing_value)
   delete(latitude@grid_mapping)
   delete(latitude@Grib1_Level_Desc)
   delete(latitude@Grib1_Parameter_Name)
   delete(latitude@Grib1_Parameter)
   delete(latitude@Grib1_TableVersion)
   delete(latitude@Grib1_Subcenter)
   delete(latitude@Grib1_Center)
   delete(latitude@Grib_Variable_Id)
   delete(latitude@Grib1_Level_Type)
   delete(latitude@coordinates)
   delete(latitude@time1)
   delete(latitude@_FillValue)
   latitude@units = "degrees north"


   do t = 0, nt-1, product_interval

      do e = 0, ne-1

         date_decompose = cd_calendar(time(t), -5)

         member = localle + sprinti("%0.2i", (e+1))

         day_dir = sprinti("%0.2i",      date_decompose(0,0)-2000) + \
                   sprinti("%0.2i",      date_decompose(0,1))      + \
                   sprinti("%0.2i",      date_decompose(0,2))

         urlfile1 =  url_root  + \
                     "/"       + \
                     member    + \
                     "/"       + \
                     day_dir   + \
                     "/"       + \
                     member    + \
                     "_"       + \
                     day_dir   + \
                     "00_post.grib"

         urlfile1b =  url_root  + \
                     "/"       + \
                     member    + \
                     "/"       + \
                     day_dir   + \
                     "/"       + \
                     member    + \
                     "_"       + \
                     day_dir   + \
                     "00.grb"

         print(" - "+member+ "_" + day_dir )

         if (isfilepresent(urlfile1)) then

            print("  -- "+urlfile1)

            f = addfile(urlfile1,"r")

            time_thredds = toint(f->time)
              time_thredds!0 = "forecast_time"
              time_thredds&forecast_time = time_thredds

            thredd_var(t, e, {time_thredds}, 0, :, :) = (/ f->$variable_file_id$({time_thredds},{2}, j_min:j_max, i_min:i_max) /)

            if (dimsizes(time_thredds) .lt. 29) then
               print("    !! missing times from "+member+ "_" + day_dir+ " ntime_steps ="+dimsizes(time_thredds) )
            end if

            delete(time_thredds)
            delete(f)

         else if (isfilepresent(urlfile1b)) then

           print("  -- "+urlfile1b)

            f = addfile(urlfile1b,"r")

            time_thredds = toint(f->time)
              time_thredds!0 = "forecast_time"
              time_thredds&forecast_time = time_thredds

            thredd_var(t, e, {time_thredds}, 0, :, :) = (/ f->$variable_file_id$({time_thredds},{2}, j_min:j_max, i_min:i_max) /)

            if (dimsizes(time_thredds) .lt. 29) then
               print("    !! missing times from "+member+ "_" + day_dir+ " ntime_steps ="+dimsizes(time_thredds) )
            end if

            delete(time_thredds)
            delete(f)

         else

            print("  MM "+urlfile1b)

         end if
         end if

      end do
   end do






   system("rm -frv "+file_output_name)
   fout = addfile(file_output_name,"c")
   fout->time = time

   delete(fout)

   print(" Processing NCKS Command:  ncks -D 3 -h --mk_rec_dmn time "+ file_output_name + " temp.nc")
   system(" ncks -D 3 -h --mk_rec_dmn time "+ file_output_name + " temp.nc")
   print(" Processing Move Command:   mv -v temp.nc " + file_output_name)
   system(" mv -v temp.nc " + file_output_name)
   print(" Processing NcDump Command:  $NETCDF/bin/ncdump -h  "+ file_output_name)
   system(" $NETCDF/bin/ncdump -h  "+ file_output_name)
print(file_output_name)
   fout = addfile(file_output_name, "rw")
print(fout)
   fout@title                      = "Big Weather Web WRF Ensemble Files Northern Great Plains"
   fout@institution                = "SD School of Mines"
   fout@source                     = "Big Weather Web Project"
   fout@references                 = "http://www.bigweatherweb.org"
   fout@start_date                 = start_date_string
   fout@end_date                   = end_date_string
   fout@map_projection             = "lambert_conformal_conic"
   fout@dx                         = 20000.0
   fout@dy                         = 20000.0
   fout@dt                         = 90.0
   fout@central_latitude           = 39.5
   fout@central_lontitude          = -98.5
   fout@reference_latitude_1       = 39.5
   fout@reference_latitude_2       = 39.5
   fout@subset_southwest_latitude  = latitude(0,0)
   fout@subset_southwest_longitude = longitude(0,0)
   fout@subset_southeast_latitude  = latitude(0,nx_wrf-1)
   fout@subset_southeast_longitude = longitude(0,nx_wrf-1)
   fout@subset_northwest_latitude  = latitude(ny_wrf-1,0)
   fout@subset_northwest_longitude = longitude(ny_wrf-1,0)
   fout@subset_northeast_latitude  = latitude(ny_wrf-1,nx_wrf-1)
   fout@subset_northeast_longitude          = longitude(ny_wrf-1,nx_wrf-1)
   fout->Lambert_Conformal                  = Lambert_Conformal
   fout->ensemble_member                    = ensemble_member
   fout->forecast_time                      = forecast_time
   fout->$vertical_coordinate_for_variable$ = height_above_ground
   fout->latitude                           = latitude
   fout->longitude                          = longitude
   fout->$standard_name$                    = thredd_var





   delete(fout)





end
