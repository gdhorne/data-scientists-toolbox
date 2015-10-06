#!/bin/bash

docker run -i -t -v /home/horne/Projects/datascience:/home/dst \
	-u dst data-scientists-toolbox:0.2 \
	sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"

