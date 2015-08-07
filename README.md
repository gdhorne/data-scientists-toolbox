# data-scientists-toolbox

Create a Docker container for RStudio Server from scratch using the associated GitHub [repository](https://github.com/gdhorne/data-scientists-toolbox) or by fetching the pre-built [image]() from the Docker website.

## Create a container from a Pre-built Image 

Download and install the Docker software for Apple Mac OS X, GNU/Linux or Microsoft Windows following the [instructions](http://docs.docker.com/linux/started/) at the [Docker](https://www.docker.com) website.

Retrieve the image and start the container running on the specified port, optionally using the host filesystem for storage as shown in the following examples.

Example 1:

    $ docker run -d -p 80:8787 gdhorne/data-scientists-toolbox

In this example any R packages and R scripts created will be stored inside the container. The first port 80 represents the local port on which your web browser can communicate with RStudio Server which internally uses port 8787. You can modify the first port when you run the preceding command-line.

Example 2:

    $ docker run -d -p 80:8787 -v /home/me/datascience:/home/dst \
        gdhorne/data-scientists-toolbox

In this example any R packages and R scripts created will be stored on the host system instead of inside the container. You can modify the host directory from '/home/me/datascience' to whatever is suitable for your environment. The first port 80 represents the local port on which your web browser can communicate with RStudio Server which internally uses port 8787. You can modify the first port when you run the preceding command-line.

Out of the gate R, RStudio, and Git are already installed as a convenience.

Type http://127.0.0.1:80, or http://127.0.0.1 without a port number since port 80 is the default HTTP port, in the address field of a web browser to display the RStudio Server login screen. The userid is 'dst' and the default password is 'science'.

## Build from Scratch

Download and install the Docker software for Apple Mac OS X, GNU/Linux or Microsoft Windows following the [instructions](http://docs.docker.com/linux/started/) at the [Docker](https://www.docker.com) website.

Build the image and start the container running on the specified port optionally using the host filesystem for storage as shown in the example.

    $ docker build -t image_name:version_tag path_to_dockerfile
    $ docker run -d -p host_port:container_port \
                 -v host_directory:container_directory \
                 image_name:version_tag

Example:

    $ git clone https://github.com/gdhorne/data-scientists-toolbox
    $ cd data-scientists-toolbox	    
    $ docker build -t data-scientists-toolbox:0.1 .
    $ docker run -d -p 80:8787 -v /home/me/data:/home/dst data-scientists-toolbox:0.1 

Type http://127.0.0.1:80, or http://127.0.0.1 without a port number since port 80 is the default HTTP port, in the address field of a web browser to display the RStudio Server login screen. The userid is 'dst' and the default password is 'science'. Changing the password via the RStudio Tools menu select Shell and type passwd at the prompt.

## Starting and Stopping a Container

Normally a container can be left in running state unless you want to remove the container or power-down the computer system. Simply logging out of the current RStudio session does not shutdown RStudio Server.

After logging out the running container can be shutdown using the command:

    $ docker stop container_name

To restart the container use the command:

    $ docker start container_name

To determine the container name use the command:

    $ docker ps -a

    CONTAINER ID        IMAGE                             COMMAND                CREATED             STATUS       
    af963946e2b7        gdhorne/data-scientists-toolbox   "/usr/bin/supervisor   35 minutes ago      Up 35 minutes
    PORTS                   NAMES
    0.0.0.0:80->8787/tcp    boring_fermi

If you prefer a memoerable name for your container use the command:

    $ docker rename new_name old_name

