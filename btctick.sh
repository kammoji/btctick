#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

#Update check preparations:
git remote update > /dev/null
STATUS=$(git status -s -u no | grep -A 1 "Your")

check_update() {

    if [ ! -z "$STATUS" ]

	   then
	    	echo
        	echo "WARN: There is a newer version of btctick.sh available, the version you are running may not work correctly."
		echo $STATUS
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
	echo "Diggin' this widget? Support us and send some BTC to: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
	echo

	#cleanup:
	rm "coinmarketcap_data_$date.html"
	rm "coinmarketcap_data_$date"

else
	echo
	echo "ERROR: unable to retrieve index.html from http://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
