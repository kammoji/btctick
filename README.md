
#Bitcoin market ticker - Copyleft - Juhana K 2018-2024

#Install:

Install git and wget if you haven't already:

<pre>
sudo apt-get install git wget
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
TODO: Graphical user interface. Launch logic works, no content in the GUI yet.

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

