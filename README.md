# data-scientists-toolbox

Create a Docker container for RStudio Server from scratch using the associated GitHub [repository](https://github.com/gdhorne/data-scientists-toolbox) or by fetching the pre-built [image]() from the Docker website.

## Create a container from a Pre-built Image 

Download and install the Docker software for Apple Mac OS X, GNU/Linux or Microsoft Windows following the [instructions](http://docs.docker.com/linux/started/) at the [Docker](https://www.docker.com) website.

Retrieve the image and start the container running on the specified port, optionally using the host filesystem for storage as shown in the following examples.

Example 1:

    $ docker run -d -p 80:80 gdhorne/data-scientists-toolbox

In this example any R packages and R scripts created will be stored inside the container. The first port 80 represents the local port on which your web browser can communicate with RStudio Server which internally uses port 80. When you run the preceding command-line you can modify the first port to avoid conflicts with another web server on the same host system.

Example 2:

    $ docker run -d -p 8008:80 -v /home/me/datascience:/home/dst \
        gdhorne/data-scientists-toolbox

In this example any R packages and R scripts created will be stored on the host system instead of inside the container. You can modify the host directory from '/home/me/datascience' to whatever is suitable for your environment. The first port 8008 represents the local port on which your web browser can communicate with RStudio Server which internally uses port 80. When you run the preceding command-line you can modify the first port to avoid conflicts with another web server on the same host system.

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
    $ docker run -d -p 80:80 -v /home/me/data:/home/dst data-scientists-toolbox:0.1 

If you omit the ':0.1' a default value of 'latest' is substituted.

Type http://127.0.0.1:80, or http://127.0.0.1 without a port number since port 80 is the default HTTP port, in the address field of a web browser to display the RStudio Server login screen. The userid is 'dst' and the default password is 'science'. Change the password via the RStudio Tools menu select Shell and type passwd at the prompt.

## Basic Container Management

Simply logging out of the current RStudio session does not shutdown RStudio Server.

|Action|Command|
|======|=======|
|Get container name|docker ps -a|
|Change container name|docker rename new\_name current\_name|
|Stop container|docker stop container\_name|
|Pause container|docker start container\_name|
|Restart container|docker restart container\_name|

The data-scientists-toolbox container supports command line interaction for people with a preference for the command-line. For convenience the screen management utility 'screen' has been installed.

    $ docker run -i -t -v /home/horne/Projects/datascience:/home/dst \
        -u dst data-scientists-toolbox:0.2 \
        sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"

Without a controlling TTY the screen utility would not function.

