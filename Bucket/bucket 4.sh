#!/bin/bash

function getpath {
	echo "List of Directories: "
	echo `ls ~/Desktop/`
	echo "Enter Foldername: " ##without slash
	read foldname
	path=~/Desktop/$foldname 
	if [ -d $path/output/ ]
	then
		echo "Directory Already Created"
	else
		mkdir $path/output/
	fi
	echo "Selected path is: " $path
	sleep 2
}

function bucket {
	sleep 2
	clear
	echo "Enter unique Bucket Name: "
	read bucketname
	echo "Creating S3 Bucket"
	aws s3api create-bucket --bucket $bucketname --create-bucket-configuration LocationConstraint=$region
	sed -i "s@bucketchange@$bucketname@" $path/application/app 5.sh 
	sleep 5
}

function app {

    bash $path/application/app 5.sh

}

getpath
bucket
app
