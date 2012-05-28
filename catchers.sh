#!/bin/bash


prefix=/home/victor/public_html/series/
server=FQDN
user=victor
http_user=public
http_password=public
outputdir=/tmp

result=$(whiptail --title "Select a tv show" --backtitle "MyServer" --menu TV-Shows 20 80 10 `for x in $(ssh $user@$server ls $prefix); do echo $x "-"; done` 2>&1 >/dev/tty)

directory=$directory$result
isdirectory=1

while [ $isdirectory -eq 1 ]
do
	completepath=$(echo "$prefix/$directory")

	result=$(whiptail --title "Select a tv show" --backtitle "MyServer" --menu TV-Shows 20 80 10 `for x in $(ssh $user@$server ls $completepath); do echo $x "-"; done` 2>&1 >/dev/tty)
	exitstatus=$?
	if [ $exitstatus != 0 ]; then
	    echo "User selected Cancel."
		exit
	fi
	directory=$directory/$result
	isdirectory=$(ssh $user@$server test -d $completepath && echo "1" || echo "0")
done

SCREENNAME=$(whiptail --inputbox "Name of the screen session for this download" 8 78 --title "Nothing" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "Aborted"
	exit
fi
echo "Downloading file $completepath"
echo "$directory"
http_prefix=$(echo $completepath | sed 's/\/home\/victor\/public_html//' )
http_path=http://$http_user:$http_password@$server/~$user/$http_prefix

echo $http_path
cd $outputdir
/usr/bin/screen -A -m -d -S $SCREENNAME wget $http_path
echo "Started!"
