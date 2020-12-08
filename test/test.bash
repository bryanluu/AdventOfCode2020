#!/bin/bash

echo "testing..."

url="https://adventofcode.com/2020/day/7/input"

username=$(head -n 1 ~/.github)
password=$(tail -n 1 ~/.github)

curl -L -v -c cookies.txt --user $username:$password $login_url > login.html