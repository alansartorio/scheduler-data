#!/bin/bash

mkdir -p "data/plans"
mkdir -p "data/commissions"

while read plan
do
	echo "PLAN: $plan"
	url=$(PLAN=$plan envsubst <<< $PLAN_URL)
	wget "$url" -O - | jq . > "data/plans/$plan"
done < .github/plans.txt
