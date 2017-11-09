#!/bin/bash

# Bitcoin ticker
# Retrieves data from coinmarketcap.com website and outputs
# Copyleft Juhana Kammonen 2017

date=`date | sed 's/ /_/g'`

wget -q --output-document coinmarketcap_data_$date\.html coinmarketcap.com

if [ -s "coinmarketcap_data_$date.html" ]
then
	grep -A 20 "<a class=\"currency-name-container\" href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	cap=`grep -P '\\$' coinmarketcap_data_$date | head -n 1 | cut -d"$" -f 2`
	price=`grep 'price' coinmarketcap_data_$date | cut -d">" -f 2 | cut -d "<" -f 1`
	volume=`grep 'volume' coinmarketcap_data_$date | cut -d">" -f 2 | cut -d "<" -f 1`
	echo
	echo "bitcoin.sh Bitcoin ticker - Copyleft Juhana Kammonen 2017"
	echo
	date
	echo "Bitcoin market cap is: $"$cap
	echo "Bitcoin average price across exchanges is: "$price
	echo "Bitcoin trading volume is: "$volume
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
