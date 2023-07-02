#!/bin/bash

# Deafult Port
def_port='8080'

# Color Codes
CR=$'\e[1;31m' CG=$'\e[1;32m' CY=$'\e[1;33m' CB=$'\e[1;34m' CC=$'\e[1;36m' CW=$'\e[1;37m' RS=$'\e[1;0m'

architecture=`uname -m`

# Terminate Program
terminated() {
	printf "\n\n${RS} ${CR}[${CW}!${CR}]${CY} Exit√√ ${CR}[${CW}!${CR}]${RS}\n"
	exit 1
}

trap terminated SIGTERM
trap terminated SIGINT

kill_pid() {
	check_PID="php ngrok cloudflared loclx"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then
			killall ${process} > /dev/null 2>&1
		fi
	done
}

# Host Banner
logo(){

clear
echo "${CR}[~ ${CC}Happy new Year${CR} ~]
${CR}[~ ${CY}New${CR}.....${CC}2023${CR} ~]
${CG}┈┈┈┈┈┈${CR}╭̸╮̸${CG}┈┈┈┈┈╱▔▔▔╲
${CG} ┈┈┈▕▔▔▔▔▏╱╲╱${CC} Link${CG}▕
${CG} ┈┈┈┏▏${CR}▉▕▊${CG}┓▔╲╱${CC} Evel${CG}╱
${CG} ┈┈┈┗▏${CR}▅▅${CG}▕┛┈┈┈┈▔▔┈
${CG} ┈╱▔▔▔▔▔▔▔▔╲┈▕▔▏┈
${CG} ╱╱▔▏┏┳┳┓▕▔╲╲╱╱┈┈
${CG} ╲╲▕┓┗▅▅┛┏▏┈╲╱┈┈┈
${CR} ----------------
${CR} [${CW}~${CR}]${CY} X_Android ${CG}(${CC}Sudan${CG})${RS}"

}

path(){
	logo
	printf "\n${RS} ${CR}[${CW}1${CR}]${CY} Please Enter [1]"
	printf "\n${RS}"
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} input number : ${CC}"
	read red_path
	
	if [[ $red_path == 1 || $red_path == 01 ]]; then
		path=$'./htdocs'
	elif [[ $red_path == 0000 || $red_path == 00000 ]]; then
		printf "\n${RS} ${CC}Enter File Path [Example : /home/tahmid/htdocs]"
		printf "\n${RS}"
		printf "\n${RS} ${CR}>>${CG} ${CC}"
		read path
	else
		printf "\n${RS} ${CR}[${CW}!${CR}]${CR} Error ${CR}[${CW}!${CR}]${RS}\n"
		sleep 2 ; logo ; path
	fi

	[[ ! -d "$path" ]] && mkdir -p "$path"
	menu
}

package(){
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Setting up Environment..${RS}"
	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Installing ${CY}Proot${RS}\n"
			pkg install proot resolv-conf -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Environment Setup Completed !${RS}"
	else
		repr=(curl php unzip)
		for i in "${repr[@]}"; do
			type -p "$i" &>/dev/null || 
				{ 
					printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Installing ${CY}${i}${RS}\n"
					
					if [[ $(command -v pkg) ]]; then
						pkg install "$i" -y
					elif [[ $(command -v apt) ]]; then
						sudo apt install "$i" -y
					elif [[ $(command -v apt-get) ]]; then
						sudo apt-get install "$i" -y
					elif [[ $(command -v dnf) ]]; then
						sudo dnf -y install "$i"
					else
						printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Unfamiliar Distro ${CR}[${CW}!${CR}]${RS}\n"
						exit 1
					fi
				}
		done
	fi
}

## Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
		else
			mv -f $file $output > /dev/null 2>&1
		fi
		chmod +x $output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RS} ${CR}[${CW}!${CR}]${CY} Error occured while downloading ${CR}${output}."
		exit 1
	fi
}

## Install ngrok

## Host on Localhost. Just "php -S" lol
localhost() {
	printf "\n${RS} ${CR}[${CW}-${CR}]${CY} Input Port ${CG}[test:${def_port}]: ${CC}"
	read port
	port="${port:-${def_port}}"
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${port}${RS}\n"
	php -S 127.0.0.1:"$port" > /dev/null 2>&1 &
	sleep 2
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} link : ${CY}http://127.0.0.1:$port ${RS}"
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CR} Don,t open link in your phone ${CG}:-)"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

## Start ngrok
ngrok() {
	ngrok_auth
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${def_port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
	sleep 1
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Launching Ngrok on Port ${CY}${def_port}${RS}"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./ngrok --config ".ngrok.yml" http 127.0.0.1:"$def_port" --log=stdout > /dev/null 2>&1 &
	else
		sleep 2 && ./ngrok --config ".ngrok.yml" http 127.0.0.1:"$def_port" --log=stdout > /dev/null 2>&1 &
	fi

	sleep 8
	ngrk=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -Eo '(https)://[^/"]+(.ngrok.io)')
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully Hosted at : ${CY}${ngrk}${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

## Start Cloudflared
cloudflared() { 
	rm .cld.log > /dev/null 2>&1 &
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${def_port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
	sleep 1
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Launching Cloudflared on Port ${CY}${def_port}${RS}"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./cloudflared tunnel -url 127.0.0.1:"$def_port" --logfile ".cld.log" > /dev/null 2>&1 &
	else
		sleep 2 && ./cloudflared tunnel -url 127.0.0.1:"$def_port" --logfile ".cld.log" > /dev/null 2>&1 &
	fi

	sleep 8
	cldflr=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully Hosted at : ${CY}${cldflr}${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

## Start LocalXpose
localxpose() { 
	rm .loclx.log > /dev/null 2>&1 &
	localxpose_auth
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${def_port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
	sleep 1
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Launching LocalXpose on Port ${CY}${def_port}${RS}"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./loclx tunnel --raw-mode http --https-redirect -t 127.0.0.1:"$def_port" > ".loclx.log" 2>&1 &
	else
		sleep 2 && ./loclx tunnel --raw-mode http --https-redirect -t 127.0.0.1:"$def_port" > ".loclx.log" 2>&1 &
	fi
	
	sleep 8
	loclx_url=$(grep -o '[0-9a-zA-Z.]*\.loclx.io' ".loclx.log")
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully Hosted at : ${CY}http://${loclx_url}${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

menu() {

			localhost;
}

kill_pid
package
install_cloudflared
install_localxpose
path

