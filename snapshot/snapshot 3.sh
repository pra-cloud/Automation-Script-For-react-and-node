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

function ec2lifecycle {
	#sed -i "s@instagname@$insname@" $path/snapshotpolicyDetails.json
	echo "Enter Account Id of your AWS"
	read accid
	aws dlm create-lifecycle-policy --description "Creating Lifecycle Policy" --execution-role-arn arn:aws:iam::$accid:role/DLMSErvicenewrole --state ENABLED --policy-details file://$path/snapshot/snapshotpolicyDetails.json
	echo "Lifecycle Policy Created"
	sleep 3
}

function bucket {

    bash $path/Bucket/bucket4.sh

}

getpath
ec2lifecycle
bucket 