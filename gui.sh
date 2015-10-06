#!/bin/bash

docker run -d -p 80:8787 -v /home/horne/Projects/datascience:/home/dst \
	data-scientists-toolbox:0.2

