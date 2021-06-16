#!/bin/bash

#function calls  the menu program
function menu {
        clear
        echo -e "\t\t\tMain Page\n\n"
        echo -e "\t1. Launch With AWS LightSail\n"
        echo -e "\t2. Launch With AWS EC2\n"
	echo -e "\t3. Scale Up/Down Instance\n"
	echo -e "\t4. Terminate a Instance\n"
	echo -e "\t5. To view Logs\n"
	echo -e "\t6. To Integrate CloudFront\n"
        echo -e "\t0. For Exit\n\n"
	echo -e "Enter option: "
        #read -p "Enter Your Choice: " option
        read option
	
	#boundary condtns
	if [ $option -gt 6 ]
	then
		echo "Invalid choice"
		sleep 3
		clear
		menu
	elif [ $option -eq 2 ]
	then
		echo "Option Selected: " $option
		sleep 2 
		allwithec2
	elif [ $option -eq 3 ]
	then
		echo "Option Selected: " $option
		sleep 2
		clear
		echo "List of Available Instances" 
		aws ec2 describe-instances --query "Reservations[].Instances[].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,CustomerName:Tags[?Key=='CustomerName']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --output table
		echo -en "\n Enter Instance-ID : "
		read insid
		echo -e "Stopping Instance with id $insid \n"
		aws ec2 stop-instances --instance-ids $insid
		while true
		do
			clear
			ec2instancestatus
			echo -en "\n Enter w for \"wait or refresh\" or c for \"continue\" : "
			read mmmm
			if [ $mmmm = "w" ]
			then
				sleep 5
				continue
			else 
				break
			fi
		done
		createlogfile
		ec2instyp
		aws ec2 modify-instance-attribute --instance-id $insid --instance-type "{\"Value\": \"$instype\"}"
		aws ec2 start-instances --instance-ids $insid
		sleep 5
		createlogfile
	elif [ $option -eq 4 ]
	then
		echo "Option Selected: " $option
		sleep 2
		clear
		echo "List of Available Instances" 
		aws ec2 describe-instances --query "Reservations[].Instances[].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,CustomerName:Tags[?Key=='CustomerName']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --output table
		echo -en "\n Enter Instance-ID : "
		read insid
		echo -e "Stopping Instance with id $insid \n"
		aws ec2 stop-instances --instance-ids $insid
		while true
		do
			clear
			ec2instancestatus
			echo -en "\n Enter w for \"wait or refresh\" or c for \"continue\" : "
			read mmmm
			if [ $mmmm = "w" ]
			then
				sleep 5
				continue
			else 
				break
			fi
		done
		createlogfile
		aws ec2 modify-instance-attribute --instance-id $insid --attribute userData --value file://$path/menu/entermination.txt
		aws ec2 start-instances --instance-ids $insid
		while true
		do
			clear
			ec2instancestatus
			echo -en "\n Enter w for \"wait or refresh\" or c for \"continue\" : "
			read mmmm
			if [ $mmmm = "w" ]
			then
				sleep 5
				continue
			else 
				break
			fi
		done
		createlogfile
		aws ec2 terminate-instances --instance-ids $insid
		sleep 5
		createlogfile
	elif [ $option -eq 5 ]
	then	
		if [ -d ./log/ ]
		then
			cd ./log/
			echo `ls | nl`
			echo -en "\n Enter the log file name : "
			read viewlogfilename
			cat $viewlogfilename 

		else
			echo "No Log Directory"
		fi
	elif [ $option -eq 6 ]
	then
		clear
		echo "Available Instances"
		aws ec2 describe-instances --instance-id --query "Reservations[].Instances[].{InstanceType:InstanceType,PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --output table	
		echo -n "Enter Instance Id: "
		read insid
		insdns=$(aws ec2 describe-instances --instance-ids $insid | jq -r ".Reservations[0].Instances[0].PublicDnsName")
		echo -e 'Instance DNS: ' $insdns
		aws cloudfront create-distribution --origin-domain-name $insdns
		echo "Cloud Front Distribution is created"
	fi
}

function createlogfile {
	if [ -d $path/log/ ]
	then
		echo "Directory Already Created"
	else
		mkdir $path/log/
	fi
	aws ec2 describe-instances --instance-id $insid --query "Reservations[].Instances[].{InstanceType:InstanceType,StateTransitionReason:StateTransitionReason,LaunchTime:LaunchTime,PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,CustomerName:Tags[?Key=='CustomerName']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --output table >> $path/log/$insid.log
}


function ec2instancestatus {
	aws ec2 describe-instances --instance-ids $insid --query "Reservations[].Instances[].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,CustomerName:Tags[?Key=='CustomerName']|[0].Value,Status:State.Name,InstanceID:InstanceId}" --output table

	echo "System Status = $(aws ec2 describe-instance-status --instance-ids $insid --query "InstanceStatuses[*].SystemStatus.Details[*].[Status]" --output text)"

	echo "Instance Status = $(aws ec2 describe-instance-status --instance-ids $insid --query "InstanceStatuses[*].InstanceStatus.Details[*].[Status]" --output text)"
}


function allwithec2 {

    bash $path/instance/ec2-instance 2.sh

}

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

getpath
menu