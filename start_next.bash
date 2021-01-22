#!/bin/bash
# This file starts the next or given day's challenge for the Advent of Code

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

programs=("ruby" "julia" "python")
extensions=("rb" "jl" "py")

i=$(($day%3))
prog=${programs[i]}
ext=${extensions[i]}

force=""
input_day=""
input_prog=""
while [ ! -z "$1" ]; do
  if [[ "$1" == "-p" ]] || [[ "$1" == "--program" ]]; then
    input_prog="$2"
    shift
    echo "Input program: $input_prog"
  elif [[ "$1" == "-f" ]] || [[ "$1" == "--force" ]]; then
    force="true"
  else
    input_day=$1
    echo "Input day: $input_day"
  fi
  shift
done

if [ -n "$input_prog" ]; then
  for ((i=0;i<${#programs[@]};i++))
  do
    if [ "$input_prog" == "${programs[i]}" ]; then
      prog=$input_prog
      ext=${extensions[i]}
    fi
  done
fi

skip=false
# # set custom day if given and it is not yet finished
if [[ $input_day =~ [0-9]+ ]] && [ $((1<=$input_day && $input_day<=25)) == 1 ];
then
  if [ -f $timefile ]; then
    # Check if part 2 for the given day is not yet finished
    if [ $(egrep -c -e "^$input_day,(1\+)?2,.*$" $timefile) == 0 ]; then
      day=$input_day
    else
      echo "Day $input_day already completed..."
    fi
  else
    day=$input_day
  fi
elif [ $(($day > 25)) == 1 ] && [ -z $input_day ]; then
  echo "Day required now..."
  echo "Usage: . start_next.bash [-f|--force] [-p|--program ruby|julia|python] day"
  skip=true
elif [ -n "$input_day" ]; then
  echo "Invalid day given: $input_day"
fi

if [ -z "$force" ]; then
  read -p $"Work on Day $day using $prog? (y/n)"$'\n' reply
  [[ $reply =~ ^[Yy].*$ ]] || skip=true # skip if reply is No
  [ $skip == true ] && echo "Stopping..."
fi

if [ $skip == false ]; then

echo "Working on Day $day using $prog..."
dir="Day$day"
codefile="Day$day.$ext"

mkdir -p $dir
mv $finish $dir

[ ! -f "$dir/$codefile" ] && cp "Templates/${prog}_template.$ext"\
   "$dir/$codefile" # Copy template if the file doesn't exist
# cd $dir

date > "$dir/start"

echo "Run '$dir/finish_day.bash [-a OR --all]' to complete solution."

tester="$dir/run.bash"
echo '#!/bin/bash' > "$tester"
echo "$prog $codefile" '$@' >> "$tester"
chmod +x "$tester"

code "$dir/$codefile" # start editing

fi

fi

fi

else

unfinished=`dirname */$finish`
day=${unfinished//[!0-9]/}
echo "Cannot start until Day $day is completed!"
echo "Run '$tester [filename]' to test program..."
echo "Run '$dir/finish_day.bash [-a OR --all]' in '$unfinished/' to finish first..."

fi
