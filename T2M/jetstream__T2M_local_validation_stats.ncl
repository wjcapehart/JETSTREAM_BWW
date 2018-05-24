


begin

   
   file_output_name       = "./BWW_ALL_VALIDATION_ISOHGT_2016-01-01_to_2018-03-31.nc"
   bulk_ensemble_file_dir = "./"

   ens_school =  (/ "alb", \
                    "csu", \
                    "psu", \
                    "smt", \
                    "ttu", \
                    "und", \
                    "uwm"  /)

   ens_numbers = (/ 13, \
                     2, \
                     9, \
                     3, \
                     8, \
                     4, \
                     9 /)

   product_interval = 8
      product_interval@units = "time_steps"

   lens_start = new( dimsizes(ens_numbers), integer)
      lens_start!0          = "ens_school"
      lens_start&ens_school = ens_school

   lens_end   = lens_start

   large_ensemble_member = new( sum(ens_numbers), string)
      large_ensemble_member!0                      = "large_ensemble_member"
      large_ensemble_member&large_ensemble_member = large_ensemble_member
      large_ensemble_member@description            = "large ensemble member list"
      large_ensemble_member@long_name              = "large ensemble member list"
      k = 0
      do j = 0, dimsizes(ens_school)-1
         lens_start(j) = k
         do i = 0, sum(ens_numbers(j))-1
            large_ensemble_member(k) = ens_school(j) + sprinti("%0.2d",i+1)
            k = 1 + k
         end do
         lens_end(j) = k - 1
         print(ens_school(j)                +  \
               sprinti("%4d",lens_start(j)) +  \
               sprinti("%4d",  lens_end(j))    )
      end do



   f_alb = addfile(bulk_ensemble_file_dir+"BWW_alb_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_csu = addfile(bulk_ensemble_file_dir+"BWW_csu_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_psu = addfile(bulk_ensemble_file_dir+"BWW_psu_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_smt = addfile(bulk_ensemble_file_dir+"BWW_smt_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_ttu = addfile(bulk_ensemble_file_dir+"BWW_ttu_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_und = addfile(bulk_ensemble_file_dir+"BWW_und_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")
   f_uwm = addfile(bulk_ensemble_file_dir+"BWW_uwm_ISOHGT_2016-01-01_to_2018-03-31.nc", "r")

   ; read coordinates

   time               = f_alb->time
   Lambert_Conformal  = f_alb->Lambert_Conformal
   forecast_time      = f_alb->forecast_time(::product_interval)
   forecast_time_orig = f_alb->forecast_time
   isobaric_height    = f_alb->isobaric_height
   y                  = f_alb->y
   x                  = f_alb->x
   latitude           = f_alb->latitude
   longitude          = f_alb->longitude

   time_alb = f_alb->time
   time_csu = f_csu->time
   time_psu = f_psu->time
   time_smt = f_smt->time
   time_ttu = f_ttu->time
   time_und = f_und->time
   time_uwm = f_uwm->time

   n_t   = dimsizes(time)
   n_ens = sum(ens_numbers)
   n_f   = dimsizes(forecast_time)
   n_p   = dimsizes(isobaric_height)
   n_y   = dimsizes(y)
   n_x   = dimsizes(x)

   ; create real-world time vector

   local_clock_time = new( (/ n_t, n_f /), double)
      local_clock_time!0             = "time"
      local_clock_time!1             = "forecast_time"
      local_clock_time&time          = time
      local_clock_time&forecast_time = forecast_time
      local_clock_time@units         = time@units
      local_clock_time@description   = "actual time at forecast product time"
      local_clock_time@long_name     = "actual time at forecast product time"
      local_clock_time@standard_name = "time"

      do i = 0, dimsizes(forecast_time)-1
         local_clock_time(:,i) = time(:) + forecast_time(i) / 24.
      end do

   ; Variables for Archiving

   inventory = new( (/ n_t, n_ens, n_f, n_p/), byte)
      inventory!0                      = "time"
      inventory!1                      = "large_ensemble_member"
      inventory!2                      = "forecast_time"
      inventory!3                      = "isobaric_height"
      inventory&time                   = time
      inventory&large_ensemble_member = large_ensemble_member
      inventory&forecast_time          = forecast_time
      inventory&isobaric_height        = isobaric_height
      inventory@description            = "Inventory of Valid Forecast-Validation Pair"
      inventory@long_name              = "Inventory of Valid Forecast-Validation Pair"
      inventory@units                  = ""
      inventory@comment1               = "true of 2-d spatial array is not missing for both forecast and valid"
      inventory@comment2               = "1=true, 0=false"
      inventory@cell_method            = "x,y: is_missing==FALSE"



   variable = new( (/ n_t, n_f, n_p /), float)
      variable!0               = "time"
      variable!1               = "forecast_time"
      variable!2               = "isobaric_height"
      variable&time            = time
      variable&forecast_time   = forecast_time
      variable&isobaric_height = isobaric_height

   variable2d = new( (/ n_ens, n_f, n_p, n_y, n_x /), float)
      variable2d!0                      = "large_ensemble_member"
      variable2d!1                      = "forecast_time"
      variable2d!2                      = "isobaric_height"
      variable2d!3                      = "y"
      variable2d!4                      = "x"
      variable2d&large_ensemble_member = large_ensemble_member
      variable2d&forecast_time          = forecast_time
      variable2d&isobaric_height        = isobaric_height
      variable2d&y                      = y
      variable2d&x                      = x

      variablet_time_ens = new( (/ n_t, n_ens, n_f, n_p /), float)
         variablet_time_ens!0                      = "time"
         variablet_time_ens!1                      = "large_ensemble_member"
         variablet_time_ens!2                      = "forecast_time"
         variablet_time_ens!3                      = "isobaric_height"
         variablet_time_ens&time                   = time
         variablet_time_ens&large_ensemble_member = large_ensemble_member
         variablet_time_ens&forecast_time          = forecast_time
         variablet_time_ens&isobaric_height        = isobaric_height



   stdev_f                       = variablet_time_ens
      stdev_f@description        = "mean ensemble forecast geopotential height spatial standard deviation"
      stdev_f@long_name          = "mean ensemble forecast geopotential height spatial standard deviation"
      stdev_f@standard_name      = "geopotential_height"
      stdev_f@cell_method        = "x,y: stdev"
      stdev_f@units              = "m"

   stdev_v                       = variablet_time_ens
      stdev_v@description        = "mean ensemble validation geopotential height spatial standard deviation"
      stdev_v@long_name          = "mean ensemble validation geopotential height spatial standard deviation"
      stdev_v@standard_name      = "geopotential_height"
      stdev_v@cell_method        = "x,y: stdev"
      stdev_v@units              = "m"

   stdev_ens_fx                     = variable
      stdev_ens_fx@description      = "spatial mean forecast ensemble gepotential height standard deviation"
      stdev_ens_fx@long_name        = "spatial mean forecast ensemble gepotential height standard deviation"
      stdev_ens_fx@standard_name    = "geopotential_height"
      stdev_ens_fx@cell_method      = "large_ensemble_member: stdev; x,y: mean"
      stdev_ens_fx@units            = "m"

   stdev_ens_val                     = variable
      stdev_ens_val@description      = "spatial mean validation ensemble gepotential height standard deviation"
      stdev_ens_val@long_name        = "spatial mean validation ensemble gepotential height standard deviation"
      stdev_ens_val@standard_name    = "geopotential_height"
      stdev_ens_val@cell_method      = "large_ensemble_member: stdev; x,y: mean"
      stdev_ens_val@units            = "m"

   rmse_through_ens                     = variable
      rmse_through_ens@description      = "spatial mean forecast gepotential height rmse"
      rmse_through_ens@long_name        = "spatial mean forecast gepotential height rmse"
      rmse_through_ens@standard_name    = "geopotential_height"
      rmse_through_ens@cell_method      = "large_ensemble_member,x,y: rmse"
      rmse_through_ens@units            = "m"

   corr_through_ens                     = variable
      rmse_through_ens@description      = "spatial mean forecast gepotential height r"
      rmse_through_ens@long_name        = "spatial mean forecast gepotential height r"
      rmse_through_ens@standard_name    = "geopotential_height"
      rmse_through_ens@cell_method      = "large_ensemble_member,x,y: coorelation"
      rmse_through_ens@units            = "m"



   rmse                          = variablet_time_ens
      rmse@description           = "spatial mean forecast ensemble gepotential height rmse"
      rmse@long_name             = "spatial mean forecast ensemble gepotential height rmse"
      rmse@standard_name         = "geopotential_height"
      rmse@cell_method           = "x,y: rmse"
      rmse@units                 = "m"

   corr                          = variablet_time_ens
      corr@description           = "spatial mean forecast ensemble gepotential height correlation"
      corr@long_name             = "spatial mean forecast ensemble gepotential height correlation"
      corr@standard_name         = "geopotential_height"
      corr@cell_method           = "x,y: corr"
      corr@units                 = ""




      bias_fx_v_valid_by_ensemble_member                          = variablet_time_ens
         bias_fx_v_valid_by_ensemble_member@description           = "spatial mean forecast ensemble gepotential height bias"
         bias_fx_v_valid_by_ensemble_member@long_name             = "spatial mean forecast ensemble gepotential height bias"
         bias_fx_v_valid_by_ensemble_member@standard_name         = "geopotential_height"
         bias_fx_v_valid_by_ensemble_member@cell_method           = "x,y: bias"
         bias_fx_v_valid_by_ensemble_member@units                 = "m"

         bias_fx_v_valid_through_all_ensembles                     = variable
            bias_fx_v_valid_through_all_ensembles@description      = "spatial mean forecast gepotential height bias"
            bias_fx_v_valid_through_all_ensembles@long_name        = "spatial mean forecast gepotential height bias"
            bias_fx_v_valid_through_all_ensembles@standard_name    = "geopotential_height"
            bias_fx_v_valid_through_all_ensembles@cell_method      = "large_ensemble_member,x,y: bias"
            bias_fx_v_valid_through_all_ensembles@units            = "m"


   ; holding arrays for processing

   forecast = new( (/ n_ens, n_f, n_p, n_y, n_x /), float)
      forecast!0                      = "large_ensemble_member"
      forecast!1                      = "forecast_time"
      forecast!2                      = "isobaric_height"
      forecast!3                      = "y"
      forecast!4                      = "x"
      forecast&large_ensemble_member = large_ensemble_member
      forecast&forecast_time          = forecast_time
      forecast&isobaric_height        = isobaric_height
      forecast&y                      = y
      forecast&x                      = x

   validation  = new( (/ n_ens, n_f, n_p, n_y, n_x /), float)
      validation!0                      = "large_ensemble_member"
      validation!1                      = "forecast_time"
      validation!2                      = "isobaric_height"
      validation!3                      = "y"
      validation!4                      = "x"
      validation&large_ensemble_member = large_ensemble_member
      validation&forecast_time          = forecast_time
      validation&isobaric_height        = isobaric_height
      validation&y                      = y
      validation&x                      = x

   ;

   do t = 0, n_t-1;

      yyyymmddhh = cd_calendar(time(t), -5)

      forecast_time_string    = sprinti( "%0.4d",yyyymmddhh(0,0)) + "-" + \
                                sprinti( "%0.2d",yyyymmddhh(0,1)) + "-" + \
                                sprinti( "%0.2d",yyyymmddhh(0,2)) + "_" + \
                                sprinti( "%0.2d",yyyymmddhh(0,3))

      print("---- " + forecast_time_string)


      do h = 0, n_f-1 ;

         yyyymmddhh = cd_calendar(local_clock_time(t,h), -5)

         validation_time_string      = sprinti( "%0.4d",yyyymmddhh(0,0)) + "-" + \
                                       sprinti( "%0.2d",yyyymmddhh(0,1)) + "-" + \
                                       sprinti( "%0.2d",yyyymmddhh(0,2)) + "_" + \
                                       sprinti( "%0.2d",yyyymmddhh(0,3))

         fx_h  := ind( forecast_time_orig .eq. forecast_time(h) )


         lens = 0
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_alb->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)
         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_csu->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)
         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_psu->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)
         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_smt->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)
         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_ttu->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)

         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_und->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)
         lens = lens+1
         ;print(" pulling forecast for " + ens_school(lens))
         forecast(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_uwm->geopotential_height( time|t,               \
                                                                                                ensemble_member|:,    \
                                                                                                forecast_time|fx_h,   \
                                                                                                isobaric_height|:,    \
                                                                                                y|:,                  \
                                                                                                x|:)                  /)




            if (local_clock_time(t,h) .le. max(time)) then

               t_fx   := ind( time .eq. local_clock_time(t,h))

               print("------- " + forecast_time_string + "_F" + sprinti("%0.2d", forecast_time(h)) + \
                            " " + validation_time_string)


               lens = 0
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_alb->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_csu->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_psu->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_smt->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_ttu->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_und->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)
               lens = lens+1
               ;print(" pulling verification for " + ens_school(lens))
               validation(lens_start(lens):lens_end(lens), h, :, :, :) = (/ f_uwm->geopotential_height( time|t_fx,         \
                                                                                                        ensemble_member|:, \
                                                                                                        forecast_time|0,   \
                                                                                                        isobaric_height|:, \
                                                                                                        y|:,               \
                                                                                                        x|:)               /)

            end if



               do p = 0, n_p-1

                  do ens = 0, n_ens-1
                     deleteme_f     = ndtooned( forecast(  ens,h,p,:,:) )
                     deleteme_v     = ndtooned( validation(ens,h,p,:,:) )
                     corr( t, ens, h, p) =  escorc(deleteme_f,deleteme_v)
                  end do
                  corr_through_ens(t,h,p) = escorc(ndtooned( forecast(  :,h,p,:,:) ),      \
                                                   ndtooned( validation(:,h,p,:,:) ) )


               end do





      end do



      ; "x,y: stdev; large_ensemble_member : mean"
      stdev_f( t, :, :, :) =  dim_stddev_n_Wrap(forecast(  :,:,:,:,:), (/ 3,4 /) )
      stdev_v( t, :, :, :) =  dim_stddev_n_Wrap(validation(:,:,:,:,:), (/ 3,4 /) )

      rmse( t, :, :, :) =  dim_rmsd_n_Wrap(forecast(  :,:,:,:,:),  \
                                           validation(:,:,:,:,:), (/ 3,4 /) )

      inventory(t, :, :, :) =  tobyte(   where(ismissing(rmse( t, :, :, :)),0,1)   )

      stdev_ens_fx( t, :, :)  =  dim_avg_n_Wrap( dim_stddev_n_Wrap(forecast(  :,:,:,:,:), 0),  (/ 2,3 /) )
      stdev_ens_val( t, :, :) =  dim_avg_n_Wrap( dim_stddev_n_Wrap(validation(:,:,:,:,:), 0),  (/ 2,3 /) )


      rmse_through_ens( t, :, :) = dim_rmsd_n_Wrap(forecast(  forecast_time|:, isobaric_height|:, large_ensemble_member|:, y|:, x|:),  \
                                                   validation(forecast_time|:, isobaric_height|:, large_ensemble_member|:, y|:, x|:), (/ 2,3,4 /) )


      bias_raw = forecast(  forecast_time|:, isobaric_height|:, large_ensemble_member|:, y|:, x|:)

      bias_raw(:,:,:,:,:)  =  forecast( forecast_time|:, isobaric_height|:, large_ensemble_member|:, y|:, x|:) - \
                             validation(forecast_time|:, isobaric_height|:, large_ensemble_member|:, y|:, x|:)


      bias_fx_v_valid_through_all_ensembles( t, :, :)     =  dim_avg_n_Wrap( bias_raw,  (/ 2,3,4 /) )
      bias_fx_v_valid_by_ensemble_member( t, :, :, :)     =  dim_avg_n_Wrap( bias_raw(large_ensemble_member|:, forecast_time|:, isobaric_height|:,  y|:, x|:),  (/  3,4  /) )


   end do

   setfileoption("nc", "Format",          "NetCDF4")
   setfileoption("nc", "CompressionLevel",        6)

   system("rm -frv " + file_output_name)
   fout = addfile(file_output_name,"c")

      fout@title                        = f_smt@title
      fout@institution                 = f_smt@institution
      fout@source                      = f_smt@source
      fout@references                  = f_smt@references
      fout@title                       = f_smt@title
      fout@start_date                  = "2016-01-01"
      fout@end_date                    = "2018-03-31"
      fout@regional_labnel             = "WRFRAP"
      fout@map_projection              = f_smt@map_projection
      fout@central_latitude            = f_smt@central_latitude
      fout@central_lontitude           = f_smt@central_lontitude
      fout@reference_latitude_1        = f_smt@reference_latitude_1
      fout@reference_latitude_2        = f_smt@reference_latitude_2
      fout@dx                          = f_smt@dx
      fout@dy                          = f_smt@dy
      fout@dt                          = f_smt@dt
      fout@subset_southwest_latitude   = f_smt@subset_southwest_latitude
      fout@subset_southwest_longitude  = f_smt@subset_southwest_longitude
      fout@subset_southeast_latitude   = f_smt@subset_southeast_latitude
      fout@subset_southeast_longitude  = f_smt@subset_southeast_longitude
      fout@subset_northwest_latitude   = f_smt@subset_northwest_latitude
      fout@subset_northwest_longitude  = f_smt@subset_northwest_longitude
      fout@subset_northeast_latitude   = f_smt@subset_northeast_latitude
      fout@subset_northeast_longitude  = f_smt@subset_northeast_longitude

      fout->time                       = time
      fout->large_ensemble_member     = large_ensemble_member
      fout->forecast_time              = forecast_time
      fout->isobaric_height            = isobaric_height
      fout->Lambert_Conformal          = Lambert_Conformal
      fout->x                          = x
      fout->y                          = y
      fout->latitude                   = latitude
      fout->longitude                  = longitude
      fout->inventory                  = inventory
      fout->stdev_forecast_by_ensemble_member             = stdev_f
      fout->stdev_validation_by_ensemble_member           = stdev_v
      fout->correlation_fx_v_valid_through_all_ensembles  = corr_through_ens
      fout->correlation_fx_v_valid_by_ensemble_member     = corr
      fout->rmse_fx_v_valid_through_all_ensembles         = rmse_through_ens
      fout->rmse_fx_v_valid_by_ensemble_member            = rmse

      fout->stdev_forecast_through_all_ensembles          = stdev_ens_fx
      fout->stdev_validation_through_all_ensembles        = stdev_ens_val


      fout->bias_fx_v_valid_through_all_ensembles = bias_fx_v_valid_through_all_ensembles
      fout->bias_fx_v_valid_by_ensemble_member    = bias_fx_v_valid_by_ensemble_member

   delete(fout)



end
