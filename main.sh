#!/bin/bash
API_KEY="YOUR API KEY"
URL="https://api.openai.com/v1/chat/completions"
MODEL_CLI="gpt-3.5-turbo-0125"
MODEL_ASSISTANT="gpt-3.5-turbo-0125"

send_data=$(mktemp)
function clean_string() {
	clean=$1
	#I DONT CARE: #Backspace is replaced with \b
	clean=$(echo "$clean" | sed 's/\\/\\\\/g')	# Backslash is replaced with \\
	clean=$(echo "$clean" | sed 's/\f/\\f/g')	# Form feed is replaced with \f
	clean=$(echo "$clean" | sed 's/$/\\n/g' | tr '\n' ' ')	# Newline is replaced with \n
	clean=$(echo "$clean" | sed 's/\r/\\r/g')	# Carriage return is replaced with \r
	clean=$(echo "$clean" | sed 's/\t/\\t/g')	# Tab is replaced with \t
	clean=$(echo "$clean" | sed 's/\"/\\\"/g')	# Double quote is replaced with \"
	echo "$clean"
}
function get_response() {
	local prompt=$1
	local prompt=$(clean_string "$prompt")
	local new_message='.messages[.messages| length] |= . + {"role": "user", "content": "'$prompt'"}'
	echo $(cat "$send_data" | jq "$new_message") > $send_data
	local response_data=$(
		curl -s $URL \
			-H "Content-Type: application/json" \
			-H "Authorization: Bearer $API_KEY" \
			-d "$(cat $send_data)"
	)
	local response_message=$(echo "$response_data" | jq '.choices[0].message')
	local add_response_message='.messages[.messages| length] |= . + '"$response_message"
	echo $(cat "$send_data" | jq "$add_response_message") > $send_data

	echo "$(echo $response_message | jq -r '.content')"
}
function first_message_cli() {
	read -p "What is your question? " question
	local prompt=$(clean_string "$question")
	may_run "$prompt"
}
function continue_messages() {
	echo -en '\e[34mYou: \t\e[0m'
	read -e input
	local prompt=$input
	local prompt=$(clean_string "$prompt")
	may_run "$prompt"
}
function may_run() {
	local prompt=$1
	local response_command=$(get_response "$prompt")
	if [ $CLI = true ]; then
		input_after_cli "$response_command"
	else
		echo -e '\e[33mAI: \t'"$response_command"'\e[0m'
		continue_messages
	fi
}
function input_after_cli() {
	local response_command=$1
	echo \
'The command to be run is
"
	'$response_command'
"
Do you wish to:
	Execute it (E/\n)
	Continue chating (C)
	Start new '${SHELL##*/}' session (s)(com back here with exit/^d)
	Exit (E/^C)
' 
	read input
	case $input in 
		e | E | "")
			eval "$response_command"
		;;
		c | C)
			continue_messages
		;;
		s | S)
			eval $SHELL
		;;
		e | E)
			exit
		;;
		*)
		;;
	esac
	input_after_cli "$response_command"
}
CLI=false
case $1 in 
	cli)
		OPENAI_MODEL=$MODEL_CLI
		system_prompt='
			You are the new interpreter for linux computers. You let the user write a task, and translate that into plug-and-play bash messages, that can be executed by the standard bash interpreter. You NEVER brake the fasad, always responding with the apropriate bash command. 

			The response is a command that can be executed in bash. It is not wraped in quotations or anything similar. You may asume that all popular or applicable cli tools are downloaded and in PATH.

			The current user directory, and the subsequent 3, are:
			```'"$(find . -type d -o -type f | head -n 20)"'
			```
			'
		CLI=true
		;;
	assist | "")
		OPENAI_MODEL=$MODEL_ASSISTANT
		system_prompt="You're an helpful assistant that helps ass musch as you can :)"
		;;
	help)
		echo '
		A tool for interacting with ai. Make sure to set the api key in the source code.

		options:
		 - cli: a tool to automatically generate cli commands using ai. Has access to the current directory and the 2 subsequent ones, uses gpt-3.5-turbo-0125
		 - assis (default), chat bot, uses gpt-4
		'
		exit
	;;

esac

system_prompt=$(clean_string "$system_prompt")

echo '
	{
		"model": "'$OPENAI_MODEL'",
		"messages": [
			{
				"role": "system",
				"content": "'$system_prompt'"
			}
		],
		"temperature": 0.7,
		"response_format": {
			"type": "text"
		}
	}
' > $send_data

if [ $CLI = true ]; then
	first_message_cli
else
	continue_messages
fi

