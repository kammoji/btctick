
#Bitcoin market ticker - Copyleft - Juhana Kammonen 2018-2023

#Install:

Install git if you have not already:

<pre>
sudo apt-get install git
</pre>

Clone the repository to your desired location:

<pre>
cd /home/USERNAME/bin
git clone https://github.com/kammoji/btctick.git
cd btctick
</pre>

Then just run the shell script btctick.sh on your Linux shell, e.g:

<pre>
bash btctick.sh
</pre>

The also script clones as runnable so simply

<pre>
chmod 775 btctick.sh
./btctick.sh
</pre>

will also do in a BASH shell.

#Update to latest version:

<pre>
cd btctick
git pull
</pre>

TODO: Check for updates upon running. Currently it works in the sense that git stuff runs on display if update available. Update is checked in the init spinner.
TODO: Set historical to optional and not default. Update 03/2023: is now optional but option not working yet
TODO: Graphical user interface

Suggestions, questions, anything?
Contact juhana[a]konekettu.fi

