#!/bin/bash

# Bitcoin ticker
# Retrieves bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018

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
spin[3]="${LC}/${NC}"

echo -n "Initializing...${spin[0]}"
for i in `seq 0 4`;
	do
  		for j in "${spin[@]}"
  			do
        		echo -ne "\b$j"
        		sleep 0.069
		done
	done
}

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

#Check that wget result not compressed:
FILEINFO=$(file "coinmarketcap_data_$date.html")
echo $FILEINFO
if [ -s "coinmarketcap_data_$date.html" ] && [ ! -z "$FILEINFO" ]
then
	spinner
	#grep -A 20 "href=\"/currencies/bitcoin/\">Bitcoin</a>" coinmarketcap_data_$date\.html > coinmarketcap_data_$date
	# Master branch observation 24 Oct 2022: The cap and volume greps return two lines -> get only the first line with head:
	cap=`cat coinmarketcap_data_$date\.html | grep -o -P 'Cap":.{0,500}' | head -n 1 | cut -d":" -f 2 | cut -d"," -f 1`
	#echo $cap
	#cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price=`cat coinmarketcap_data_$date\.html | grep -o -P 'price".{0,40}' | head -n 2 | tail -n 1 | cut -d":" -f 2 | cut -d"." -f 1`
	volume=`cat coinmarketcap_data_$date\.html | grep -o -P 'volume".{0,40}' | cut -d"," -f 1 | cut -d":" -f 2`
	#Enter parser:
	cap_parsed=`printf "%.0f" $cap | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	price_parsed=`printf "%.0f" $price | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	volume_parsed=`printf "%.0f" $volume | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'`
	echo
	echo "----------"
	echo "btctick.sh - Bitcoin market price ticker"
	echo "----------"
	echo
	echo "You are at btctick.sh master branch 2023-11-12 - US dollars ($)"
	echo "btctick has NO WARRANTY. Use at your own discretion."
	echo
	date
	echo "Bitcoin market cap: "$cap_parsed
	echo "Avg. price across exchanges: "\$$price_parsed
	echo "Trading volume (last 24h): "\$$volume_parsed
	echo
	echo "Data is from https://coinmarketcap.com"
	echo "Diggin' this little thing? Tip: 34iMNyQ4ntVQSPeMLtyM7j1Az1eqWagQwK"
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
		echo '--history : Creates a hidden folder with historical data into your home at ~/.btctick_history'
		echo '            A timestamp and BTC/USD price line will be appended into a file called price_history in the hidden folder.'
		echo
		echo '-g | --gui : launches btctick in C gtk GUI mode'
		echo
		echo 'EXAMPLES:'
		echo
		echo './btctick.sh --history     : run btctick once, create and save the historical data'
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
			echo 'INFO: Price history save requested...'
        		if [[ ! -d ~/.btctick_history ]]
                		then
					echo 'Creating folder ~/.btctick_history...'
                        		mkdir ~/.btctick_history
        		fi
        		echo $date $price >> ~/.btctick_history/price_history
			echo 'INFO: Successfully appended current BTC/USD price to ~/.btctick_history/price_history'
            		shift # past argument
            		;;
            		-g|--gui)
			echo 'INFO: GUI launch requested.'
			echo 'INFO: Launching GUI...'
			gcc -o ./gui src/gui.c `pkg-config --cflags --libs gtk4`
			./gui
			rm -rf gui
            		shift # past argument
            		;;
            		*)
                    		# unknown option
				echo
                		echo ERROR: Unknown 'option(s)' passed, please check 'command' line
                		echo Usage: btctick.sh '[--history, -g]'
                		echo For full help, run btctick.sh -h
                		echo 'Contact juhana@konekettu.fi for further support'
                		echo
#			      	exit 1

            		;;
        	esac
        	done
	fi
	#CLEANUP, comment away with "#" the following line to enable debugging
	# Debugging is frequently needed due to coinmarketcap.com changing the site...: 
	rm "coinmarketcap_data_$date.html"
else
	echo
	echo "ERROR: no data link to https://coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
