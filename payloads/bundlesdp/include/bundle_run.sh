#!/bin/bash

# Please run the script by passing 2 parameters..1st is the new build and 2nd is the previous spring build.
#./bundle_run.sh 14.2.19.0.21 14.2.18.0.21 Here 14.2.19.0.21 is the current Sprint 19 build and 14.2.18.0.21 is the Sprint 18 build.

cp -f ETF_template.xml ETF.xml
string=$1
string1=$2
str=(${string//./ })
str1=(${string1//./ })

current_Major_Version=${str[0]}
if [ "${str[1]}" -le 9 ]; then
current_Minor_Version=0${str[1]}
else
current_Minor_Version=${str[1]}
fi
#echo "current_Type : ${str[2]}";
current_Type=${str[2]}
if [ "${str[3]}" -le 9 ]; then
current_Revision=000${str[3]}
else
current_Revision=00${str[3]}
fi
current_Build=${str[4]}
echo Current Build is : $current_Major_Version$current_Minor_Version$current_Type$current_Revision$current_Build 
sed -i s/buildno/$current_Major_Version$current_Minor_Version$current_Type$current_Revision$current_Build/g ETF.xml
