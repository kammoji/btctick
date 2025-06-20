#!/bin/bash

# Bitcoin ticker
# Gets bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018->
# that is to say, btctick is PUBLIC DOMAIN. Please copy, paste and spread the work!

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

#Spinning icon stuff:
spinner() {
LG='\033[1;32m'
LC='\033[1;36m'
NC='\033[0m'

spin[0]="-"
spin[1]="${LG}\\"
spin[2]="|"
spin[3]=$'\u20bf'
spin[4]="${LC}/${NC}"

echo -n "Initializing...${spin[0]}"
for i in `seq 0 5`;
	do
  		for j in "${spin[@]}"
  			do
        		echo -ne "\b$j"
        		sleep 0.080
		done

	done
	sleep 0.5
	tput cr; tput el
}
#Update check prep:
git remote update > /dev/null
STATUS=$(git status -s -u no | grep -A 1 "Your")

check_update() {

    if [ ! -z "$STATUS" ]

	   then
	    	echo
        	echo "WARN: An update to btctick is available, the version you are running may not work correctly."
		echo "INFO: Simply type 'git pull' in your install location to update."
		echo $STATUS
		echo

    fi

}

check_update

date=`date | sed 's/ /_/g'`

wget -q --output-document coinmarketcap_data_"$date".html coinmarketcap.com/currencies/bitcoin
#Check if coinmarketcap_data was compressed:
FILEINFO=$(file "coinmarketcap_data_$date.html")
if [[ $FILEINFO == *"gzip"* ]]; then
  mv coinmarketcap_data_"$date".html coinmarketcap_data_"$date".gz
  gunzip coinmarketcap_data_"$date".gz
  mv coinmarketcap_data_"$date" coinmarketcap_data_"$date".html
fi
if [ -s "coinmarketcap_data_$date.html" ] && [ ! -z "$FILEINFO" ]
then
	spinner
	#grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	cap=`cat coinmarketcap_data_$date\.html | grep -o -P 'Cap":.{0,500}' | head -n 1 | cut -d":" -f 2 | cut -d"," -f 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`cat coinmarketcap_data_$date\.html | grep -o -P 'price".{0,500}' | head -n 7 | tail -n 1 | cut -d":" -f 2 | cut -d"." -f 1`
	volume=`cat coinmarketcap_data_$date\.html | grep -o -P 'volume".{0,40}' | tail -n 1 | cut -d"," -f 1 | cut -d":" -f 2`
	#Enter parser:
	cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price_parsed=`printf "%.0f" $price | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	volume_parsed=`printf "%.0f" $volume | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	echo
	echo "----------"
	echo "btctick.sh - "$'\u20bf'"itcoin market price ticker"
	echo "----------"
	echo
	echo "You are at btctick.sh master branch edit 2025-06-19 - USD (\$)"
	echo "btctick is public domain with NO WARRANTY. Use at your own discretion."
	echo
	echo "NEWS: Bitcoin market price around \$100k again. All aboard the "$'\u20bf'" train while it's still on the station!"
	echo
	date
	echo "Bitcoin market cap: "\$$cap_parsed
	echo "Avg. price across exchanges: "\$$price_parsed
	echo "Trading volume (24h): "\$$volume_parsed
	echo
	echo "Data: https://coinmarketcap.com"
	echo "Diggin' the works? Why not support with "$'\u20bf'" to address: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
	echo

	#Command line option parser:
	if [ -z $1 ]
	then
		echo "For options run 'btctick.sh -h'"
	elif [ $1 == "-h" ] # Parse command line options:
	then

		echo
        	echo 'OPTIONS:'
		echo
		echo '--history   : makes a hidden directory/folder with historical data into your $HOME at ~/.btctick_history'
		echo '              A timestamp and BTC/USD price line is appended into a file "price_history" in the folder.'
		echo
		echo '-e | --euro : output with currency as EUR instead of USD' 
		echo
		echo '-g | --gui  : launches btctick in GUI mode'
		echo
		echo 'EXAMPLES:'
		echo
		echo './btctick.sh --history     : run btctick, create and save the historical data'
		echo
		echo './btctick.sh -g --history  : run btctick in GUI mode, save the historical data'
		echo
#        	exit 1
	else    # Parse command line options
	
	        btctick_command=$0
        	while [[ $# -gt 0 ]]
        	do
        	key="$1"
        	case $key in
            		--history)
			#APPEND price to home directory folder btctick_history in a file called price_history:
			echo 'INFO: Price history save requested.'
        		if [[ ! -d ~/.btctick_history ]]
                		then
					echo 'Creating new folder ~/.btctick_history ...'
                        		mkdir ~/.btctick_history
        		fi
        		echo $date $price_parsed >> ~/.btctick_history/price_history
			echo 'INFO: Success! Saved current BTC/USD price to ~/.btctick_history/price_history'
            		shift # past argument
            		;;
            		-g|--gui)
			echo 'INFO: GUI requested.'
			echo 'INFO: GUI launching...'
			gcc -o ./gui src/gui.c `pkg-config --cflags --libs gtk4`
			./gui
			rm -rf gui
            		shift # past argument
            		;;
			-e|--euro)
			echo 'INFO: Output currency EUR requested...'
			echo 'INFO: Unfortunately, EUR mode still TODO.'
			shift # past argument
			;;
            		*)
                    		# unknown option
				echo
                		echo ERROR: Unknown 'option(s)' passed, please check 'command' line
                		echo Usage: btctick.sh '[--history, -g, -e]'
                		echo Full help: btctick.sh -h
                		echo 'Contact juhana|at|konekettu.fi for support'
                		echo
			      	break

            		;;
        	esac
        	done
	fi
	#CLEANUP, comment away with "#" the following line to enable debugging
	# Debugging is frequently needed due to coinmarketcap.com changing the site...: 
	rm -rf "coinmarketcap_data_$date.html"
else
	echo
	echo "ERROR: no data link to https://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
