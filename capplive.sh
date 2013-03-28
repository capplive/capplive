#!/bin/bash
# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....

if [[ $EUID -ne 0 ]]; then
   echo
else
   zenity --warning --text "This script may not be run as root";
   exit 1
fi

if [ "$0" != "bash" ]; then
   zenity --warning --text "This script must be executed as source.  Execute this way:\n\n. cappLive.sh";
   exit 1
fi

sudo iptables -F
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -A INPUT -p tcp --dport ssh -j DROP
sudo iptables -I INPUT 1 -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -j DROP

# xchat --url=irc://irc.freenode.net:6667/#cappuccino

zenity --info --text "Cappuccino Live for Linux and Windows users.  This script is meant to run live on Linux Mint 13 Cinnomon.  You will be prompted a few times during installation.  Read the prompts carefully or your installation may fail.  Shutdown Firefox before running."

sudo killall firefox
sudo apt-get update
# wget https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi && firefox *.xpi && rm *.xpi

zenity --info --text "\n\nYou will make several passwords during this install.  Store passwords conveniently in keepassx.  Keepassx will be launching shortly."

sudo apt-get -q -y install keepassx

keepassx &

sudo apt-get -q -y install chromium-browser
sudo apt-get -q -y install firefox
sudo apt-get -q -y install opera
sudo apt-get -q -y install curl
sudo apt-get -q -y install filezilla
sudo apt-get -q -y install apache2
sudo apt-get -q -y install git
sudo apt-get -q -y install nautilus

# printf "\n\nAnswer NO if you are running the script on the Live disk.  If you already installed Mint and are running the script on an installed Mint, then you may answer yes.  Remastersys allows you to create a live disk with all your custom settings on it.  Do you want to install Remastersys?  (y or n) \n\n<enter to continue>\n"
# read x
# if["$x" == "y"]; then 
#   sudo -u root -s wget -O - http://www.remastersys.com/ubuntu/remastersys.gpg.key | sudo apt-key add -
#   cat /etc/apt/sources.list > souces.list
#   echo "deb http://www.remastersys.com/ubuntu precise main" >> sources.list
#   sudo cp sources.list /etc/apt/
#   sudo apt-get update
#   sudo apt-get -q -y install remastersys
#   sudo apt-get -q -y install remastersys-gtk
# fi

printf "\n\nFirefox will be launched to test Apache.  \n\n<Close Firefox to continue.>\n"
firefox localhost

sudo apt-get -q -y install php5 libapache2-mod-php5

sudo /etc/init.d/apache2 restart

echo '<?php phpinfo(); ?>' > phptest.php
sudo mv phptest.php /var/www/

printf "\n\nFirefox will be launched to test php.  \n\n<Close Firefox to continue.t>\n"
firefox localhost/phptest.php

zenity --info --text "mysql server is about to be installed.  mysql has a set of users of it's own.  To begin with, mysql comes with one user called: root.  You will be asked to set root's password.  You must do this!  Use keepassx to store the password."
sudo apt-get -q -y install mysql-server

zenity --info --text "myphpadmin is about to be installed.  You will be prompted four times: \n(1) Use the space bar to select Apache, and then tab to ok, and press enter. \n(2) Answer yes at the 'Configuring phpmyadmin' screen by pressing enter.\n(3) Enter your mysql root user password (the one you just created).\n(4) Finally, you must create a new password for myphpadmin program.  myphpadmin also a set of users of it's own.  You must create this password!  Use keepassx to store the password. (It's a good idea to keep this window up for reference for this process.)" &
sudo apt-get -q -y install libapache2-mod-auth-mysql php5-mysql phpmyadmin

zenity --info --text "It's time to uncomment a line inside a file that will be opened when you hit enter.  Use find to find the line\n\nextension=msql.so\n\nand take out the semi-colon at the begining of the line to uncomment it, then hit save, quit." &
gksudo gedit /etc/php5/apache2/php.ini

zenity --info --text "Firefox will be launched to test opening: phpmyadmin.  You should see phpmyadmin app show up in Firefox.  Close Firefox to continue."
firefox localhost/phpmyadmin

zenity --info --text "Sublime Text is an Objective-J code editor and will be installed and must be launched to install the Objective-J language."
wget http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.tar.bz2
tar -xf Sublime\ Text\ 2.0.1.tar.bz2
sudo cp Sublime\ Text\ 2/Icon/128x128/sublime_text.png /usr/share/icons/sublime.png

sudo ln -s /home/$USER/Sublime\ Text\ 2/sublime_text /usr/bin/sublime
echo "[Desktop Entry]
Name=sublime
Comment=Objective-J Editor
Exec=sublime
Terminal=false
Type=Application
Icon=sublime
Categories=Development;" > Desktop/sublime.desktop
sudo cp Desktop/sublime.desktop /usr/share/applications/sublime.desktop
sudo chmod 755 /usr/share/applications/sublime.desktop
sudo chmod 755 Desktop/sublime.desktop

zenity --info --text "Close Sublime Text (and this window) to contine."
sublime
read x

cd ~/.config/sublime-text-2/Packages/
git clone git://github.com/aparajita/Cappuccino-Sublime.git
cd ~/

# if [ ! -f .bashrc ];
# then
#     echo "" > .bashrc
# fi

zenity --info --text "Cappuccino will now be installed and can take several minutes.  But, first you will answer a short amount of questions on the command line.  Answer yes to all (y/n) questions and choose all default answers.  Do not close the Terminal window during this process. Click OK to continue."

git clone git://github.com/cappuccino/cappuccino.git
cd cappuccino
sudo ./bootstrap.sh
source ~/.bashrc
export NARWHAL_ENGINE=rhino
export PATH="/usr/local/narwhal/bin:$PATH"
export CAPP_BUILD="/home/$USER/cappuccino/Build"
echo "NARWHAL_ENGINE=rhino" >> /home/$USER/.bashrc
echo PATH="/usr/local/narwhal/bin:$PATH" >> /home/$USER/.bashrc
echo CAPP_BUILD="/home/"$USER"/cappuccino/Build" >> /home/$USER/.bashrc

jake sudo-install
