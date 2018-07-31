#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
BRANCH=$(git symbolic-ref HEAD)

check_update() {

    echo "Running btctick.sh version check..."
    cd $SCRIPTPATH

    if [ "$BRANCH" == 'refs/heads/master' ]

	then
		echo "INFO: btctick.sh is the latest version, great!"
		echo "-----------"
    	else
        	echo "WARN: There is a newer version of btctick.sh available, the version you are running may not work correctly"
		echo "INFO: Type \"git pull\" to update"
		echo

    fi

}

check_update

date=`date | sed 's/ /_/g'`

wget -q --output-document coinmarketcap_data_$date\.html coinmarketcap.com

if [ -s "coinmarketcap_data_$date.html" ]
then
	grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	cap=`grep -A 1 'market-cap' "coinmarketcap_data_$date" | tail -n 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`grep 'price' coinmarketcap_data_$date | cut -d">" -f 2 | cut -d "<" -f 1`
	volume=`grep 'volume' coinmarketcap_data_$date | cut -d">" -f 2 | cut -d "<" -f 1`
	echo
	echo "btctick.sh Bitcoin ticker - Copyleft Juhana Kammonen 2018"
	echo
	date
	echo "Bitcoin market cap is: "$cap
	echo "Bitcoin average price across exchanges is: "$price
	echo "Bitcoin trading volume (last 24h) is: "$volume
	echo
	echo "Data retrieved from http://coinmarketcap.com"

	#cleanup:
	rm "coinmarketcap_data_$date.html"
	rm "coinmarketcap_data_$date"

else
	echo
	echo "ERROR: unable to retrieve index.html from http://coinmarketcap.com"
	echo "Please check internet connection."
	echo
fi
