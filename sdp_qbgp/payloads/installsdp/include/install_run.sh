#!/bin/bash
# Please run the script by passing 2 parameters..1st is the new build and 2nd is the previous spring build.
#./install_run.sh 14.2.19.0.21 14.2.18.0.21 Here 14.2.19.0.21 is the current Sprint 19 build and 14.2.18.0.21 is the Sprint 18 build.


string=$1
string1=$2
str=(${string//./ })
str1=(${string1//./ })

cp -f  campaign_template.xml campaign.xml
cp -f ETF_template.xml ETF.xml


current_Major_Version=${str[0]}
if [ "${str[1]}" -le 9 ]; then
current_Minor_Version=0${str[1]}
else
current_Minor_Version=${str[1]}
fi
current_Type=${str[2]}
if [ "${str[3]}" -le 9 ]; then
current_Revision=000${str[3]}
else
current_Revision=00${str[3]}
fi
current_Build=${str[4]}
echo Current Build is : $current_Major_Version$current_Minor_Version$current_Type$current_Revision$current_Build 
old_Major_Version=${str1[0]}
if [ "${str1[1]}" -le 9 ]; then
old_Minor_Version=0${str1[1]}
else
old_Minor_Version=${str1[1]}
fi
old_Type=${str1[2]}
if [ "${str1[3]}" -le 9 ]; then
old_Revision=000${str1[3]}
else
old_Revision=00${str1[3]}
fi
old_Build=${str1[4]}

echo Old Build is : $old_Major_Version$old_Minor_Version$old_Type$old_Revision$old_Build
sed -i s/buildno/$current_Major_Version$current_Minor_Version$current_Type$current_Revision$current_Build/g ETF.xml
sed -i s/buildno/$current_Major_Version$current_Minor_Version$current_Type$current_Revision$current_Build/g campaign.xml
