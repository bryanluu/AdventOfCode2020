#!/bin/bash

end=$(date)

folder=${PWD##*/}
if [ ${folder//[0-9]/} != Day ]
then
echo "Cannot run this yet! Start by running '. start_next.bash' first..."
exit 1
else

day=${folder//[!0-9]/}

timefile="../times.csv"
if [ ! -f $timefile ]
then

echo "Day,Start,End" > $timefile
echo >> $timefile

fi

st=$(head start)
echo "$day,$st,$end" >> $timefile
echo >> $timefile

rm start

case $(($day%3)) in
  0) ext="rb";;
  1) ext="jl";;
  2) ext="py";;
esac

dir=$PWD

echo "Congrats on completing the Day $day! :)"
echo "Times saved in '$(dirname $PWD)/times.csv'"

mv $0 ..

git add $dir $timefile
git commit -m "Added solution for December $day and updated times.csv"
git commit --amend

# if aborted, undo commit but keep files
if [ $? == 1 ]; then
git reset HEAD~
fi

fi