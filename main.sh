#!/bin/bash

#get food pln in html form:
foodPlanHtml=$(curl -s "http://mensa.akk.uni-karlsruhe.de/?DATUM=heute&uni=1&schnell=1")

#extract needed block:
foodPlan=${foodPlanHtml#*<!-- Liste Essen Anfang -->}
foodPlan=${foodPlan%Stand:*}
#-------------------

#Delete html tags:
foodPlan=$(echo $foodPlan | sed 's/<[^>]\+>/ /g')

#cut into lines and save in array
IFS=':€' read -r -a foodPlanArray <<< "$foodPlan"
#get size of array:
Size=${#foodPlanArray[@]}

#get server time:
serverDate=$(date +"%d.%m.%Y")
foodPlanFormated="Ihr Täglicher Mensaplan:%0Afür den: $serverDate%0A"

#read each line:
for Line in $(seq 0 $Size)
do
foodPlanArray[Line]=$(echo ${foodPlanArray[Line]} | sed 's/\W\s/ /g')

	if [[ ${foodPlanArray[Line]} =~ ^Linie ]]; then
	#adds newlines if "Line" is in the beggining
	foodPlanArray[Line]="%0A${foodPlanArray[Line]}:"
	fi

	if [[ ${foodPlanArray[Line]} =~ ^heut ]]; then
	coppyString=${foodPlanArray[Line]}
	firstString=${coppyString%Linie*}
	secondString=${coppyString#*Ausgabe }
	foodPlanArray[Line]="$firstString%0A%0A$secondString:"
	fi

	if [[ ${foodPlanArray[Line]} =~ [0-9]$ ]]; then
	#add Euro symbol at end if numbers ocur
	foodPlanArray[Line]="${foodPlanArray[Line]}€"
	fi

#echo ${foodPlanArray[Line]}

#add new line at end of each line, save into singel string
foodPlanFormated="$foodPlanFormated${foodPlanArray[Line]}%0A"
done

#------------------------------------------------------------------
#Dies is der interessante part.
#------------------------------------------------------------------

#chat ids saved into file "ids.txt " by getNewIds.sh
#read them into variable chatId
chatId=$(<ids.txt)
#seperate ids, save into array:
IFS=' ' read -r -a chatIdArray <<< "$chatId"

#send formated plan to each id
for Id in ${chatIdArray[@]}
do
#>/dev/null voides the output s its not shown in the console.
#replace the id after /bot with our bot-token.
curl -s -X POST https://api.telegram.org/bot__________________/sendMessage -d text="$foodPlanFormated" -d chat_id=$Id >/dev/null
done
#--------------------------------------------------------------------


