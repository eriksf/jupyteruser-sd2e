#!/bin/sh

test_description="Agave CLI and Oauth Tests"

. ./lib/sharness/sharness.sh
. ../common.sh

echo ""
echo "Please make sure the Agave CLI is installed and is"
echo "available in your PATH. Also, make sure to have a current"
echo "access token from the sd2e tenant."
echo ""

test_expect_success "agave cli is installed" '
    command -v auth-check >/dev/null &&
    command -v apps-list >/dev/null &&
    command -v jobs-submit >/dev/null
'

test_expect_success "agave cli command 'auth-check' works" '
    auth-check >auth_output
'

TENANT=$(cat auth_output | awk "/^tenant:/ { print \$2 }")
test_expect_success "sd2e tenant is selected" '
    test "${TENANT}" = "sd2e"
'

TIMELEFT=$(cat auth_output | awk "/^time left:/ { print \$3 }")
test_expect_success "sd2e access token is current" '
    test "${TIMELEFT}" -gt 0
'

test_expect_success "agave cli command 'apps-list' works" '
    apps-list >apps_output
'

test_expect_success "can refresh token" '
    auth-tokens-refresh -S
'

test_expect_success "can poll abaco reactors" '
    abaco ls
'

test_done
