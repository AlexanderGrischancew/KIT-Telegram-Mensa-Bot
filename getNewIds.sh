#!/bin/bash
#get all messages of the past 24h off the server together wit their parameters:
update=$(curl -s -X POST https://api.telegram.org/bot_______________________/getUpdates | jq .)

#delete all tags:
updateSanitized=$(echo $update | sed 's/[[{",:]+*/ /g')
updateSanitized=$(echo $updateSanitized | sed 's/[]]/ /g')
#split at "}" and write each line to an array
IFS='}' read -r -a updateArray <<< $updateSanitized

#idArray-var needed for future reference
idArray=$(<ids.txt)
IFS=' ' read -r -a idArray <<< "$idArray"
#get size of the cleaned array wit all the messages and parameters
size=${#updateArray[@]}
for lineIndex in $(seq 0 $size)
do
	#if line starts with chat (line that contains chat_ID-Parameter)
	if [[ ${updateArray[lineIndex]} =~ chat ]] ; then
		#read arraypoint into string
		arrayString=${updateArray[lineIndex]}
		#extract id only:
		idString=${arrayString#*id}
		idString=${idString%first_name*}
		#---------------
		#asumed that its not duplicate(needed for futher reference) flag set to 0
		idDuplicate=0

		for Id in ${idArray[@]}
		do
			if [ $Id == $idString ] ; then
				idDuplicate=1
				#id already contained in array, set flag to 1
			fi
		done

		if [ $idDuplicate == 0 ] ; then
			#if duplicate flag is not 1, write id to end of array
			#get size of array
			lastIdArrayIndex=${#idArray[@]}
			#add 1 to array size to append new id to end:
			newIdArrayIndex=$((lastIdArrayIndex+1))
			idArray[newIdArrayIndex]=$idString
		fi
	fi

done

#write ids to file
echo ${idArray[@]}>ids.txt

