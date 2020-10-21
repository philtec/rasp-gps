#!/bin/bash
# Install
# dos2unix gpspipe cgps jq
# touch -f /home/pi/countermovement.txt
# mkdir /home/pi/gpsdata
# touch -f /home/pi/gpsdata/MovementLLBK.txt
# touch -f /home/pi/gpsdata/MovementLL.txt

youremail=PUT YOUR EMAIL HERE

count=0

# Detect Movement of the RV and email me

F1=$(cat /home/pi/gpsdata/MovementLLBK.txt |head -1 |sed 's/^ *//g' | dos2unix )
F2=$(cat /home/pi/gpsdata/MovementLLBK.txt |tail -1 |sed 's/^ *//g' | dos2unix )

G1=$(gpspipe -w -n 5 | jq -r '.lat' | grep "[[:digit:]]" | tail -1)
G2=$(gpspipe -w -n 5 | jq -r '.lon' | grep "[[:digit:]]" | tail -1)

	R1a=$(printf "%8.4f\n" "$F1" |sed 's/^ *//g')
	R1b=$(printf "%8.4f\n" "$G1" |sed 's/^ *//g')

	R2a=$(printf "%8.4f\n" "$F2" |sed 's/^ *//g')
	R2b=$(printf "%8.4f\n" "$G2" |sed 's/^ *//g')

		echo "$R1b" > /home/pi/gpsdata/MovementLL.txt
		echo "$R2b" >> /home/pi/gpsdata/MovementLL.txt

		mv /home/pi/gpsdata/MovementLL.txt /home/pi/gpsdata/MovementLLBK.txt



	result=$(echo "$R1a-$R1b" | bc -l)
	result2=$(bc <<< "$R2a- $R2b")


	if [[ "$result" == "0"  &&  "$result2" == "0" ]]; then
		echo "Long Not Changed"
			count=$(cat /home/pi/countermovement.txt)
                        count=$((count+1))
                        echo "$count" > /home/pi/countermovement.txt
	else
		echo -e "Subject: RV Movement Detection\r\n\r\n RV has moved it is now https://www.google.com/maps/place/$R1b,%20$R2b" |msmtp --debug --from=default -t $youremail

			echo "1" > /home/pi/countermovement.txt
                        sudo crontab -l -u root |sed '/movement.sh/d' |sudo crontab -u root - && { sudo crontab -l -u root 2>/dev/null; sudo echo "* * * * * /home/pi/movement.sh > /dev/null 2>&1 &"; } | sudo crontab -u root -

		fi



	if [ "$count" == "3" ]; then

                        sudo crontab -l -u root |sed '/movement.sh/d' |sudo crontab -u root - && { sudo crontab -l -u root 2>/dev/null; sudo echo "*/30 * * * * /home/pi/movement.sh > /dev/null 2>&1 &"; } | sudo crontab -u root -
                        echo "1" > /home/pi/countermovement.txt
                fi
