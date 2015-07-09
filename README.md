# data-scientists-toolbox

Create a Docker container for RStudio Server from scratch or by fetching the pre-built image from the [Docker](https://www.docker.com) website.

## Build from Scratch

Download and install the Docker software for Apple Mac OS X, GNU/Linux or Microsoft Windows following the [instructions](http://docs.docker.com/linux/started/) at the [Docker](https://www.docker.com) website.

Build the image and start the container running on the specified port optionally using the host filesystem for storage as shown in the example.

    $ docker build -t image_name:version_tag path_to_dockerfile
    $ docker run -d -p container_port:host_port \
                 -v host_directory:container_directory \
                 image_name:version_tag
    
    $ docker build -t dst:0.1 .
    $ docker run -d -p 8787:8787 -v /home/me/data:/home/dst dst:0.1

In this example the image will be named 'dst' and the 

## Create from the Pre-built Image

Map a directory on the host system to the exported volume defined in Dockerfile.
    $ docker run -d -p 8787:8787 -v /home/me/data:/home/dst dst:0.1

Isolate the filesystem of the container from the host system.
    $ docker run -d -p 8787:8787 dst:0.1

Type http://127.0.0.1:8787 in the address field of a web browser to display the RStudio Server login screen. The userid is 'dst' and the default password is 'science'. Changing the password via the RStudio Toolls menu select Shell and type passwd at the prompt.
