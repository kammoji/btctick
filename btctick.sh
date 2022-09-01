#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018
# Updated last: 30/08/2022 - adjusted greps for CoinMarketCap site configuration

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
		echo "INFO: Go to your install location where your 'btctick.sh' is located and type 'git pull' to update."
		echo $STATUS
		echo

    fi

}

#Check available updates to start:
check_update

date=`date | sed 's/ /_/g'`

wget -q --output-document coinmarketcap_data_$date.html coinmarketcap.com/currencies/bitcoin

if [ -s "coinmarketcap_data_$date.html" ]
then
	#grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	cap=`grep -o -P 'Market Cap</caption.{0,100}' coinmarketcap_data_$date\.html | cut -d">" -f 8 | cut -d"<" -f 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`grep -o -P 'priceValue .{0,40}' coinmarketcap_data_$date\.html | cut -d">" -f 2 | cut -d"<" -f 1`
	volume=`grep -o -P 'Volume</th.{0,40}' coinmarketcap_data_$date\.html | cut -d">" -f 3 | cut -d"<" -f 1`
	echo
	echo "----------"
	echo "btctick.sh Bitcoin USD price ticker - Copyleft Juhana Kammonen 2018"
	echo "----------"
	echo
	echo "Last update 08/2021 - All reported prices are US dollars ($)"
	echo "btctick.sh comes with NO WARRANTY whatsoever."
	echo
	date
	echo "Bitcoin market cap is: "$cap
	echo "Bitcoin average price across exchanges is: "$price
	echo "Bitcoin trading volume (last 24h) is: "$volume
	echo
	echo "Data retrieved from https://coinmarketcap.com"
	echo "Diggin' this widget? Support us and send some BTC to: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
	echo

	#cleanup:
	rm "coinmarketcap_data_$date.html"

else
	echo
	echo "ERROR: unable to retrieve data from https://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
