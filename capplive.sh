#!/bin/bash
# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"
#....

if [[ $EUID -ne 0 ]]; then
   echo
else
   echo "This script may not be run as root" 1>&2
   exit 1
fi

if [ "$0" != "bash" ]; then
   printf "\n\nThis script must be executed as source.  Execute this way:\n\n. cappLive.sh\n\n"
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

xchat --url=irc://irc.freenode.net:6667/#cappuccino

printf "Cappuccino Live!! - For Linux Users.  This script in meant run live on Linux Mint 13 Cinnamon.\n\n"

printf "\nYou will be prompted a few times during intallation.  Read the prompts carefully or your installation may fail! This script may not work twice so get it right the first time or reboot the live disk and start again.  Once you understand how to do it without error live, then use the script on an installed version of Mint.  If Firefox is running, shut it down before you press enter.\n\n<enter to continue>\n"
read x

sudo killall firefox
sudo apt-get update
wget https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi && firefox *.xpi && rm *.xpi

printf "\n\nYou will make several passwords during this install.  Store passwords conveniently in keepassx.  Keepassx will be launching shortly.\n\n<enter to continue>\n"
read x

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

printf "\n\nFirefox will be launched to test Apache.  Close Firefox to continue.\n\n<enter to launch Apache test>\n"
read x
firefox localhost

sudo apt-get -q -y install php5 libapache2-mod-php5

sudo /etc/init.d/apache2 restart

echo '<?php phpinfo(); ?>' > phptest.php
sudo mv phptest.php /var/www/

printf "\n\nFirefox will be launched to test php.  Close Firefox to continue.\n\n<enter to launch php test>\n"
read x
firefox localhost/phptest.php

printf "\n\nmysql server is about to be installed.  mysql has a set of users of it's own.  To begin with, mysql comes with one user called: root.  You will be asked to set root's password.  You must do this!  Use keepassx to store the password. \n\n<enter to install mysql server>\n"
read x
sudo apt-get -q -y install mysql-server

printf "\n\nmyphpadmin is about to be installed.  You will be prompted four times: \n(1) Use the space bar to select Apache, and then tab to ok, and press enter. \n(2) Answer yes at the 'Configuring phpmyadmin' screen by pressing enter.\n(3) Enter your mysql root user password (the one you just created).\n(4) Finally, you must create a new password for myphpadmin program.  myphpadmin also a set of users of it's own.  You must create this password!  Use keepassx to store the password. \n\n<enter to install nmyphpadmin>"
read x
sudo apt-get -q -y install libapache2-mod-auth-mysql php5-mysql phpmyadmin

printf "\n\nIt's time to uncomment a line inside a file that will be opened when you hit enter.  Use find to find the line\n\nextension=msql.so\n\nand take out the semi-colon at the begining of the line to uncomment it, then hit save, quit. \n\n<enter to open file to edit>\n"
gksudo gedit /etc/php5/apache2/php.ini

printf "\n\nFirefox will be launched to test opening: phpmyadmin.  You should see phpmyadmin app show up in Firefox.  Close Firefox to continue.\n\n<enter to launch phpmyadmin test>\n"
read x
firefox localhost/phpmyadmin

printf "\n\nSublime Text is an Objective-J code editor and will be installed and launched to test.\n\n<enter to install Sublime Text>\n"
read x
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

printf "\n\nExit Sublime to continue\n\n<enter to continue>\n"
sublime
read x

cd ~/.config/sublime-text-2/Packages/
git clone git://github.com/aparajita/Cappuccino-Sublime.git
cd ~/

# if [ ! -f .bashrc ];
# then
#     echo "" > .bashrc
# fi

printf "\n\nCappuccino will now be installed.  Answer yes to all (y/n) questions and choose all default answers.  After the questions end, it may take several minute for Cappuccino to build.  Do not close the Terminal window.\n\n<enter to install Cappuccino>\n"
read x

git clone git://github.com/cappuccino/cappuccino.git
cd cappuccino
sudo ./bootstrap.sh
source ~/.bashrc
export NARWHAL_ENGINE=rhino
export PATH="/usr/local/narwhal/bin:$PATH"
export CAPP_BUILD="/home/$USER/cappuccino/Build"
echo "NARWHAL_ENGINE=rhino" >> /home/$USER/.bashrc
echo PATH="/usr/local/narwhal/bin:$PATH" >> /home/$USER/.bashrc
echo CAPP_BUILD="/home/$USER/cappuccino/Build" >> /home/$USER/.bashrc

jake sudo-install
