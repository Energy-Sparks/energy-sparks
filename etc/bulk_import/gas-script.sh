
echo "Split Gas file into  MSN file"
awk -F ',' 'NR==1{h=$0; next};!seen[$56]++{f=$56".csv"; print h > f};{f=$56".csv"; print >> f; close(f)}' BANES_Energy_Usage_Gas.csv

echo "Now sort each file"
for f in *.csv
do
	echo "Sorting - $f"
  sort -n -t"," -k2.7,2.10 -k2.1,2.2 -k2.4,2.5 -o $f $f
done
