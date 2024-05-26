
This tool lets you chat with openai's chat botts using you terminal. It supports two modes
 - 'assistant' let's you chat with gpt-4 (similar to chatgpt)
 - 'cli' let's you ask for a command you do not know by hart and it will give you the command, with the option to execute, continue chating or test it out in a new SHELL section 
 ```txt
[bob@foo ~]$ ai cli
What is your question? how do i convert an h264 encoded mp4 to av1
The command to be run is
"
	ffmpeg -i input.mp4 -c:v libaom-av1 -crf 30 output.av1
"
Do you wish to:
	Execute it (E/\n)
	Continue chating (C)
	Start new bash session (s)(com back here with exit/^d)
	Exit (E/^C)
```

#Installation
Install the dependencies
- bash
- curl
- jq
Copy the `main.sh` file into your PATH with a name of your liking, make it executable. Get an api key frome [openai]{openai.com/api} set the value of `OPENAI_API_KEY` in the source code. 


#Contribution
Do you have an though of how this litle program can improve? Great! Make an issue and i will merge. Here are som short guidelines:
- I want to keep this a one-filer
- All dependencies should be redely available on all major distributions.
