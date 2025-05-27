
# Bitcoin market price command line tool - Copyleft - Juhana K 2018-2025

##Beyond Bitcoin 2025!!

# Install:

1. Install git, gzip and wget, needed to download the script logic.
2. Fetch and, if needed, unzip downloaded data:

<pre>
sudo apt-get install git gzip wget
</pre>

Clone the repo to wherever, e.g. to home:

<pre>
cd
git clone https://github.com/kammoji/btctick.git
cd btctick
</pre>

Then run the script btctick.sh on your Linux shell, e.g:

<pre>
bash btctick.sh
</pre>

The main script clones as runnable so simply

<pre>
chmod 775 btctick.sh
./btctick.sh
</pre>

should work in your shell.

# Manually update to latest:

<pre>
cd btctick
git pull
</pre>

TODO: Check for updates at execute. Currently works in the sense that git stuff runs on display if update available. Update is checked in the init spinner.
TODO: Graphical user interface. Launch logic works, no real business in the GUI yet.
TODO: Check if a Rust or Golang GUI would be possible and more easily implemented.
TODO: Support for other currencies. Euro is in the prealpha phase now...

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

