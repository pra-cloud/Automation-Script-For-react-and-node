#!/bin/bash
function module{
        getpath
        awsconfig 
	   ec2region 
	   ec2instyp 
	   ec2insname 
	   ec2amiid 
	   ec2storage 
	   ec2keyselection 
	   ec2clientname 
	   ec2subnet 
	   ec2count 
	   ec2securitygroup
	   repodetails
	   ec2launch
       ec2details
       ec2lifecycle
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

#function to retrieve configuration from user
function awsconfig {
        clear
        aws configure
}

#function to get ec2 region name
function ec2region {
        arr4=(ap-south-1 ap-southeast-1 us-east-1 us-west-1 ap-northeast-1)
        echo "0. Mumbai Region"
        echo "1. Singapore Region"
        echo "2. N. Virginia"
        echo "3. N. California"
	echo "Enter your region: "
        read tem5
	if [ $tem5 -gt 3 ]
	then
		echo "Invalid Choice"
		sleep 3
		clear
		ec2region
	fi
        region=${arr4[tem5]}
	echo "Region is: " $region
	sleep 2
}

function ec2instyp {
        arr1=(t2.small t2.micro t3.large t3.small t2.large t2.xlarge t3.xlarge t3.2xlarge)
        clear
        echo -e "\t0. t2.small\n"
        echo -e "\t1. t2.micro\n"
        echo -e "\t2. t3.large\n"
        echo -e "\t3. t3.small\n"
	echo -e "\t4. t2.large\n"
	echo -e "\t5. t2.xlarge\n"
	echo -e "\t6. t3.xlarge\n"
	echo -e "\t7. t3.2xlarge\n"
	echo -e "Enter your instance type: "
        #read -p "Enter Your Choice " instype
        read tem4

	if [ $tem4 -gt 7 ]
	then
		echo "Invalid Choice"
		sleep 3
		clear
		ec2instyp
	fi

        instype=${arr1[tem4]}

	echo "Instance Type is: " $instype
	sleep 2
}

#function to retrieve instance name
function ec2insname {
        echo -e "Enter instance tagname\n"
        read insname
        echo "Instance Name  is: " $insname
        sed -i "s@instagname@$insname@" $path/snapshot/snapshotpolicyDetails.json
	sleep 2
}

#function to retrieve ami ids for different region
function ec2amiid {
	arrM=(ami-0bcf5425cdc1d8a85 ami-0a9d27a9f4f5c0efc ami-0d758c1134823146a ami-0b3acf3edf2397475)
        arrV=(ami-0742b4e673072066f ami-096fda3c22c1c990a ami-042e8287309f5df03 ami-0fde50fcbcd46f2f7)
        arrC=(ami-0577b787189839998 ami-09d9c5cdcfb8fc655 ami-031b673f443c2172c ami-05c558c169cfe8d99)
        arrS=(ami-03ca998611da0fe12 ami-0f86a70488991335e ami-01581ffba3821cdf3 ami-03e8d3c5c16f119bb)
	echo -e "0. Amazon Linux 2\n"
        echo -e "1. Redhat 8\n"
        echo -e "2. Ubuntu 20.04\n"
        echo -e "3. Suse 15\n"
	echo -e "4. Others (snapshot ami-0cb0e6b6df21f4bcf )\n"
	echo -e "Choose your OS: "
        read tem
	if [ $tem == 4 ]
	then
		echo -e "enter Ami Id"
		read AMI
		amiid=$AMI
	fi
	if [ $tem -gt 4 ]
	then
		echo "Invalid Choice"
		sleep 3
		clear
		ec2amiid
	fi
	if [ $tem -lt 4 ]
	then
	#to check the different regions AMIid
	if [ $region == 'ap-south-1' ]
	then
		amiid=${arrM[tem]}
	elif [ $region == 'ap-southeast-1' ]
	then
		amiid=${arrS[tem]}
	elif [ $region == 'us-east-1' ]
	then
		amiid=${arrV[tem]}
	elif [ $region == 'us-west-1' ]
	then
		amiid=${arrC[tem]}
	fi
	fi
	echo "AMI Id is: " $amiid
	sleep 2
}

#function to retrieve storage
function ec2storage {
	echo "Enter Additional Storage"
	read storage
	echo Storage is: 8 +  $storage Gib
	sleep 2
}


#function to create new key
function ec2createkey {
	echo "Enter new keyname: "
	read newkeyname
	#aws ec2 create-key-pair --key-name $newkeyname --query 'KeyMaterial' --output text > /root/internship/script3/$newkeyname.pem
	aws ec2 create-key-pair --key-name $newkeyname --query 'KeyMaterial' --output text > $path/output/$newkeyname.pem
	chmod +x $path/output/$newkeyname.pem
	echo "New key Created"
	#change variable so in the end no need to call 2 names for instance launching
	keyname=$newkeyname
	sleep 2
}

#function for key type selection
function ec2keyselection {
	clear
	#retrieving all keys from acct
	#aws ec2describe-key-pairs > /root/internship/script3/keyDetails.json
	aws ec2 describe-key-pairs > $path/output/keyDetails.json
	#jq -r '.KeyPairs[].KeyName' /root/internship/script3/keyDetails.json
	arrkey=($(jq -r '.KeyPairs[].KeyName' $path/output/keyDetails.json))
	for i in "${!arrkey[@]}"
	do
		printf "%s\t%s\n" "$i" "${arrkey[$i]}"
	done
	sleep 2
	echo "Select from above keys"
	echo "---------OR----------"
	echo -e "0. For creating new key\n"
	echo -e "1. For selecting the key\n"
	read keyopt
	
	case $keyopt in
		0)
			ec2createkey
			;;
		1)
			echo "Enter Keyposition"
			read temp9
			keyname=${arrkey[temp9]}
			;;
		*)
			echo "Invalid Choice"
			ec2keyselection
			;;
	esac
	echo Key Selected: $keyname
	sleep 2
}

#function to retrieve the client name
function ec2clientname {
	echo "Enter the clientname: "
	read cname
	echo Client Name is: $cname
	sleep 2
}


#function to retrieve subnet ids
function ec2subnet {
	clear
	#aws ec2 describe-subnets > /root/internship/script3/subnetDetails.json
	aws ec2 describe-subnets > $path/output/subnetDetails.json
	#arrsubnetname=($(jq -r '.Subnets[].AvailabilityZone' /root/internship/script3/subnetDetails.json | tr -d '[],"'))
	arrsubnetname=($(jq -r '.Subnets[].AvailabilityZone' $path/output/subnetDetails.json | tr -d '[],"'))
	#arrsubnetid=($(jq -r '.Subnets[].SubnetId' /root/internship/script3/subnetDetails.json | tr -d '[],"'))
	arrsubnetid=($(jq -r '.Subnets[].SubnetId' $path/output/subnetDetails.json | tr -d '[],"'))
	echo -e "Subnets in this region are: "
	echo ${#arrsubnetname[@]}
	for i in "${!arrsubnetname[@]}"
	do
		printf "%s\t%s\n"  "$i" "${arrsubnetname[$i]}"
	done
	echo "Select the position"
	read position
	maxsubnet=${#arrsubnetid[@]}
	
	echo "Maximum subnets in this region are" $maxsubnet

	if [ $position -gt $maxsubnet ]
	then
		echo "Invalid Choice"
		sleep 2
		clear
		ec2subnet
	fi

	subnetid=${arrsubnetid[position]}
	echo "Subnet Name Selected is: " $subnetid
	sleep 2
}

##function to retrieve max no of instances
function ec2count {
	echo "Enter the maximum no of instances "
	read count
	echo Total count is: $count
	sleep 2
}

##function to retrieve security groups and change accrodingly
function ec2securitygroup {
	clear
	#aws ec2 describe-security-groups > /root/internship/script3/securitygroupDetails.json
	aws ec2 describe-security-groups > $path/output/securitygroupDetails.json
	#arrsgname=($(jq -r '.SecurityGroups[].GroupName' /root/internship/script3/securitygroupDetails.json | tr -d '[],"'))
	arrsgname=($(jq -r '.SecurityGroups[].GroupName' $path/output/securitygroupDetails.json | tr -d '[],"'))
	#arrsgid=($(jq -r '.SecurityGroups[].GroupId' /root/internship/script3/securitygroupDetails.json | tr -d '[],"'))
	arrsgid=($(jq -r '.SecurityGroups[].GroupId' $path/output/securitygroupDetails.json | tr -d '[],"'))
	echo "Total Security groups are:"
	echo ${#arrsgname[@]}
	for i in "${!arrsgname[@]}"
	do
		printf "%s\t%s\n" "$i" "${arrsgname[$i]}"
	done
	sleep 2
	echo "Give Position"
	read position2
	maxsg=${#arrsgid[@]}

	if [ $position2 -gt $maxsg ]
	then
		echo "Invalid Choice"
		ec2securitygroup
	fi

	sgid=${arrsgid[position2]}
	echo "Id is: " $sgid
	echo "Selected SecurityGroupName is: " ${arrsgname[position2]}
	echo "Selected SecurityGroupId is: " ${arrsgid[position2]}
	sleep 2
}

function ec2launch {
	aws ec2 run-instances --image-id $amiid --instance-type $instype --key-name $keyname --subnet-id $subnetid --security-group-ids $sgid --count $count --monitoring Enabled=true --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$storage,\"DeleteOnTermination\":true}}]"   --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$insname'},{Key=CustomerName,Value='$cname'}]' --user-data file://$path/instance/ubuntuscriptb.sh > $path/output/instanceDetails.json --iam-instance-profile Name="ipname"
	sed -i "s@$glink@domainlink@" $path/ubuntuscriptb.sh
	sed -i "s@$temp1@filetype@" $path/ubuntuscriptb.sh
	sed -i "s@$temp2@filedetail@" $path/ubuntuscriptb.sh
	sed -i "s@$reponame@reponame@" $path/ubuntuscriptb.sh
	sed -i "s@$insname@instagname@" $path/snapshotpolicyDetails.json
	echo -e "Successfully launched"
	sleep 3
}

function ec2details {
	clear
	insid=$(jq -r '.Instances[0].InstanceId' $path/output/instanceDetails.json)
	privip=$(jq -r '.Instances[0].PrivateIpAddress' $path/output/instanceDetails.json)
	launchtime=$(jq -r '.Instances[0].LaunchTime' $path/output/instanceDetails.json)
	echo -e 'Instance Id: ' $insid
	echo -e 'Private Ip: ' $privip
	echo -e 'Launch Time: ' $launchtime
	sleep 3
	createlogfile
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

function ec2lifecycle {

    bash $path/snapshot/snapshot 3.sh

}

module