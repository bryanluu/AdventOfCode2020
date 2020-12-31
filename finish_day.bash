#!/bin/bash

end=$(date)

folder=${PWD##*/}
if [ ${folder//[0-9]/} != Day ]
then
echo "Cannot run this yet! Start by running '. start_next.bash [day]' first..."
exit 1
else

day=${folder//[!0-9]/}

timefile="../times.csv"
if [ ! -f $timefile ]
then

echo "Day,Part(s),Start,End,Notes" > $timefile

fi

# get number of parts already saved for this day
entries=$(egrep -c -e "^$day,1,.*$" $timefile)

parts="$(($entries+1))"
partstr=""
# check if all option is provided
if [ $parts != 2 ]; then
for arg in $@
do
  if [ $arg == "-a" ] || [ $arg == "--all" ]
  then
    parts="1+2"
    partstr="s"
  fi
done
fi

read -p $"Complete Day $day, Part$partstr $parts?"$'\n' reply
[[ $reply =~ ^[Yy].*$ ]] || skip=true # skip if reply is No
[ -n "$skip" ] && [ $skip == true ] && echo "Stopping..." && exit 1

st=$(head start)
echo "$day,$parts,$st,$end," >> $timefile

rm start

case $(($day%3)) in
  0) ext="rb";;
  1) ext="jl";;
  2) ext="py";;
esac

dir=$PWD

echo "Congrats on completing the Day $day, part$partstr $parts! :)"
echo "Times saved in '$(dirname $PWD)/times.csv'"

mv $0 ..

read -p $"Commit solution into Git?"$'\n' reply
[[ $reply =~ ^[Yy].*$ ]] && commit=true # commit if reply is Yes

[ $commit == true ] || exit 0 # exit if don't wanna commit changes

git add $dir $timefile
git commit -m "Added solution for Day $day, Part$partstr $parts and updated times.csv"
git commit --amend

# if aborted, undo commit but keep files
if [ $? == 1 ]; then
echo "Did not commit..."
git reset HEAD~
fi

fi