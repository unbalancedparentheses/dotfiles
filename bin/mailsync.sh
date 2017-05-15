#!/bin/sh

while true
do
	imapfilter
	offlineimap
	#notmuch new
	sleep 5
done
