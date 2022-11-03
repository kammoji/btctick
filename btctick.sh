#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018
# Updated last: 24/10/2022 - adjusted greps/zcats for CoinMarketCap current site configuration

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

# Master branch observation 24 Oct 2022: It looks like the following download object has turned into a binary! -> add a zcat pipe
# Update 3 Nov 2022, this was changed back to cat.
wget -q --output-document coinmarketcap_data_$date.html coinmarketcap.com/currencies/bitcoin

if [ -s "coinmarketcap_data_$date.html" ]
then
	#grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	# Master branch observation 24 Oct 2022: The cap and volume greps return two lines -> get only the first line with head:
	cap=`cat coinmarketcap_data_$date\.html | grep -o -P 'Market Cap</caption.{0,100}' | head -n 1 | cut -d">" -f 8 | cut -d"<" -f 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`cat coinmarketcap_data_$date\.html | grep -o -P 'priceValue .{0,40}' | cut -d">" -f 3 | cut -d"<" -f 1`
	volume=`cat coinmarketcap_data_$date\.html | grep -o -P 'Market Cap</caption.{0,100}' | head -n 1 | cut -d">" -f 8 | cut -d"<" -f 1`
	echo
	echo "----------"
	echo "btctick.sh Bitcoin USD price ticker - Copyleft Juhana Kammonen 2018"
	echo "----------"
	echo
	echo "You are at btctick.sh master branch 2022-11-04 - All reported prices are US dollars ($)"
	echo "btctick ships with NO WARRANTY whatsoever."
	echo
	date
	echo "Bitcoin market cap is: "$cap
	echo "Bitcoin average price across exchanges is: "$price
	echo "Bitcoin trading volume (last 24h) is: "$volume
	echo
	echo "Data retrieved from https://coinmarketcap.com"
	echo "Diggin' this little script widget? Support us and send some BTC to: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
	echo

	#CLEANUP, comment away with "#" the following line to enable debugging:
	rm "coinmarketcap_data_$date.html"

else
	echo
	echo "ERROR: unable to retrieve data from https://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
