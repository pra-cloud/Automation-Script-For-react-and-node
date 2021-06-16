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

function ec2codepipeline {
	echo -e "\nInitiating Pipeline"
	aws codepipeline create-pipeline --cli-input-json file://$path/application/code.json > $path/output/codepipelinecloudwatch1.json
	echo "Pipeline is created"
        sleep 3
	aws codepipeline get-pipeline --name $pipeline > $path/output/codepipelinecloudwatch2.json
        cloudarn=$(jq -r '.metadata.pipelineArn' $path/output/codepipelinecloudwatch2.json)
        echo $cloudarn
        sed -i "s@arnoutput@$cloudarn@" $path/cloudwatch/permissionspolicyforCloudWatchEvent.json
	sleep 5
}

function watch{

    bash $path/cloudwatch/cloudwatch7.sh

}

getpath
ec2codepipeline
watch