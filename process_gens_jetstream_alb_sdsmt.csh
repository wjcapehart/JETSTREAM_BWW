#!/bin/csh
source ~wjc/.bash_profile

cd /projects/BIG_WEATHER/wjc/JETSTREAM_BWW

location_list=("BWWRAP")

start_date=("2016-01-01"
            "2016-02-01"
            "2016-03-01"
            "2016-04-01"
            "2016-05-01"
            "2016-06-01"
            "2016-07-01"
            "2016-08-01"
            "2016-09-01"
            "2016-10-01"
            "2016-11-01"
            "2016-12-01"
            "2017-01-01"
            "2017-02-01"
            "2017-03-01"
            "2017-04-01"
            "2017-05-01"
            "2017-06-01"
            "2017-07-01"
            "2017-08-01"
            "2017-09-01"
            "2017-10-01")

eom_date=(  "2016-01-31"
            "2016-02-29"
            "2016-03-31"
            "2016-04-30"
            "2016-05-31"
            "2016-06-30"
            "2016-07-31"
            "2016-08-31"
            "2016-09-30"
            "2016-10-31"
            "2016-11-30"
            "2016-12-31"
            "2017-01-31"
            "2017-02-29"
            "2017-03-31"
            "2017-04-30"
            "2017-05-31"
            "2017-06-30"
            "2017-07-31"
            "2017-08-31"
            "2017-09-30"
            "2017-10-31")




number_of_months=${#start_date[@]}
number_of_regions=${#location_list[@]}


echo End of Month Date = $eom_date

echo Number of Month Dates = $number_of_months


number_of_regions=1

# use for loop to read all values and indexes

for (( j=1; j<${number_of_regions}+1; j++ ));
do
   LOCATION=${location_list[$j-1]}
   for (( i=1; i<${number_of_months}+1; i++ ));
   do
      echo "====================================================="
      echo

      echo $LOCATION $i " / " ${number_of_months} " : " ${start_date[$i-1]}

      echo
      echo "-----------------------------------------------------"
      echo

      # command-line syntax should read (for example):
      #  ncl 'scenario="WRFRAP"' 'start_date_string="2016-01-01"' 'end_date_string="2016-02-10"'  script_read_ensembles_from_thredds.ncl

      echo ncl scenario='"'${location_list[$j-1]}'"' \
               start_date_string='"'${start_date[$i-1]}'"'   \
               end_date_string='"'${eom_date[$i-1]}'"'       \
               jetstream_grib_alb_read.ncl

      echo
      echo "- - - - - - - - - - - - - - - - - - - - - - - - - - -"
      echo

      ncl scenario='"'${location_list[$j-1]}'"' \
               start_date_string='"'${start_date[$i-1]}'"'   \
               end_date_string='"'${eom_date[$i-1]}'"'       \
               jetstream_grib_alb_read.ncl >& LOG_${LOCATION}_${start_date[$i-1]}_to_${eom_date[$i-1]}.txt

   done

   echo
   echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   echo


done

echo "We're Out of Here Like Vladimir"
