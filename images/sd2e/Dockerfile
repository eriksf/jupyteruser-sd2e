#Image: sd2e/jupyteruser-sd2e
#Version: 0.3.7

FROM taccsciapps/jupyteruser-base:1.1.0

# Convenience variable
ARG CONDA_ARGS="--quiet --no-update-deps --yes"

# Image release
USER root
ARG image_version=development
RUN echo "${image_version}" > /etc/sd2e_jupyteruser-sd2e-release && \
	chmod a+r /etc/sd2e_jupyteruser-sd2e-release

##########################################
# SD2E-specific Environment variables
##########################################
RUN echo "\n\nexport SD2_DATA=/home/jupyter/sd2e-community\n\
export PROJECTS_DATA=/home/jupyter/sd2e-projects\n\
export PARTNERS_DATA=/home/jupyter/sd2e-partners" >> /home/jupyter/.bashrc

###############################################
# Affiliated projects
###############################################
ADD src/add-sd2e-groups.sh /tmp/add-sd2e-groups.sh
RUN bash /tmp/add-sd2e-groups.sh && docker-clean

##########################################
# Readme
##########################################
ADD docs/SD2E_README.ipynb /home/jupyter/SD2E_README.ipynb

##########################################
# Agave tools
##########################################
# SD2E CLI
ADD src/configuration.rc configuration.rc
RUN git clone https://github.com/SD2E/sd2e-cli.git && \
	mv configuration.rc sd2e-cli/ && cd sd2e-cli && \
	git submodule update --init --recursive && \
	make && make install && \
	cd ../ && rm -rf sd2e-cli && \
	mv ${HOME}/sd2e-cloud-cli /opt/cli && \
	chmod -R a+rX /opt/cli && chmod -R a+x /opt/cli/bin && \
	docker-clean
# Enable sd2nb sharing service
RUN cd /root && \
	git clone https://github.com/SD2E/sd2nb-app.git && \
	( cd sd2nb-app && make && make install ) && \
	rm -rf sd2nb-app && \
	docker-clean
# Enable sd2e-jupyter
RUN cd /root && \
	git clone https://github.com/SD2E/sd2e-jupyter-ascending.git && \
	( cd sd2e-jupyter-ascending && make && make install ) && \
	rm -rf sd2e-jupyter-ascending && \
	docker-clean

##########################################
# igraph and networkx
##########################################
USER root
LABEL "comment"="Support for plotly igraph and networkx" "issue"="SD2E/jupyteruser-sd2e/issues/3"
RUN conda install ${CONDA_ARGS} plotly networkx && \
	bash -c "source activate base && pip install python-igraph" && \
	conda install ${CONDA_ARGS} -n python2 plotly networkx && \
	bash -c "source activate python2 && pip install python-igraph" && \
	docker-clean

##########################################
# Probcomp stack
##########################################
USER root

LABEL "comment"="Support for Open Probabilistic Programming Stack" "issue"="SD2E/jupyteruser-sd2e/issues/2"

# Install run dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends libgsl0-dev && \
	conda install -n python2 ${CONDA_ARGS} flask jsonschema patsy requests six && \
	conda install -n python2 ${CONDA_ARGS} -c conda-forge ncurses apsw && \
	docker-clean
# Install probcomp software stack
### Make sure to remove build deps
RUN apt-get update && apt-get install -y --no-install-recommends libboost-all-dev ccache
RUN bash -c "export MPLBACKEND=Agg && source activate python2 && \
	pip install git+https://github.com/probcomp/Venturecxx@v0.5.1.1 && \
        pip install git+https://github.com/probcomp/cgpm.git@v0.1.2 && \
        pip install git+https://github.com/probcomp/crosscat.git@v0.1.56.1 && \
        pip install git+https://github.com/probcomp/bayeslite.git@v0.3.2 && \
        pip install git+https://github.com/probcomp/iventure.git@v0.2.3" && \
	rm -rf .ccache && \
	apt-get --purge remove -y libboost-all-dev ccache && \
	apt-get --purge -y autoremove && \
	docker-clean
# Grab latest example notebooks
RUN mkdir -p /home/jupyter/examples/probcomp && \
	cd /home/jupyter/examples/probcomp && \
	curl http://probcomp-workshop-materials.s3.amazonaws.com/latest.tgz | tar -xzf -

##########################################
####  Common Lisp Kernel Setup Begin  ####
##########################################

ENV CL_PREFIX=/opt/common-lisp
ARG CLV=1.4.6-x86-64-linux
# Install dependency
RUN apt-get update && apt-get install -yq --no-install-recommends libzmq3-dev && \
	docker-clean
# Install SBCL
RUN curl -L prdownloads.sourceforge.net/sbcl/sbcl-${CLV}-binary.tar.bz2 | tar -xjf - && \
	( cd sbcl-${CLV} && INSTALL_ROOT=${CL_PREFIX} bash install.sh ) && \
	rm -rf sbcl-${CLV} && \
	docker-clean
# Set env variable for sbcl http://www.sbcl.org/getting.html
ENV SBCL_HOME=${CL_PREFIX}/lib/sbcl
ENV PATH=${CL_PREFIX}/bin:${PATH}

COPY common-lisp/ql_setup.lisp ${CL_PREFIX}/ql_setup.lisp

# Install the common lisp jupyter kernel
RUN cd ${CL_PREFIX} && \
    git clone https://github.com/fredokun/cl-jupyter.git && \
    ( cd cl-jupyter && rm -rf .git && ${CONDA_DIR}/bin/python ./install-cl-jupyter.py ) && \
    curl -LO https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load ql_setup.lisp && \
    rm quicklisp.lisp ql_setup.lisp

# SBCL init file
# Loads required packages for common lisp kernel
# everytime sbcl starts
COPY common-lisp/sbclrc /home/jupyter/.sbclrc

# Move the kernel json file to the correct location
RUN cp -r $HOME/.ipython/kernels/lisp ${CONDA_DIR}/share/jupyter/kernels/ && \
    rm -rf $HOME/.ipython && \
    chmod -R a+rX ${CONDA_DIR}/share/jupyter/kernels/lisp && \
    docker-clean

COPY examples/common-lisp /home/jupyter/examples/common-lisp

USER jupyter
RUN sbcl --load ${CL_PREFIX}/cl-jupyter/cl-jupyter.lisp

##########################################
# pyemd support
##########################################
USER root
LABEL "comment"="support for pyemd" "issue"="SD2E/jupyteruser-sd2e/issues/8"
RUN conda install ${CONDA_ARGS} pyemd && \
	conda install ${CONDA_ARGS} -n python2 pyemd && \
	docker-clean

##########################################
# Support DSGRN code
##########################################
USER root
LABEL "comment"="Support DSGRN code" "issue"="SD2E/jupyteruser-sd2e/issues/9"
RUN apt-get update && apt-get install -yq --no-install-recommends cmake graphviz && \
	conda install ${CONDA_ARGS} python-graphviz && \
	conda install ${CONDA_ARGS} -n python2 python-graphviz && \
	docker-clean

##########################################
# Support Tensorflow and Keras
##########################################
USER root
LABEL "comment"="Support Tensorflow and Keras" "issue"="SD2E/jupyteruser-sd2e/issues/13"
RUN conda install ${CONDA_ARGS} 'tensorflow=1.6*' keras theano && \
	conda install ${CONDA_ARGS} -n python2 'tensorflow=1.6*' keras theano && \
	docker-clean
RUN cd examples && \
	git clone https://github.com/leriomaggio/deep-learning-keras-tensorflow.git && \
	cd deep-learning-keras-tensorflow && rm -rf .git
# Necessary for theano
ENV MKL_THREADING_LAYER=GNU

###############################################
# Permissions
###############################################

# The notebook is run by the TACC userid, not jupyter,
# so permissions need to be open
RUN chown -R jupyter:${NB_GROUP} /home/jupyter && \
	chmod 777 /home/jupyter && \
	find /home/jupyter -type f -exec chmod 666 {} \; && \
	find /home/jupyter -type d -exec chmod 777 {} \;

USER jupyter
