#!/bin/sh

test_description="Jupyter Server Checks"

. ./lib/sharness/sharness.sh

#  grab token
token=$(jq -r .token /home/jupyter/.local/share/jupyter/runtime/nbserver-*.json)

test_expect_success "get the status of the running jupyter notebook server" '
    connections=$(curl -H "Authorization: token ${token}" http://localhost:8888/api/status | jq -r .connections)
    test "${connections}" = "0"
'

# grab the kernelspecs
curl -H "Authorization: token ${token}" http://localhost:8888/api/kernelspecs 2>/dev/null | jq . >kernelspecs

test_expect_success "check for the R kernel" '
    kernel=$(cat kernelspecs | jq -r '.kernelspecs.ir.name') &&
    test "${kernel}" = "ir"
'

test_expect_success "check for the python3 kernel" '
    kernel=$(cat kernelspecs | jq -r '.kernelspecs.python3.name') &&
    test "${kernel}" = "python3"
'

test_expect_success "check for the python2 kernel" '
    kernel=$(cat kernelspecs | jq -r '.kernelspecs.python2.name') &&
    test "${kernel}" = "python2"
'

test_expect_success "check for the lisp kernel" '
    kernel=$(cat kernelspecs | jq -r '.kernelspecs.lisp.name') &&
    test "${kernel}" = "lisp"
'

test_expect_success "check for the bash kernel" '
    kernel=$(cat kernelspecs | jq -r '.kernelspecs.bash.name') &&
    test "${kernel}" = "bash"
'

test_done
