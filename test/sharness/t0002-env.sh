#!/bin/sh

test_description="Jupyter Environment Checks"

. ./lib/sharness/sharness.sh
. ../common.sh

taccname=$(profiles-list me | cut -f 1 -d "@")
taccuser=$(profiles-list -v me | jq -r '"\(.username)"')
fullname=$(profiles-list -v me | jq -r '"\(.first_name) \(.last_name)"')

test_expect_success "running as the jupyter user" '
    test "$(echo $USER)" = "jupyter"
'

test_expect_success "GIT_COMMITTER_NAME is set to TACC user" '
    test "$(echo $GIT_COMMITTER_NAME)" = "$fullname"
'

test_expect_success "GIT_COMMITTER_EMAIL is set to real email address" '
    test "$(echo $GIT_COMMITTER_EMAIL)" = "${taccname}@tacc.utexas.edu"
'

test_done
