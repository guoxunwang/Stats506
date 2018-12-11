#!/bin/bash

##Stats 506, F18, Problem Set 1
##Question 1

###Part A
####i Response to part one
echo "Response to Part A part one:"

cut -d, -f2 ./recs2015_public_v3.csv|grep 3|wc -l

####ii Response to part two
echo "Response to Part A part two:"
echo "Created a .csv.gz file containing only DOEID, NWEIGHT, and BRRWT1-BRRWT96 for part two."
cut -d, -f1,475-571 ./recs2015_public_v3.csv|gzip>recs2015_q1.csv.gz

###Part B
####i Response to part one
echo "Response to part B part one:"
for i in $(sed 1d ./recs2015_public_v3.csv|cut -d, -f2|sort|uniq)
do
  echo "observations within region" $i
  cut -d, -f2 ./recs2015_public_v3.csv|grep $i|wc -l
done

####ii Response to part two
sed 1d ./recs2015_public_v3.csv|cut -d, -f2,3|sort|uniq|sort -V|tr "," " ">region_division.txt
sed -i '1i Regionc Division' region_division.txt

####contents of the file
echo "Response to Part B part two:"
echo "set up a .txt file and contents of the file are:"
cat region_division.txt