load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  directory = "./"

  url_root  = "http://149.165.157.204/thredds/dodsC/archive"

 ;start_date_string = "2017-02-01"
 ; end_date_string   = "2017-02-28"

 setfileoption("nc", "Format",          "NetCDF4")
 setfileoption("nc", "CompressionLevel",        6)
  ;;;localle = "alb" ; change this one...

  title_string      = "bww_" + localle + "_500mb_"
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

  initital_setup_url = "http://149.165.157.204/thredds/dodsC/archive/alb10/180319/alb10_18031900_post.grib"

  f = addfile(initital_setup_url, "r")


  latw = f->$"latitude_-90_to_and90_surface"$(0,:,:)
  lonw = f->$"east_longitude_0-360_surface"$(0,:,:)

  ;;; local region to clip
  lat_min = 34. ; degrees North
  lat_max = 55. ; degrees North

  lon_min = 247. ; degrees East
  lon_max = 268. ; degrees East

  wrf_region_ind = region_ind(latw,lonw,lat_min,lat_max,lon_min,lon_max)

  i_min = wrf_region_ind(2)
  i_max = wrf_region_ind(3)
  j_min = wrf_region_ind(0)
  j_max = wrf_region_ind(1)

  delete(latw)
  delete(lonw)

  longitude = f->$"latitude_-90_to_and90_surface"$(0, j_min:j_max, i_min:i_max)
  latitude  = f->$"east_longitude_0-360_surface"$( 0, j_min:j_max, i_min:i_max)

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

   height_above_ground                 = (/ 2. /)
   height_above_ground!0               = "height_above_ground"
   height_above_ground&height_above_ground = height_above_ground
   height_above_ground@description     = "Specified height level above ground"
   height_above_ground@long_name       =  height_above_ground@description
   height_above_ground@standard_name   = "height"
   height_above_ground@positive        = "up"
   height_above_ground@unit            = "m"
   height_above_ground@axis            = "Z"




   time = fspan(start_time_arch, end_time_arch, nt)
      time@description   = "time"
      time@long_name     = "time"
      time@standard_name = "time"
      time@calendar      = "standard"
      time@units         = time_units
      time!0             = "time"
      time&time          = time


   Lambert_Conformal = toint(0)
      Lambert_Conformal!0 =  "ncl_scalar"
      Lambert_Conformal@grid_mapping_name = "lambert_conformal_conic";
      Lambert_Conformal@standard_parallel = 39.5;
      Lambert_Conformal@longitude_of_central_meridian = 360.0-98.50000762939453;
      Lambert_Conformal@latitude_of_projection_origin = 39.5;

   z_500_arch = new((/ nt, ne, nt_wrf, 1, ny_wrf, nx_wrf /), float)
      z_500_arch!0               = "time"
      z_500_arch!1               = "ensemble_member"
      z_500_arch!2               = "forecast_time"
      z_500_arch!3               = "height_above_ground"
      z_500_arch!4               = "y"
      z_500_arch!5               = "x"
      z_500_arch&time            = time
      z_500_arch&ensemble_member = ensemble_member
      z_500_arch&forecast_time   = forecast_time
      z_500_arch&height_above_ground = height_above_ground
      z_500_arch@description     = "2-m Air Temperature"
      z_500_arch@long_name       =  z_500_arch@description
      z_500_arch@standard_name   = "air_temperature"
      z_500_arch@coordinates     = "time height_above_ground latitude longitude"
      z_500_arch@units           = "m"
      ;delete(z_500_arch@Isobaric)
      delete(z_500_arch@Grib1_Level_Type)
      delete(z_500_arch@Grib1_Parameter_Name)
      delete(z_500_arch@Grib1_Parameter)
      delete(z_500_arch@Grib1_TableVersion)
      delete(z_500_arch@Grib1_Subcenter)
      delete(z_500_arch@Grib1_Center)
      delete(z_500_arch@Grib_Variable_Id)
      delete(z_500_arch@coordinates)
      delete(z_500_arch@isobaric1)
      delete(z_500_arch@_FillValue)
      delete(z_500_arch@missing_value)
      delete(z_500_arch@grid_mapping)
      print(getFillValue(z_500_arch))
      z_500_arch@_FillValue           = getFillValue(new((/10/), float))
      z_500_arch@coordinates = "time height_above_ground longitude latitude"
      z_500_arch@grid_mapping = "Lambert_Conformal"
      printVarSummary(z_500_arch)


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

            z_500_arch(t, e, {time_thredds}, 0, :, :) = (/ f->Geopotential_height_isobaric({time_thredds},{500}, j_min:j_max, i_min:i_max) /)

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

            z_500_arch(t, e, {time_thredds}, 0, :, :) = (/ f->Temperature_height_above_ground({time_thredds},{2}, j_min:j_max, i_min:i_max) /)

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
   fout@subset_northeast_longitude = longitude(ny_wrf-1,nx_wrf-1)
   fout->Lambert_Conformal         = Lambert_Conformal
   fout->ensemble_member           = ensemble_member
   fout->forecast_time             = forecast_time
   fout->height_above_ground           = height_above_ground
   fout->latitude                  = latitude
   fout->longitude                 = longitude
   fout->air_temperature       = z_500_arch





   delete(fout)





end
