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

launch_gui() {
	OS=$(uname -s)
	case "$OS" in
	Linux)
		cache="${XDG_CACHE_HOME:-$HOME/.cache}/btctick"
		if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
			echo 'ERROR: No graphical display found, GUI not available here. Terminal output above is all yours!'
			return 1
		fi ;;
	Darwin)
		cache="$HOME/Library/Caches/btctick" ;;
	*)
		echo "ERROR: GUI mode supports Linux and macOS only (this system: $OS)."
		return 1 ;;
	esac
	mkdir -p "$cache"
	gui_page > "$cache/btctick.html"

	if browser=$(find_app_browser); then
		# Separate small profile: guarantees the window size is honoured and
		# keeps the user's own browser session untouched.
		profile="$cache/browser-profile"
		# Snap-packaged browsers can't access hidden folders like ~/.cache:
		if [[ $(readlink -f "$browser") == */snapd* ]]; then
			profile="$HOME/snap/$(basename "$browser")/common/btctick-profile"
		fi
		# Page is passed inline as a data: URL, so file access never matters.
		url="data:text/html;charset=utf-8;base64,$(base64 < "$cache/btctick.html" | tr -d '\n')"
		nohup "$browser" --app="$url" --window-size=$GUI_W,$GUI_H \
			--user-data-dir="$profile" --no-first-run --no-default-browser-check \
			>/dev/null 2>&1 &
		echo "INFO: GUI opened in a small $(basename "$browser") window."
	else
		# No app-capable browser (e.g. Firefox only): use the default browser.
		if [ "$OS" = Darwin ]; then
			open "$cache/btctick.html"
		else
			nohup xdg-open "$cache/btctick.html" >/dev/null 2>&1 &
		fi
		echo "INFO: GUI opened in your default browser."
	fi
}
