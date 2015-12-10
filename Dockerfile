###############################################################################
# Data Science Toolbox for Data Science Specialization                        #
#                                                                             #
# Build a Docker image for the Data Science Specialization                    #
# Johns Hopkins University                                                    #
#                                                                             #
# Version 0.1, Copyright (C) 2015 Gregory D. Horne                            #
#                                 (horne at member dot fsf dot org)           #
#                                                                             #
# Licensed under the terms of the GNU General Public license (GPL) v2         #
###############################################################################


FROM ubuntu:latest

MAINTAINER "Gregory D. Horne" horne@member.fsf.org

ENV     ARCH amd64
ENV     R_VERSION 3.2.2
ENV     RSTUDIO_VERSION 0.99.489

ENV     DEBIAN_FRONTEND noninteractive

RUN		apt-get update


# Configure the regional language settings

ENV     LOCALE en_US.UTF-8

RUN		dpkg-reconfigure locales \
		&& locale-gen ${LOCALE} \
		&& /usr/sbin/update-locale LANG=${LOCALE}

# miscellaneous packages
#
RUN     apt-get install --yes --no-install-recommends \
        libssl-dev \
        libcurl4-gnutls-dev \
		curl \
        wget \
        ca-certificates

# Git command line client

RUN		apt-get install --yes git git-doc \
		&& git config --system push.default simple


# Statistical Computing Evironment and Programming Language

RUN     echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" \
        >> /etc/apt/sources.list \
        && apt-key adv --keyserver keyserver.ubuntu.com --recv-key 51716619E084DAB9 \
        && apt-get update \
        && apt-get install --yes --force-yes --no-install-recommends \
        r-base r-base-dev r-doc-info r-recommended \
        libxml2-dev \
        pandoc pandoc-citeproc \
        texlive texlive-xetex texlive-latex-extra \
		libmysqlclient-dev \
        && mkdir -p /etc/R/ \
        && echo "options(repos = list(CRAN = 'https://cran.rstudio.com/'), \
        download.file.method = 'libcurl')" \
        > /etc/R/Rprofile.site


# RStudio Server

RUN		apt-get install --yes psmisc libapparmor1 \
		&& wget -c -nv http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb \
		&& dpkg -i rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb \
		&& rm rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb

RUN		echo "r-libs-user=~/R/packages" >> /etc/rstudio/rsession.conf


# Create default user account 

ENV		DST_USER dst	
ENV		HOME /home/${DST_USER}

RUN		useradd --create-home --shell /bin/bash ${DST_USER} \
		&& echo "${DST_USER}:science" | chpasswd \
		&& mkdir ${HOME}/bin \
		&& mkdir ${HOME}/tmp


# Console/terminal managememnt, text editor and text editor plug-in manager

RUN		apt-get install --yes screen vim \
		&& echo "alias vi=vim" >> ${HOME}/.bashrc \
		&& curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
		&& mkdir ${HOME}/data

ADD		vimrc ${HOME}/.vimrc

RUN		chown -R ${DST_USER}:${DST_USER} ${HOME}

# WeTTY

RUN		apt-get install --yes nodejs-legacy npm \
		&& cd /tmp \
		&& git clone https://github.com/krishnasrinivas/wetty \
		&& cd wetty \
		&& npm install \
		&& mkdir /opt/wetty \
		&& cp app.js /opt/wetty/app.js \
		&& cp bin/wetty.js /opt/wetty/wetty.js \
		&& sed -i 's/\.\.\/app/\/opt\/wetty\/app\.js/' /opt/wetty/wetty.js \
		&& chmod +x /opt/wetty/wetty.js \
		&& cp -r node_modules /opt/wetty \
		&& cp -r public /opt/wetty \
		&& ln -s /opt/wetty/wetty.js /usr/local/bin/wetty.js \
		&& rm -r /tmp/wetty


# Supervisor deamon

RUN		apt-get install --yes supervisor

COPY	supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN		mkdir -p /var/log/supervisor \
		&& chgrp staff /var/log/supervisor \
		&& chmod g+w /var/log/supervisor \
		&& chgrp staff /etc/supervisor/conf.d/supervisord.conf


# Clean-up installation environment

RUN     apt-get clean && apt-get autoclean


VOLUME  ${HOME}
WORKDIR ${HOME}


# Make TCP/IP ports accessible outside the container.
#
# Port		Application
# 8000		WeTTY
# 8787		RStudio Server

EXPOSE	8000 8787


# Manages processes within the container

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

