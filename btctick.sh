#!/bin/bash

# Bitcoin ticker
# Gets bitcoin data from coinmarketcap.com website and outputs data
# Copyleft Juhana Kammonen 05/2018->
# Co-author: Claude (Anthropic) 11/2026->
# btctick is and always will be PUBLIC DOMAIN. Please copy, paste, spread the work!

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

# Date of the latest edit + today's news (one line per entry). Both are shown
# in the terminal and in the GUI window. Update these together on each edit.
EDIT_DATE=2026-11-25
NEWS=(
"BTC is 'crashing' toward \$50K - a price we could only dream of 4 years back :D"
"In the next four years, we may see it crash all the way to \$200K :D !"
"Dips are a great chance to stack Sats, visit https://konekettu.fi for opportunities."
)

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
# Update check: compares this copy with the latest version on GitHub.
# Stays silent when offline, or when btctick wasn't installed with git clone.
update_behind=0
check_update() {
	git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1 || return 0   # no git clone / no upstream
	# No password prompts; give up if the connection stalls for 5 s:
	GIT_TERMINAL_PROMPT=0 git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=5 \
		fetch -q 2>/dev/null || return 0
	update_behind=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
	update_latest=$(git log -1 --format='%s (%cs)' '@{u}' 2>/dev/null)
}
show_update() {
	[ "${update_behind:-0}" -gt 0 ] || return 0
	echo "WARN: Update available! You are $update_behind version(s) behind, so btctick may not work correctly."
	echo "      Latest: $update_latest"
	echo "INFO: To update, run:  cd $SCRIPTPATH && git pull"
	echo
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
	ch24=`get_stat priceChangePercentage24h`
	ch7=`get_stat priceChangePercentage7d`
	snapshot=`date '+%Y-%m-%d %H:%M'`
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
	# Compact 2-line header: orange ₿ badge + name, then dimmed edit/license line.
	# Colors only when writing to a terminal, so piped output stays clean text.
	if [ -t 1 ]; then
		BADGE=$'\033[1;97;48;5;208m' BOLD=$'\033[1m' DIM=$'\033[2m' RST=$'\033[0m'
	else
		BADGE="" BOLD="" DIM="" RST=""
	fi
	echo "${BADGE} ₿ ${RST} ${BOLD}btctick${RST}  Bitcoin market price ticker"
	echo "${DIM}    edit $EDIT_DATE · $fiat · public domain, no warranty${RST}"
	echo
	date
	echo "Bitcoin market cap: $sym$cap_parsed"
	echo "Avg. price across exchanges: $sym$price_parsed"
	echo "Trading volume (24h): $sym$volume_parsed"
	if [ "$fiat" = "EUR" ]; then
		echo "(Converted from USD at 1 EUR = `printf "%.4f" $eurusd` USD)"
	fi
	echo
	# News after the price figures, same layout as the GUI window:
	prefix="NEWS: "
	for line in "${NEWS[@]}"; do
		echo "$prefix$line"
		prefix="      "
	done
	echo
	echo "Source: https://coinmarketcap.com"
	echo "Diggin' it? Support us with some "$'\u20bf'" to address: 1GsBi4t7XyDRoBR2kegDUdNa3CHMVRto6q"
	echo
	show_update

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
		echo '-g | --gui  : also shows the figures in a small browser window (Linux/macOS)'
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
			# GUI code lives in src/gui.sh, loaded only when needed:
			if [ -f "$SCRIPTPATH/src/gui.sh" ]; then
				source "$SCRIPTPATH/src/gui.sh" && launch_gui
			else
				echo "ERROR: GUI file src/gui.sh is missing. Run git pull to restore it."
			fi
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
	show_update
fi
