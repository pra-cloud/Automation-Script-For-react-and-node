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

function ec2cloudwatch {
	clear
	echo "Option for Times"
	echo "1. For every (1/2/3/4/5/10/15/30/45/60) minute"
	echo "2. For a particular time (ex. At 1PM everyday)"
	echo -n "Enter Your Choice : "
	read cloudwatchtimefirstoption
	if [ $cloudwatchtimefirstoption -eq 1 ]
	then
		clear
		echo -e "Your choice \"For every (1/2/3/4/5/10/15/30/45/60) minute\" \n"
		echo -n "Enter your minute(0-59): "
		read cloudwatchminchoice
		cloudwatchcronexp="cron(0/$cloudwatchminchoice * * * ? *)"
		echo $cloudwatchcronexp
		sleep 3
	elif [ $cloudwatchtimefirstoption -eq 2 ]
	then
		clear
		echo -e "Your choice \"For a particular time (ex. At 1PM everyday)\" \n"
		echo "Time in IST"
		echo -e "0. 00:30 \t1. 01:30 \t2. 02:30 \t3. 03:30"
		echo -e "4. 04:30 \t5. 05:30 \t6. 06:30 \t7. 07:30"
		echo -e "8. 08:30 \t9. 09:30 \t10. 10:30 \t11. 11:30"
		echo -e "12. 12:30 \t13. 13:30 \t14. 14:30 \t15. 15:30"
		echo -e "16. 16:30 \t17. 17:30 \t18. 18:30 \t19. 19:30"
		echo -e "20. 20:30 \t21. 21:30 \t22. 22:30 \t23. 23:30"
		echo -n "Enter your choice(0-23) : "
		read cloudwatchoiceist
		if [ $cloudwatchoiceist -eq 0 ]
		then
			cloudwatchoicegmt=19
		elif [ $cloudwatchoiceist -eq 1 ]
		then
			cloudwatchoicegmt=20
		elif [ $cloudwatchoiceist -eq 2 ]
		then
			cloudwatchoicegmt=21
		elif [ $cloudwatchoiceist -eq 3 ]
		then
			cloudwatchoicegmt=22
		elif [ $cloudwatchoiceist -eq 4 ]
		then
			cloudwatchoicegmt=23
		elif [ $cloudwatchoiceist -gt 23 ]
		then
			echo "Wrong Choice"
			sleep 3
			ec2cloudwatch
		else 
			cloudwatchoicegmt=$(($cloudwatchoiceist-5))
		fi
		cloudwatchcronexp="cron(0 $cloudwatchoicegmt * * ? *)"
		echo $cloudwatchcronexp
		sleep 3
	else 
		echo "Wrong Choice"
		sleep 2
		ec2cloudwatch
	fi


	#cloudwatch role
	
	echo -e "Enter name of CloudWatch Role Name"
	read cloudwatch
	aws iam create-role --role-name $cloudwatch --assume-role-policy-document file://$path/cloudwatch/trustpolicyforCloudWatchEvent.json

	aws iam put-role-policy --role-name $cloudwatch --policy-name CodePipeline-Permissions-Policy-For-CloudWatchEvent --policy-document file://$path/cloudwatch/permissionspolicyforCloudWatchEvent.json

	sleep 5
	watchrole=$(aws iam get-role --role-name $cloudwatch --query "Role.Arn" --output text )
	echo -e  $watchrole


	
	echo -e "\n Creating cloudwatch event"
	sleep 2
	echo -e "\n Enter Cloud Watch Event Name"
	read cloudeventname
	aws events put-rule --schedule-expression "$cloudwatchcronexp" --name $cloudeventname
	echo "Cloudwatch Event Created Adding Target"
	sleep 5
	aws events put-targets --rule $cloudeventname --targets "Id"="1","Arn"="$cloudarn","RoleArn"="$watchrole"
	sleep 1
	echo "Target Added"
	sed -i "s@$cloudarn@arnoutput@" $path/cloudwatch/permissionspolicyforCloudWatchEvent.json
}

function congrats {

    echo -e "Congratulation !! ALL DONE"
}

getpath 
ec2cloudwatch
congrats