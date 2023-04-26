
#Bitcoin market ticker - Copyleft - Juhana Kammonen 2018-2023

#Install:

Install git if you have not already:

<pre>
sudo apt-get install git
</pre>

Clone the repository to your location, e.g. to your home:

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

will also do in BASH shell.

#Update to latest version:

<pre>
cd btctick
git pull
</pre>

TODO: Check for updates at execute. Currently works in the sense that git stuff runs on display if update available. Update is checked in the init spinner.
TODO: Graphical user interface. Launch command line argument works now but not the actual launch logic. Also, no content in the GUI yet.

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

