#!/bin/bash

display_usage() {
  echo -e "\nUsage:\n\n$0 [filename] \n"
}

select_month_year() {
  month=$1
  year=$2
  huge_file=$3
  out_file=$year-$month.csv
  echo "Writing $out_file.."
  echo 'ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2' > $out_file
  cat $huge_file | egrep "$month.* $year " >> $out_file
  dos2unix $out_file
}

if [ $# -eq 0 ]
then
  display_usage
  exit 1
fi

huge_file=$1

echo "Splitting $huge_file.."

for year in 2020
do
  for month in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
  do
    select_month_year $month $year $huge_file
  done
done

echo "Done"
