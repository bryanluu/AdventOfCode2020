#!/bin/bash
# This file should be called using `source` rather than bash

finish="finish_day.bash"
if [ -f $finish ]
then

month=`date +%m`
if [ $month != 12 ] # Invalid month
then
echo "Invalid month!"
else

today=`date +%d`
days=`ls -d Day* | wc -l`
# remove any leading zeroes
days=${days#0}
today=${today#0}
hour=$(date +%H)
if [ $(($days > $today)) == 1 ] || ([ $today == $days ] && [ $(($hour < 21)) == 1 ])
then
echo "Too early! Wait until December $(($days)), 9pm PST for the next challenge."
elif [ $today -ge 25 ]
then
echo "Advent already finished! (Good job)"
else


day=$(($days+1))
echo "Starting Day $day..."
newdir="Day$day"
case $(($day%3)) in
  0) prog="ruby"; ext="rb";;
  1) prog="julia"; ext="jl";;
  2) prog="python"; ext="py";;
esac
newfile="Day$day.$ext"

mkdir $newdir
mv $finish $newdir
cp "Templates/${prog}_template.$ext" "$newdir/$newfile"
cd $newdir

date > start

echo "Run './finish_day.bash' to complete solution."

echo '#!/bin/bash' > run
echo "$prog $newfile" >> run
chmod +x run

code $newfile # start editing

fi

fi

else

unfinished=`dirname */$finish`
day=${unfinished//[!0-9]/}
echo "Cannot start until Day $day is completed!"
echo "Run './finish_day.bash' in '$unfinished/' to finish first..."

fi
