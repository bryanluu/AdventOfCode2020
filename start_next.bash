#!/bin/bash
# This file should be called using `source` rather than bash

advent_year=2020
finish="finish_day.bash"
if [ -f $finish ]
then

year=$(date +%Y)
month=`date +%m`
if ([ $year == $advent_year ] && [ $month != 12 ])\
   || [ $(($year < $advent_year)) == 1 ] # Too early
then
echo "Advent of Code $advent_year hasn't started yet!"
else

today=`date +%d`
days=`ls -d Day* | wc -l`
# remove any leading zeroes
days=${days#0}
today=${today#0}
hour=$(date +%H)
if [ $year == $advent_year ] && ([ $(($days > $today)) == 1 ] || ([ $today == $days ] && [ $(($hour < 21)) == 1 ]))
then
echo "Too early! Wait until December $(($days)) $advent_year"\
", 9pm PST for the next challenge."
else

day=$(($days+1))

timefile="times.csv"

skip=false
# # set custom day if given and it is not yet finished
if [[ $1 =~ [0-9]+ ]] && [ $((8<=$1 && $1<=25)) == 1 ];
then
  if [ -f $timefile ]; then
    # Check if part 2 for the given day is not yet finished
    if [ $(egrep -c -e "^$1,(1\+)?2,.*$" $timefile) == 0 ]; then
      day=$1
    else
      echo "Day $1 already completed..."
      read -p $"Continue onto Day $day?"$'\n' reply
      [[ $reply =~ ^[Yy].*$ ]] || skip=true # skip if reply is No
      [ $skip == true ] && echo "Stopping..."
    fi
  else
    day=$1
  fi
elif [ $(($day > 25)) == 1 ] && [ -z $1 ]; then
  echo "Day required now..."
  echo "Usage: . start_next.bash day"
  skip=true
else
  echo "Invalid day given: $1"
fi

if [ $skip == false ]; then

echo "Working on Day $day..."
dir="Day$day"
case $(($day%3)) in
  0) prog="ruby"; ext="rb";;
  1) prog="julia"; ext="jl";;
  2) prog="python"; ext="py";;
esac
codefile="Day$day.$ext"

mkdir -p $dir
mv $finish $dir

[ ! -f "$dir/$codefile" ] && cp "Templates/${prog}_template.$ext"\
   "$dir/$codefile" # Copy template if the file doesn't exist
cd $dir

date > start

echo "Run './finish_day.bash [-a OR --all]' to complete solution."

echo '#!/bin/bash' > run.bash
echo "$prog $codefile" '$1' >> run.bash
chmod +x run.bash

code $codefile # start editing

fi

fi

fi

else

unfinished=`dirname */$finish`
day=${unfinished//[!0-9]/}
echo "Cannot start until Day $day is completed!"
echo "Run './run.bash [filename]' to test program..."
echo "Run './finish_day.bash [-a OR --all]' in '$unfinished/' to finish first..."

fi
