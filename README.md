
#Bitcoin market ticker - Copyleft - Juhana K 2018-2024

#Install:

Install git, gzip and wget, needed to download the script logic, fetch and, if needed, unzip downloaded data:

<pre>
sudo apt-get install git gzip wget
</pre>

Clone the repo to your location, e.g. to your home:

<pre>
cd
git clone https://github.com/kammoji/btctick.git
cd btctick
</pre>

Then run the shell script btctick.sh on your Linux shell, e.g:

<pre>
bash btctick.sh
</pre>

Script clones as runnable so simply

<pre>
chmod 775 btctick.sh
./btctick.sh
</pre>

will work in a BASH shell.

#Update to latest version:

<pre>
cd btctick
git pull
</pre>

TODO: Check for updates at execute. Currently works in the sense that git stuff runs on display if update available. Update is checked in the init spinner.
TODO: Graphical user interface. Launch logic works, no real business in the GUI yet.

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

