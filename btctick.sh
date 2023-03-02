#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018
# Updated last: 24/10/2022 - adjusted greps/zcats for CoinMarketCap current site configuration

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

#Command line option parser:
#if [ $1 == "-h" ] && [ -z $2 ]        # Parse command line options:
#then
#
#        echo '[TODO] Output full help'
#        exit 1
#else    # Parse command line options
#
#        btctick_command=$0
#        while [[ $# > 1 ]]
#        do
#        key="$1"

#        case $key in
#            --history)
#            PACBIO_SCAFFOLDER_RESULTS="$2"
#            shift # past argument
#            ;;
#            -g|--gui)
#            THREADS="$2"
#            shift # past argument
#            ;;
#            -h|--help)
#            THREADS="$2"
#            shift # past argument
#	     ;;
#            *)
                    # unknown option
#                echo [ERROR] Unknown 'option(s)' passed, please check 'command' line
#                echo Usage: btctick.sh '[--history, -g]'
#		 echo For full help, run btctick.sh -h
#                echo 'Contact juhana.kammonen@konekettu.fi for further support'
#                echo
#                exit 1

#            ;;
#	 esac
#	 done
#        shift
#Spinning icon stuff:

LG='\033[1;32m'
LC='\033[1;36m'
NC='\033[0m'

spin[0]="-"
spin[1]="${LG}\\"
spin[2]="|"
spin[3]="${LC}/${NC}"

echo -n "Initializing...${spin[0]}"
for i in `seq 0 4`;
	do
  		for j in "${spin[@]}"
  			do
        		echo -ne "\b$j"
        		sleep 0.065
		done
	done

#Update check preparations:
git remote update > /dev/null
STATUS=$(git status -s -u no | grep -A 1 "Your")

check_update() {

    if [ ! -z "$STATUS" ]

	   then
	    	echo
        	echo "WARN: There is an update to btctick.sh available, the version you are running may not work correctly."
		echo "INFO: Go to your install location where your 'btctick.sh' is located and type 'git pull' to update."
		echo $STATUS
		echo

    fi

}

#Check available updates to start:
check_update

date=`date | sed 's/ /_/g'`

# Master branch observation 24 Oct 2022: It looks like the following download object has turned into a binary! -> add a zcat pipe
# Update 3 Nov 2022 download object was plaintext. AND: Update 13 Nov 2022 it's binary again!
wget -q --output-document coinmarketcap_data_"$date".html coinmarketcap.com/currencies/bitcoin

if [ -s "coinmarketcap_data_$date.html" ]
then
	#grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	# Master branch observation 24 Oct 2022: The cap and volume greps return two lines -> get only the first line with head:
	cap=`zcat coinmarketcap_data_$date\.html | grep -o -P 'Market Cap</caption.{0,100}' | head -n 1 | cut -d">" -f 8 | cut -d"<" -f 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`zcat coinmarketcap_data_$date\.html | grep -o -P 'priceValue .{0,40}' | cut -d">" -f 3 | cut -d"<" -f 1`
	volume=`zcat coinmarketcap_data_$date\.html | grep -o -P 'volume24h.{0,30}' | head -n 1 | cut -d":" -f 2 | cut -d"," -f 1`
	#Enter volume parser:
	volume_parsed=`printf "%.0f" $volume | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	echo
	echo "----------"
	echo "btctick.sh Bitcoin USD price ticker - Copyleft Juhana Kammonen 2018-2023"
	echo "----------"
	echo
	echo "You are at btctick.sh master branch 2023-03-02 - All reported prices are US dollars ($)"
	echo "btctick has NO WARRANTY. All use at your own discretion."
	echo "A file called 'price_history' in folder '~/.btctick_history' is created for saving a local price historical data to utilize later."
	echo
	date
	echo "Bitcoin market cap is: "$cap
	echo "Bitcoin avg. price across exchanges is: "$price
	echo "Bitcoin trading volume (last 24h) is: "\$$volume_parsed
	echo
	echo "Data retrieved from https://coinmarketcap.com"
	echo "Diggin' this little script widget? Support us and send some BTC to: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
	echo

	#CLEANUP, comment away with "#" the following line to enable debugging:
	rm "coinmarketcap_data_$date.html"
	#APPEND price to home directory folder btctick_history in a file called price_history:
	if [[ ! -d ~/.btctick_history ]]
		then
			mkdir ~/.btctick_history
	fi
	echo $date $price >> ~/.btctick_history/price_history

else
	echo
	echo "ERROR: no data link to https://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
