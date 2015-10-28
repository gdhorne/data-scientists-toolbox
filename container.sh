#!/bin/bash

###############################################################################
# Data Science Toolbox for Data Science Specialization                        #
#                                                                             #
# Manage containers for the Data Science Specialization                       #
# Johns Hopkins University                                                    #
#                                                                             #
# Version 0.1, Copyright (C) 2015 Gregory D. Horne                            #
#                                 (horne at member dot fsf dot org)           #
#                                                                             #
# Licensed under the terms of the GNU General Public license (GPL) v2         #
###############################################################################

###############################################################################
# Display an information banner                                               #
###############################################################################

function display_banner() {

	echo
	echo "Data Science Toolbox for 'Data Science Specialization'"
	echo "version 0.1, Copyright (C) 2015 Gregory D. Horne"
	echo
	echo "Data Science Toolbox comes with ABSOLUTELY NO WARRANTY;"
	echo "for details read the LICENSE file."
	echo "This is free software, and you are welcome to redistribute it"
	echo "under certain conditions; read the LICENSE for details."
	echo
	echo "Further informmation about the Data Science Specialization"
	echo "offered by Johns Hopkins University as a Massively Open-Online"
	echo "Course (MOOC) using the Coursera platform can be found at"
	echo -e "\n\tData Science Specialization"
	echo -e "\t\thttps://www.coursera.org/specializations/jhudatascience"
	echo -e "\n\tCoursera\n\t\thttps://coursera.org"
	echo
	echo "This software and associated documentation has been developed"
	echo "independently of Johns Hopkins University and Coursera. It is"
	echo "provided as a convenience to participants in the Data Science "
	echo "Specalization."
	echo
	echo
}

###############################################################################
# Process container lifecycle management requests.                             #
###############################################################################

function manage_container() {

	local retcode=0
	
	if [[ ${1} != "attach" && ${1} != "create" && ${1} != "detach" && \
		${1} != "kill" && ${1} != "pause" && ${1} != "unpause" && \
		${1} != "start" && ${1} != "stop" && ${1} != "status" ]]
	then
		echo "Error: invalid command/action. Type 'container.sh --help'"
		exit -1
	elif [[ ${1} != "status" && -z ${2} ]]
	then
		echo -n "Error: 'container ${1}' requires a container name or "
		echo "id as the second argument"
		echo "       (e.g.) container ${1} toolbox"
	fi

	case ${1} in
		attach)
			if [[ -z `docker ps --filter=name=${2} | \
				grep --ignore-case paused` && \
			       	-z `docker ps --all=true | grep ${2} | \
				grep --ignore-case exited` ]]
			then
				echo "Attaching to existing container [${2}]."
				echo "Press ENTER to continue."
				docker attach ${2}
			else
				echo "Error: Container [${2}] is not running."
				retcode=-1
			fi
			;;
		create)
			if [[ -z `docker ps --all=true | grep ^${2}` ]]
			then
				echo "Building/fetching container image [${3}]."
				if [ -z `docker images | \
					grep ^${3%:*} |\
				       	cut -d\  -f1` ]
				then
					if [[ ! -z `echo ${3} | grep /`  ]]
					then
						docker pull ${3}
					else
						docker build -t ${3} .
					fi
				fi
				echo "Creating container [${2}]."
				if [[ -z ${4} ]]
				then
					docker run \
							--detach=true \
							--hostname=${2} \
							--interactive=true \
							--tty=true \
							--publish=8000:8000 \
							--publish=8787:8787 \
							--volume=/tmp/.X11-unix:/tmp/.X11-unix \
							--env=DISPLAY=unix$DISPLAY \
							--name=${2} \
							${3}
				else
					docker run \
							--detach=true \
							--hostname=${2} \
							--interactive=true \
							--tty=true \
							--publish=8000:8000 \
							--publish=8787:8787 \
							--volume=/tmp/.X11-unix:/tmp/.X11-unix \
							--env=DISPLAY=unix$DISPLAY \
							--name=${2} \
							--volume=${4}:/home/gdst/data \
							${3}
				fi
			else
				echo -n "Error: Container with name [${2}] "
				echo "already exists."
				retcode=-1
			fi
			;;
		kill)
			if [[ ! -z `docker ps --filter=name=${2} | grep ${2}` ]]
			then
				if [[ -z `docker ps --filter=name=${2} | \
					grep --ignore-case paused` ]]
				then
					echo "Terminating container [${2}]."
					docker stop ${2} > /dev/null 2>&1
					docker rm ${2} > /dev/null 2>&1
				elif [[ ! -z `docker ps --filter=name=${2} | \
					grep --ignore-case paused` ]]
				then
					echo -n "Error: Container [${2}] must "
					echo "be running or stopped."
				fi
			elif [[ ! -z `docker ps --all=true | grep ${2}` ]]
			then
				echo "Terminating container [${2}]."
				docker rm ${2} > /dev/null 2>&1
			else
				echo "Error: Container [${2}] does not exist."
				retcode=-1
			fi
			;;
		pause)
			if [[ ! -z `docker ps --filter=name=${2}` ]]
			then
				if [[ ! -z `docker ps --filter=name=${2} | \
					grep --ignore-case --invert-match paused` &&  \
					! -z `docker ps --all=true | \
					grep ${2} | \
					grep --ignore-case --invert-match exited` ]]
				then
					echo "Pausing container [${2}]."
					docker pause ${2} > /dev/null 2>&1
				else
					echo -n "Error: Container [${2}] is not "
					echo "running and cannot be paused."
					retcode=-1
				fi
			elif [[ ! -z `docker ps --all=true | grep ${2}` ]]
			then
				echo -n "Error: Container [${2}] is not running "
				echo "and cannot be paused."
			else
				echo "Error: Container [${2}] does not exist."
				retcode=-1
			fi
			;;	
		unpause)
			if [[ ! -z `docker ps --filter=name=${2} | \
				grep --ignore-case paused` ]]
			then
				echo "Unpausing container [${2}]."
				docker unpause ${2} > /dev/null 2>&1
			elif [[ ! -z `docker ps --all=true | grep ${2}` ]]
			then
				echo "Error: Container [${2}] is not paused."
			else
				echo "Error: Container [${2}] does not exist."
				retcode=-1
			fi
			;;
		start)
			if [[ -z `docker ps --filter=name=${2} | grep ${2}` && \
				! -z `docker ps --all=true | grep ${2}` ]]
			then
				echo "Starting container [${2}]."
				docker start ${2} > /dev/null 2>&1
			elif [[ !  -z `docker ps --filter=name=${2}` && \
				-z `docker ps --filter=name=${2} | \
			       	grep -v Paused` ]]
			then
				echo -n "Error: Container [${2}] is already "
				echo "running."
			elif [[ ! -z `docker ps --filter=name=${2} | \
				grep Paused` ]]
			then
				echo "Error: Container [${2}] is paused."
			else
				echo "Error: Container [${2}] does not exist."
				retcode=-1
			fi
			;;
		stop)
			if [[ -z `docker ps --filter=name=${2} | \
				grep --ignore-case paused` && \
				-z `docker ps --all=true | grep ${2} | \
				grep --ignore-case exited` ]]
			then
				echo "Stopping container [${2}]."
				docker stop ${2} > /dev/null 2>&1
			elif [[ ! -z `docker ps --all=true | grep ${2}` ]]
			then
				echo "Error: Container [${2}] is not running."
			else
				echo "Error: Container [${2}] does not exist."
				retcode=-1
			fi
			;;
		status)
			if [ -z ${2} ]
			then
				docker ps -all=true
			else
				docker ps --filter=name=${2}
			fi
			;;
		*)
			echo -n "Error: container ${1}: invalid command"
			echo "Type 'container.sh --help'"
			retcode=-1
			;;
	esac

	return ${retcode}
}

###############################################################################
# Display usage information.                                                  #
###############################################################################

function display_usage() {
	echo
	echo -e -n "Usage: ${0} [-h | --help | -v | --version]|"
	echo "[<action> [<argument>*] <container>]"
	echo 
	echo "options:"
	echo -e "\t-h, --help\n\t\tDisplay this help information."
	echo -e "\t-v, --version\n\t\tDisplay version information"
	echo
	echo -e "action"
	echo -e "\tcreate\tcreate a new container from an existing image"
	echo -e "\t\t./containter.sh create <container> <image_name> [<host_directory>]"
	echo -e "\tkill\tterminate an existing container"
	echo -e "\t\t./container.sh kill <container>"
	echo -e "\tpause\tpause a running container"
	echo -e "\t\t./container.sh pause <container>"
	echo -e "\tunpause\tunpause an existing container"
	echo -e "\t\t./container.sh unpause <container>"
	echo -e "\tstart\tstart an existing container"
	echo -e "\t\t./container.sh start <container>"
	echo -e "\tstop\tstop a running container"
	echo -e "\t\t./container.sh stop <container>"
	echo -e -n "\tstatus\tdisplay the current status of an existing "
	echo "container or all containers"
	echo -e "\t\t./container.sh [<container>]"
	echo -e "container\n\t\t<container name>\n\t\t<container id>"
	echo
}

###############################################################################
# Display version information.                                                #
###############################################################################

function display_version() {

	echo
	echo "Data Science Toolbox for 'Data Science Specialization'"
	echo "version 0.1, Copyright (C) 2015 Gregory D. Horne"
	echo
}

###############################################################################
# Parse command line arguments and dispatch appropriate handler function.     #
###############################################################################

if [ $# -lt 1 ]
then
	display_banner
	display_usage
	exit 1
elif [[ ${1} == "-h" || ${1} == "--help" ]]
then
	display_banner
	display_usage
	exit 0
elif [[ ${1} == "-v" || ${1} == "--version" ]]
then
	display_version
	exit 0
elif [[ $# -gt 0 && $# -lt 5 ]]
then
	manage_container ${1} ${2} ${3} ${4}
	exit $?
fi

