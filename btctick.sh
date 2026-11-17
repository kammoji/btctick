#!/bin/bash

# Bitcoin ticker
# Gets bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018->
# btctick is and always will be PUBLIC DOMAIN. Please copy, paste, spread the work!

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

#Spinning icon stuff:
spinner() {
NC='\033[0m'
# Rainbow cycle: red, yellow, green, cyan, blue, magenta (bold/bright).
# 6 colors vs 5 frames, so the colors drift across the symbols each round.
colors=('\033[1;31m' '\033[1;33m' '\033[1;32m' '\033[1;36m' '\033[1;34m' '\033[1;35m')

spin=("-" "\\" "|" $'\u20bf' "/")

echo -n "Initializing... "
k=0
for i in `seq 0 5`;
	do
  		for j in "${spin[@]}"
  			do
        		printf "\b${colors[k % ${#colors[@]}]}%s${NC}" "$j"
        		k=$((k + 1))
        		sleep 0.086
		done

	done
	sleep 0.4
	tput cr; tput el
}
#Update check prep:
git remote update > /dev/null
STATUS=$(git status -s -u no | grep -A 1 "Your")

check_update() {

    if [ ! -z "$STATUS" ]

	   then
	    	echo
        	echo "WARN: Update available, the version you are running may not work correctly."
		echo "INFO: Run 'git pull' to auto-update to latest."
		echo $STATUS
		echo

    fi

}

check_update

# Early scan for currency option, needed before output is printed:
euro=0
for arg in "$@"; do
	case $arg in -e|--euro) euro=1 ;; esac
done

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
	# Bitcoin's own figures live in the page's "statistics":{...} JSON block.
	# Extract by key name instead of counting matches, which broke on every site edit.
	stats=`grep -o -P '"statistics":\{[^}]*\}' coinmarketcap_data_$date\.html | head -n 1`
	get_stat() { echo "$stats" | grep -o -P "\"$1\":[0-9.eE+-]+" | head -n 1 | cut -d":" -f 2; }
	cap=`get_stat marketCap`
	price=`get_stat price`
	volume=`get_stat volume24h`
	if [ -z "$cap" ] || [ -z "$price" ] || [ -z "$volume" ]; then
		echo "ERROR: could not parse Bitcoin data from coinmarketcap.com (site layout changed?)"
		echo "Debug copy kept at: $SCRIPTPATH/coinmarketcap_data_$date.html"
		exit 1
	fi
	#Enter parser:
	fmt() { printf "%.0f" "$1" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'; }
	usd_price_parsed=`fmt $price`   # history file always stores BTC/USD
	fiat="USD"; sym="\$"
	if [ "$euro" = 1 ]; then
		# The page lists fiat rates as USD per unit, e.g. "symbol":"EUR","p":1.10
		eurusd=`grep -o -P '"symbol":"EUR","p":[0-9.]+' coinmarketcap_data_$date\.html | head -n 1 | cut -d":" -f 3`
		if [ -n "$eurusd" ]; then
			fiat="EUR"; sym=$'€'
			price=`awk -v v="$price" -v r="$eurusd" 'BEGIN{printf "%.2f", v/r}'`
			cap=`awk -v v="$cap" -v r="$eurusd" 'BEGIN{printf "%.2f", v/r}'`
			volume=`awk -v v="$volume" -v r="$eurusd" 'BEGIN{printf "%.2f", v/r}'`
		else
			echo "WARN: EUR exchange rate not found on coinmarketcap.com, showing USD instead."
		fi
	fi
	cap_parsed=`fmt $cap`
	price_parsed=`fmt $price`
	volume_parsed=`fmt $volume`
	echo
	echo "----------"
	echo "btctick.sh - "$'\u20bf'"itcoin market price ticker"
	echo "----------"
	echo
	echo "You are at btctick master branch edit 2026-11-17 - default FIAT is USD (\$)."
	echo "btctick is public domain with NO WARRANTY. Use at your own discretion."
	echo
	echo "NEWS: btctick is now supercharged with Claude! Rock-solid price parsing and a brand new EUR mode (-e)."
	echo "      BTC is 'crashing' toward \$50K - a price we could only dream of 4 years back :D"
	echo "      In the next four years, we may see it crash all the way to \$200K :D !"
	echo "      Dips are a great chance to stack Sats, visit https://konekettu.fi for opportunities."
	echo
	date
	echo "Bitcoin market cap: $sym$cap_parsed"
	echo "Avg. price across exchanges: $sym$price_parsed"
	echo "Trading volume (24h): $sym$volume_parsed"
	if [ "$fiat" = "EUR" ]; then
		echo "(Converted from USD at 1 EUR = `printf "%.4f" $eurusd` USD)"
	fi
	echo
	echo "Source: https://coinmarketcap.com"
	echo "Diggin' it? Support us with some "$'\u20bf'" to address: 1GsBi4t7XyDRoBR2kegDUdNa3CHMVRto6q"
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
		echo '--history   : makes a semi-hidden directory/folder with historical data into your $HOME at ~/.btctick_history'
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
                        		mkdir -p ~/.btctick_history
        		fi
        		if echo $date $usd_price_parsed >> ~/.btctick_history/price_history; then
				echo 'INFO: Success! Saved current BTC/USD price to ~/.btctick_history/price_history'
			else
				echo 'ERROR: Could not write to ~/.btctick_history/price_history'
			fi
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
			# Already applied above (see early -e/--euro scan)
			shift # past argument
			;;
            		*)
                    		# unknown option
				echo
                		echo ERROR: Unknown 'option(s)' passed, please check 'command' line
                		echo Usage: btctick.sh '[--history, -g, -e]'
                		echo Full help: btctick.sh -h
                		echo 'Contact juhana[a]konekettu.fi for support'
                		echo
			      	break

            		;;
        	esac
        	done
	fi
	#CLEANUP for devs
	#Comment away with "#" the following line to enable debugging
	#Frequently needed due to coinmarketcap.com site edits...: 
	rm -rf "coinmarketcap_data_$date.html"
else
	echo
	echo "ERROR: no data link to coinmarketcap.com"
	echo "Please check your internet connection."
	echo
fi
