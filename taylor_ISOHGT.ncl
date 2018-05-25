

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin

   parameters = (/ "ISOHGT" /)
   school     = (/ "alb", \
                  "csu", \
                  "psu", \
                  "smt", \
                  "ttu", \
                  "und", \
                  "uwm" )

   f_isohgt = addfile("./ISOHGT/BWW_ALL_VALIDATION_ISOHGT_2016-01-01_to_2018-03-31.nc","r")

   large_ensemble_member = f->large_ensemble_member
   time                  = f->time
   forecast_time         = f->forecast_time



   n_param = dimsizes(parameters)
   n_ens   = dimsizes(large_ensemble_member)
   n_time  = dimsizes(time)
   n_fx    = dimsizes(forecast_time)
   n_month = 3*12 + 3

   yymmdd = cd_calendar(time,-5)

   yr_time = cd_calendar(:,0)
   mo_time = cd_calendar(:,1)
   dy_time = cd_calendar(:,2)

   year = 2016
   monnth = 1

   time_monthly  = new(n_month, "double")

   do yymm = 0, n_month-1
      time_monthly(yymm) = cd_inv_calendar(year,  \
                                           month, \
                                           15,    \
                                            0,    \
                                            0,    \
                                            0,    \
                                            0)
      month = month + 1
      if (month .eq. 13) then
         month = 1
         year = year + 1
      end if

   end do
   label_monthly = cd_string(time_monthly, \
                             "%Y %c")


   









end
