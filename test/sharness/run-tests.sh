#!/bin/sh
set -e

nohup /usr/local/bin/start-notebook.sh &
/test/wait-for-it.sh localhost:8888 -- echo "Jupyter server is running"
make
