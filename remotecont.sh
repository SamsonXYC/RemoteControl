#!/bin/bash

#Network Research Project
#Student Name : Samson Xiao
#Student Code : s30
#Class Code : cfc0202
#Lecturer : James Lim

echo 'Installing required applications'
sleep 1																	#sleep command to put terminal to sleep for specified timing.
sudo apt-get update && sudo apt-get upgrade -y 							#doing an update and upgrade to the kali system with the flag -y to reply yes to all prompts.
echo 'System updated'
sleep 1
sudo apt-get install sshpass -y 										#installing the application sshpass
echo 'sshpass Installed.'
sleep 1
sudo apt-get install geoip-bin -y 										#installing the application geoip-bin
echo 'geoip-bin Installed.'
sleep 1
sudo apt-get install cpanminus -y 										#installing the application cpanminus
git clone https://github.com/htrgouvea/nipe								#cloning the nipe files from github
cd nipe																	#changing directory to nipe
sudo cpanm --installdeps . 												#using the application cpan to install dependencies for nipe
sudo perl nipe.pl install 												#installing the application nipe
echo 'Nipe Installed.'
sleep 1
echo ' '
echo ' '

sudo perl nipe.pl start													#starting the nipe service. Nipe is a engine that makes Tor Network your default gateway, which spoofs your external ip address.

truestatus=$(sudo perl nipe.pl status | grep true | wc -l)
spoofip=$(sudo perl nipe.pl status | grep -Eo "[0-9]{1,3}[\.][0-9]{1,3}[\.][0-9]{1,3}[\.][0-9]{1,3}")
spoofcountry=$(geoiplookup $spoofip | awk '{print $4,$5}')
																		#here we are saving a few commands into Variable so we can use the variable to call out the command instead of having to type the command repeatedly.
if [ $truestatus == 1 ]
then 
	echo 'You are anonymous..'
	echo "Your spoofed IP is.. $spoofip"								#calling out the Variables we saved using $Variable
	echo "Your spoofed Country is.. $spoofcountry"
																		#here is a if/else script that executes a block of code if the condition is met, if condition is not met then another block of code will be executed.
else
	echo 'Not anonymous, exiting.'
	echo 'Please restart script.'
	exit
fi

sleep 2	
echo ' '
echo 'Please input remote server IP'									#we are getting the user input for specific words to save them into Variables which we can call out later on in our command.
read remoteIP															#the read command saves the user input into Variable
echo 'Please input remote server User'
read remoteUser
echo 'Please input remote server Password'
read remotePW
echo "Connecting to ${remoteUser}@${remoteIP}.."						#we are calling out the saved Variables which is input by the using ${variable}  
sshpass -p "${remotePW}" ssh -o "StrictHostKeyChecking=no" ${remoteUser}@${remoteIP} "uptime"  #using sshpass to connect remotely using the Variables given by the user to check the uptime of the ssh server we are connected to.
echo 'Enter IP or DNS to scan..'
read scanthis

whereisfile=$(pwd)														#we are saving yet another few commands into variables for use later.
datetime=$(date)

sshpass -p "${remotePW}" ssh -o "StrictHostKeyChecking=no" ${remoteUser}@${remoteIP} "whois ${scanthis}" | tee whois_${scanthis}  #using the sshpass, we are now accessing the remote server and doing a whois scan on the IP/DNS given by user. and using tee to save the output to our local machine.
echo ' '
sleep 3
echo "Whois data was saved into $whereisfile"							#by using the variable $whereisfile, we inform the user of the path in which the Whois data is stored in. So that they can find it easily.
echo ' '
sleep 3
sshpass -p "${remotePW}" ssh -o "StrictHostKeyChecking=no" ${remoteUser}@${remoteIP} "nmap -Pn -F ${scanthis}" | tee nmap_${scanthis}	#using sshpass again to do a nmap scan on IP/DNS given by user.
echo ' '
sleep 3
echo "Nmap data was saved into $whereisfile"
sleep 3
sudo echo "$datetime" >> NR.log											#here we are creating and appending a logfile which will keep track of all the scans done on all the IP/DNS given by the user.
sudo echo "Nmap data collected for: $scanthis" >> NR.log
sudo echo "Whois data collected for: $scanthis" >> NR.log
sudo echo ' ' >> NR.log
echo "NR.log is updated, file is saved in $whereisfile"
