
## Bitcoin market price command line tool - Copyleft - Juhana K 2018-2025

### Beyond Bitcoin 2026!

## Install:

1. Install git, gzip and wget, needed to download the script logic.
2. Fetch and, if needed, unzip downloaded data:

<pre>
sudo apt-get install git gzip wget
</pre>

Clone the repo to e.g. to your home:

<pre>
cd
git clone https://github.com/kammoji/btctick.git
cd btctick
</pre>

Then run on your Linux shell, e.g:

<pre>
bash btctick.sh
</pre>

The script clones as runnable so simply

<pre>
chmod 775 btctick.sh
./btctick.sh
</pre>

should work in a shell.

## Print the manual
<pre>
./btctick.sh -h
</pre>

## Manually update to latest:

<pre>
cd btctick
git pull
</pre>

TODO: Check for updates at exec. Currently works so that git stuff runs on display if update available. Update is checked in the init spinner.
TODO: GUI. Launch logic works, no real business in the GUI yet.
TODO: Check if a Rust GUI would be possible and more easily implemented.
TODO: Support for other currencies. Euro is in the prealpha phase now...

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

