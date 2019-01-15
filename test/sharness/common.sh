#!/bin/sh

export JPY_USER=${JUPYTERHUB_USER:-jupyter}
export WORK=/home/jupyter/tacc-work
export SD2_DATA=/home/jupyter/sd2e-community
export PROJECTS_DATA=/home/jupyter/sd2e-projects
export PARTNERS_DATA=/home/jupyter/sd2e-partners
export PYTHONUSERBASE=/home/jupyter/tacc-work/jupyter_packages
export AGAVE_CACHE_DIR=/home/jupyter/.agave
if [ -z "$GIT_COMMITTER_EMAIL" ]; then
	# Refresh agave token
	if [ -e $AGAVE_CACHE_DIR/current ]; then
		auth-tokens-refresh -S >/dev/null 2>&1 || true
		# Get user info and populate git vars
        NAME=$(profiles-list -v me | jq -r '"\(.first_name) \(.last_name)"' 2>/dev/null || echo "Jupyter User")
		export GIT_COMMITTER_NAME="$NAME"
		export GIT_COMMITTER_EMAIL=$(profiles-list -v me | jq -r .email 2>/dev/null || echo ${JUPYTERHUB_USER:-jupyter}@tacc.cloud)
	else
		export GIT_COMMITTER_NAME="Jupyter User"
		export GIT_COMMITTER_EMAIL="jupyter@tacc.cloud"
	fi
fi
