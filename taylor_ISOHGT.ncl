

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "./taylor_stats.ncl"
load "./taylor_stats.ncl"
load "./taylor_diagram.ncl"

begin

   parameters = (/ "ISOHGT" /)
   school     = (/ "alb", \
                  "csu", \
                  "psu", \
                  "smt", \
                  "ttu", \
                  "und", \
                  "uwm"  /)

   f = addfile("./ISOHGT/BWW_ALL_VALIDATION_ISOHGT_2016-01-01_to_2018-03-31.nc","r")

   large_ensemble_member = f->large_ensemble_member
   time                  = f->time
   forecast_time         = f->forecast_time

   delete(f)


   n_param = dimsizes(parameters)
   n_ens   = dimsizes(large_ensemble_member)
   n_time  = dimsizes(time)
   n_fx    = dimsizes(forecast_time)
   n_month = 2*12 + 3

   yymmdd = cd_calendar(time,-5)

   yr_time = yymmdd(:,0)
   mo_time = yymmdd(:,1)
   dy_time = yymmdd(:,2)

   year = 2016
   month = 1


   bias_daily = new(  (/ n_time, n_ens, n_fx, n_param /)  , "float")
      bias_daily!0                      = "time"
      bias_daily&time                   =  time
      bias_daily!1                      = "large_ensemble_member"
      bias_daily&large_ensemble_member  =  large_ensemble_member
      bias_daily!2                      = "forecast_time"
      bias_daily&forecast_time          =  forecast_time
      bias_daily!3                      = "parameters"
      bias_daily&parameters             =  parameters

  stdf_daily = bias_daily
  stdv_daily = bias_daily
  coef_daily = bias_daily
  rmse_daily = bias_daily

  label_daily = cd_string(time, "%Y %c %D")



  do p = 0, n_param-1
    f = addfile("./" + parameters(p) + "/BWW_ALL_VALIDATION_"+parameters(p)+"_2016-01-01_to_2018-03-31.nc","r")

     bias_daily(:,:,:,p) = f->bias_fx_v_valid_by_ensemble_member(:,:,:,0)
     stdf_daily(:,:,:,p) = f->stdev_forecast_by_ensemble_member(:,:,:,0)
     stdv_daily(:,:,:,p) = f->stdev_validation_by_ensemble_member(:,:,:,0)
     coef_daily(:,:,:,p) = f->correlation_fx_v_valid_by_ensemble_member(:,:,:,0)
     rmse_daily(:,:,:,p) = f->rmse_fx_v_valid_by_ensemble_member(:,:,:,0)

  end do

  time_monthly = calculate_monthly_values(time,       "avg", 0, False)
  bias_monthly = calculate_monthly_values(bias_daily, "avg", 0, False)
  stdf_monthly = calculate_monthly_values(stdf_daily, "avg", 0, False)
  stdv_monthly = calculate_monthly_values(stdv_daily, "avg", 0, False)
  coef_monthly = calculate_monthly_values(coef_daily, "avg", 0, False)
  rmse_monthly = calculate_monthly_values(rmse_daily, "avg", 0, False)
  stdr_monthly = stdf_monthly
  stdr_monthly(:,:,:,:) = (/  stdf_monthly / stdv_monthly  /)

  label_monthly = cd_string(time_monthly, "%Y %c")


  wks   = gsn_open_wks("pdf","taylor_plots")      ; send graphics to PNG file

  case = forecast_time(1:n_fx-1)
  var  = large_ensemble_member

  p = 0
  m = 0
  printVarSummary(stdr_monthly(m,:,1:n_fx-1,p))

  do p = 0, n_param-1
    do m = 0, n_month-1

      heading_string = "BWW NGP 500-hPa Heights " + label_monthly(m)
      print(""+heading_string)
      ty_opt   = True                           ; taylor diagram with options

      ty_opt@Markers       = new( n_ens, "integer", 16)         ; make all solid fill
      ty_opt@Colors        = new( n_ens, "string", "black")
      ty_opt@Colors(0:2)    = (/ "blue", "green", "red"/)
      ty_opt@varLabels     = var
      ty_opt@caseLabels    = "F"+case

      ty_opt@varLabelsYloc = 2.; 1.5                ; Move location of variable labels [default 0.45]
      ty_opt@caseLabelsFontHeightF = 0.07      ; make slight larger   [default=0.12 ]
      ty_opt@varLabelsFontHeightF  = 0.0075      ; make slight smaller  [default=0.013]

      ty_opt@tiMainString  = heading_string          ; title
      ty_opt@stnRad        = (/ 0.5, 1.5 /)     ; additional standard radii
      ty_opt@ccRays        = (/ 0.6, 0.9 /)     ; correllation rays
      ty_opt@centerDiffRMS = True               ; RMS 'circles'


      ratio := stdr_monthly(time|m, forecast_time|:, large_ensemble_member|:, parameters|p)
      cc    := coef_monthly(time|m, forecast_time|:, large_ensemble_member|:, parameters|p)



          plot  = taylor_diagram(wks,ratio(1:n_fx-1,:),cc(1:n_fx-1,:),ty_opt)

end do

  end do


end
