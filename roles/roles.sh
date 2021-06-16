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

function roles {

echo -e "\t Enter ec2 service Role Name\n"
read rname
aws iam create-role --role-name $rname --assume-role-policy-document file://$path/roles/awsec2.json

aws iam attach-role-policy --role-name $rname --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy

aws iam attach-role-policy --role-name $rname --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

echo -e "\t Enter instance-profile-name\n"
read ipname
aws iam create-instance-profile --instance-profile-name $ipname

aws iam add-role-to-instance-profile --role-name $rname --instance-profile-name $ipname

sleep 10

sed -i "s@ipname@$ipname@" $path/instance/ec2-instance 2.sh

#add profile name ($ipname) to the ec2 launch instance command by using sed 

echo -e "Enter name of deployment role"
read codeDeploy
aws iam create-role --role-name $codeDeploy --assume-role-policy-document file://$path/roles/codedep.json

aws iam attach-role-policy --role-name $codeDeploy  --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole

role=$(aws iam get-role --role-name $codeDeploy  --query "Role.Arn" --output text)

echo -e "$role"
sleep 10

sed -i "s@drole@$role@" $path/application/app 5.sh

#add role to the create deployment command by using sed ( --service-role-arn $role)

echo -e "Enter name of CodePipeline Role Name"
read rolepipe

aws iam create-role --role-name $rolepipe --assume-role-policy-document file://$path/roles/trust-policy.json

aws iam put-role-policy --role-name $rolepipe --policy-name CodePipelinePolicy --policy-document file://$path/roles/policy.json

piperole=$(aws iam get-role --role-name $rolepipe  --query "Role.Arn" --output text )

echo -e "$piperole"

sed -i "s@piperole@$piperole@" $path/application/app 5.sh
sleep 5
}

getpath 
roles