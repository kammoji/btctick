# btctick GUI mode (-g): shows the figures in a small browser window.
# No compiler or GUI toolkit needed, just a web browser. Works on Linux & macOS.
#
# Not run directly: btctick.sh loads this file (source) when -g/--gui is given,
# then calls launch_gui. It uses the figures btctick.sh has already parsed:
# price_parsed, cap_parsed, volume_parsed, sym, fiat, eurusd, ch24, ch7,
# snapshot, NEWS, EDIT_DATE and update_behind.

GUI_W=440; GUI_H=480   # window size in pixels

# Prints the HTML page, built from the figures parsed by btctick.sh.
gui_page() {
	# Percentage change, green when up and red when down:
	chg() { awk -v v="$1" 'BEGIN{ if (v == "") { print "<b>n/a</b>"; exit }
		if (v < 0) printf "<b class=\"down\">▼ %.2f%%</b>", -v;
		else       printf "<b class=\"up\">▲ %.2f%%</b>", v }'; }
	local note="" news="" line update=""
	[ "${update_behind:-0}" -gt 0 ] && update="<div class=\"update\">⬆ Update available: run <code>git pull</code> in the btctick folder</div>"
	[ "$fiat" = "EUR" ] && note="1 EUR = `printf "%.4f" $eurusd` USD · "
	# News lines: escape HTML special characters, make web addresses clickable
	for line in "${NEWS[@]}"; do
		news+="<p>$(printf '%s' "$line" | sed -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' \
			-E -e 's#(https?://[^ ]*[^ .,!?)])#<a href="\1">\1</a>#g')</p>"
	done
	cat <<EOF
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>btctick · $sym$price_parsed</title>
<style>
:root { --bg:#fbfaf7; --card:#ffffff; --fg:#1d1d1f; --muted:#6e6e73; --line:#e6e3dc;
        --btc:#f7931a; --up:#1a7f37; --down:#c62828; }
@media (prefers-color-scheme: dark) {
  :root { --bg:#16161a; --card:#1f1f24; --fg:#f2f2f2; --muted:#9a9aa2; --line:#2e2e35;
          --up:#4cc26b; --down:#ff6b6b; } }
* { box-sizing:border-box; margin:0; }
body { background:var(--bg); color:var(--fg); padding:18px 20px;
       font:15px/1.4 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif; }
header { display:flex; align-items:center; gap:8px; color:var(--muted); font-size:13px; }
.logo { display:grid; place-items:center; width:26px; height:26px; border-radius:50%;
        background:var(--btc); color:#fff; font-weight:700; font-size:16px; }
.name { color:var(--fg); font-weight:600; font-size:15px; margin-right:auto; }
.price { font-size:44px; font-weight:700; letter-spacing:-0.02em; margin:18px 0 4px;
         font-variant-numeric:tabular-nums; }
.changes { display:flex; gap:18px; color:var(--muted); font-size:14px; }
.changes b { font-weight:600; } .up { color:var(--up); } .down { color:var(--down); }
.grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; margin:20px 0 16px; }
.cell { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:10px 12px; }
.cell span { display:block; color:var(--muted); font-size:12px; }
.cell b { font-size:16px; font-variant-numeric:tabular-nums; }
footer { color:var(--muted); font-size:12px; }
footer a { color:inherit; }
.news { border-left:3px solid var(--btc); padding:2px 0 2px 10px; margin:0 0 14px;
        font-size:12px; line-height:1.45; }
.news h2 { font-size:10px; letter-spacing:0.08em; color:var(--btc); margin-bottom:3px; }
.news p + p { margin-top:2px; }
.news a { color:inherit; }
.update { background:var(--btc); color:#fff; border-radius:8px; padding:6px 10px;
          margin:0 0 12px; font-size:12px; font-weight:600; }
.update code { font:inherit; font-family:ui-monospace,monospace; }
</style></head>
<body>
<header><span class="logo">₿</span><span class="name">btctick</span>$snapshot</header>
<div class="price">$sym$price_parsed</div>
<div class="changes"><span>24h `chg "$ch24"`</span><span>7d `chg "$ch7"`</span></div>
<div class="grid">
  <div class="cell"><span>Market cap</span><b>$sym$cap_parsed</b></div>
  <div class="cell"><span>Volume (24h)</span><b>$sym$volume_parsed</b></div>
</div>
<section class="news"><h2>NEWS · $EDIT_DATE</h2>$news</section>
$update
<footer>${note}Source: <a href="https://coinmarketcap.com/currencies/bitcoin/">coinmarketcap.com</a></footer>
</body></html>
EOF
}

# Finds a Chromium-family browser; they can show a page as a small,
# toolbar-free "app" window. Prints its path, or fails if none found.
find_app_browser() {
	case "$OS" in
	WSL)
		# Windows-side browsers (Edge ships with every Windows):
		for exe in "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
			"/mnt/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
			"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" \
			"/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"; do
			[ -x "$exe" ] && { echo "$exe"; return 0; }
		done ;;
	Linux)
		for b in google-chrome google-chrome-stable microsoft-edge brave-browser \
			vivaldi chromium chromium-browser; do
			command -v "$b" 2>/dev/null && return 0
		done ;;
	Darwin)
		for app in "Google Chrome" "Microsoft Edge" "Brave Browser" "Vivaldi" "Chromium"; do
			for dir in /Applications "$HOME/Applications"; do
				[ -x "$dir/$app.app/Contents/MacOS/$app" ] && { echo "$dir/$app.app/Contents/MacOS/$app"; return 0; }
			done
		done ;;
	esac
	return 1
}

# Starts a program in the background, then checks it didn't fail right away.
# A browser that can't start usually exits within a second with an error;
# one that stays running, or hands over to an already-open browser (exit 0), is fine.
start_bg() {
	local log="$cache/launch.log" pid rc i
	nohup "$@" >"$log" 2>&1 &
	pid=$!
	for i in 1 2 3; do
		sleep 0.5
		kill -0 $pid 2>/dev/null || break
	done
	kill -0 $pid 2>/dev/null && return 0
	wait $pid; rc=$?
	[ $rc -eq 0 ] && return 0
	echo "WARN: $(basename "$1") failed to start (exit code $rc)."
	[ -s "$log" ] && tail -n 2 "$log" | cut -c1-150 | sed 's/^/      /'
	return 1
}

# Opens the page in the system's default browser.
open_default() {
	case "$OS" in
	Darwin) start_bg open "$page" ;;
	WSL)
		# wslview (from wslu) if present, else Windows' own "start" command.
		# cmd.exe is run from C:\ to avoid its warning about Linux folders.
		if command -v wslview >/dev/null 2>&1; then
			start_bg wslview "$page"
		else
			(cd /mnt/c 2>/dev/null || cd /; start_bg cmd.exe /c start "" "$(wslpath -w "$page" 2>/dev/null)")
		fi ;;
	*) start_bg xdg-open "$page" ;;
	esac
}

launch_gui() {
	OS=$(uname -s)
	# WSL reports Linux, but its usable browsers live on the Windows side:
	if [ "$OS" = Linux ] && { [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }; then
		OS=WSL
	fi
	case "$OS" in
	Linux)
		cache="${XDG_CACHE_HOME:-$HOME/.cache}/btctick"
		if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
			echo 'ERROR: No graphical display found, GUI not available here. Terminal output above is all yours!'
			return 1
		fi ;;
	WSL)   cache="${XDG_CACHE_HOME:-$HOME/.cache}/btctick" ;;
	Darwin) cache="$HOME/Library/Caches/btctick" ;;
	*)
		echo "ERROR: GUI mode supports Linux, WSL and macOS only (this system: $OS)."
		return 1 ;;
	esac
	mkdir -p "$cache"
	page="$cache/btctick.html"
	gui_page > "$page"

	# 1st choice: a small app-style window in a Chromium-family browser.
	if browser=$(find_app_browser); then
		# Separate small profile: guarantees the window size is honoured and
		# keeps the user's own browser session untouched.
		profile="$cache/browser-profile"
		if [ "$OS" = WSL ]; then
			# Windows browsers need a Windows folder for the profile:
			local appdata
			appdata=$(cd /mnt/c 2>/dev/null || cd /; cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r')
			profile="${appdata:-C:\\Temp}\\btctick\\browser-profile"
		elif [[ $(readlink -f "$browser") == */snapd* ]]; then
			# Snap-packaged browsers can't access hidden folders like ~/.cache:
			profile="$HOME/snap/$(basename "$browser")/common/btctick-profile"
		fi
		# Page is passed inline as a data: URL, so file access never matters.
		url="data:text/html;charset=utf-8;base64,$(base64 < "$page" | tr -d '\n')"
		if start_bg "$browser" --app="$url" --window-size=$GUI_W,$GUI_H \
			--user-data-dir="$profile" --no-first-run --no-default-browser-check; then
			echo "INFO: GUI opened in a small $(basename "$browser") window."
			return 0
		fi
		echo "INFO: Trying your default browser instead..."
	fi

	# 2nd choice: the default browser (e.g. when only Firefox is installed).
	if open_default; then
		echo "INFO: GUI opened in your default browser."
		return 0
	fi

	echo "ERROR: Could not open a browser window for the GUI."
	echo "       The page is saved here, open it in any browser: $page"
	return 1
}
