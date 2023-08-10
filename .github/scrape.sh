#!/bin/bash

mkdir -p "data/plans"
mkdir -p "data/commissions"

function getJson() {
	wget "$1" -O - | jq .
}

function scrapePlans() {
	jq -r 'flatten(1) | .[]' .github/plans.json | while read plan
	do
		urlEncoded=$(echo $plan | jq -sRr @uri)
		fileEncoded=$(echo $plan | sed 's;/;%2f;g')
		echo "PLAN: $plan"
		url=$(PLAN="$urlEncoded" envsubst <<< $PLAN_URL)
		getJson "$url" > "data/plans/$fileEncoded.json"
	done
}

function scrapeCommissionsBase() {
	level="GRADUATE"
	year="$1"
	period="$2"
	url=$(LEVEL="$level" YEAR="$year" PERIOD="$period" envsubst <<< $COMMISSIONS_URL)
	echo year: $1
	echo period: $2
	echo $url
	getJson "$url" > "data/commissions/$level-$year-$period.json"
}

function getNextSemester() {
	year=$1
	semester=$2
	if [ "$semester" = "FirstSemester" ]
	then
		echo $year "SecondSemester"
	else
		echo $((year+1)) "FirstSemester"
	fi
}

function getSemesterFromMonth() {
	year=$1
	month=$2
	case $month in
		01 | 02 | 03 | 04 | 05 | 06)
			echo $year "FirstSemester"
			;;
		07 | 08 | 09 | 10 | 11)
			echo $year "SecondSemester"
			;;
		12)
			echo $((year+1)) "FirstSemester"
			;;
	esac
}

function scrapeCommissions() {
	read -r year month <<<$(date +"%Y %m")
	read -r year semester <<<$(getSemesterFromMonth $year $month)

	scrapeCommissionsBase $year $semester
	read -r nextYear nextSemester <<<$(getNextSemester $year $semester)
	scrapeCommissionsBase $nextYear $nextSemester
}

scrapePlans
scrapeCommissions
