#!/bin/bash


limit=$1
inapp=$(rev <(echo $2) | cut -d"/" -f2- | rev)


if [ $# -eq 0 ]
then
	echo "Missing Number of Arguments"
	exit
fi

first=$($inapp/smc -t | sort -k 2 | tail -$1)

direct=$(echo "$first" | awk '{print $2}')
codes=$(echo "$first" | cut -c2)

arr=($codes)
val=($direct)

for i in ${!arr[@]}
do
	 code=${arr[$i]}
	 temp=${val[$i]}

	 case $code in
		 C) echo -e "CPU : \t \t 	 $temp" ;;
		 H) echo -e "Drive : \t \t 	 $temp" ;;
		 M) echo -e "Memory : \t 	 $temp" ;;
		 W) echo -e "Network : \t 	 $temp" ;;
		 P) echo -e "Platform : \t 	 $temp" ;;
		 B) echo -e "Battery : \t 	 $temp" ;;
		 G) echo -e "GPU : \t \t 	 $temp" ;;
		 s) echo -e "Palm Rest : \t 	 $temp" ;;
		 p) echo -e "Power Supply :      $temp" ;;
		 *) echo -e "Misc. \t \t 	 $temp" ;;
	 esac
done


