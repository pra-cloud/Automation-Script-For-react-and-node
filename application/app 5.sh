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


function ec2application {
	clear
	sleep 7
	echo "Enter application name: "
	read appname
	aws deploy create-application --application-name $appname --compute-platform Server
	sleep 2
	echo "Application created"
	echo "Enter Deploymentgroup name: "
	read depname
	aws deploy create-deployment-group --application-name $appname --deployment-group-name $depname --service-role-arn drole --deployment-config-name CodeDeployDefault.OneAtATime --deployment-style deploymentType=IN_PLACE,deploymentOption=WITHOUT_TRAFFIC_CONTROL  --ec2-tag-filters Key=Name,Value=$insname,Type=KEY_AND_VALUE
	echo "Deployment Group Created"
	sleep 2
	#sed -i "s@app@$appname@" $path/codepipelineDetails.json
	#sed -i "s@gname@$depname@" $path/codepipelineDetails.json
	
	echo -e "Enter GitHUb Owner name"
        read owner

        echo -e "Enter name of GitHub Repository"
        read repo

        echo -e "Enter name of GitHub Branch"
        read branch

        echo -e "Enter token Id Of Github Account"
        read token

        echo -e "Enter name of Pipeline Name"
        read pipeline

	pipe5=piperole

	sudo tee $path/application/code.json >/dev/null <<EOF
{
 "pipeline": {
  "roleArn": "$pipe5",
  "stages": [
    {
      "name": "Source",
      "actions": [
        {
          "inputArtifacts": [],
          "name": "Source",
          "actionTypeId": {
            "category": "Source",
            "owner": "ThirdParty",
            "version": "1",
            "provider": "GitHub"
          },
        "configuration": {
                "Owner": "$owner",
                "Repo": "$repo",
		"PollForSourceChanges": "false",
                "Branch": "$branch",
                "OAuthToken": "$token"
        },
          "outputArtifacts": [
            {
              "name": "MyApp"
            }
          ],
          "runOrder": 1
        }
      ]
    },
    {
      "name": "CodeDeploy",
      "actions": [
        {
          "inputArtifacts": [
            {
              "name": "MyApp"
            }
          ],
          "name": "CodePipelineDemo",
          "actionTypeId": {
            "category": "Deploy",
            "owner": "AWS",
            "version": "1",
	    "provider": "CodeDeploy"
          },
          "outputArtifacts": [],
          "configuration": {
            "ApplicationName": "$appname",
            "DeploymentGroupName": "$depname"
          },
          "runOrder": 1
        }
      ]
    }
  ],
  "artifactStore": {
    "type": "S3",
    "location": "bucketchange"
  },
  "name": "$pipeline",
  "version": 1
 }
}
EOF

echo -e " Sleep For 10 Seconds"

sleep 10

}


function pipeline{

    sed -i "s@$bucketname@bucketchange@" $path/application/app5.sh
    
    bash $path/pipeline/pipeline 6.sh

}


getpath
ec2application
pipeline