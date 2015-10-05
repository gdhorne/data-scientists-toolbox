# Build a Docker image for R/RStudio

FROM ubuntu:14.04

MAINTAINER "Gregory D. Horne" horne@member.fsf.org

ENV     ARCH amd64
ENV     R_VERSION 3.2.2
ENV     RSTUDIO_VERSION 0.99.484

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt-get update \
        && apt-get -y upgrade

RUN     sed -i 's/101/0/' /usr/sbin/policy-rc.d

ENV     LOCALE en_GB.UTF-8

RUN     apt-get install -y locales \
        && echo ${LOCALE} UTF-8 >> /etc/locale.gen \
        && locale-gen ${LOCALE} \
        && /usr/sbin/update-locale LANG=${LOCALE}

ENV     LC_ALL ${LOCALE}
ENV     LANG ${LOCALE}

ENV     USER dst
ENV     HOME /home/${USER}

RUN     useradd ${USER} \
        && mkdir -p ${HOME} \
        && chown ${USER}:${USER} ${HOME} \
        && addgroup ${USER} staff \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} \
        && chmod 0440 /etc/sudoers.d/${USER}

RUN     echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" \
        >> /etc/apt/sources.list \
       	&& apt-key adv --keyserver keys.gnupg.net --recv-key 51716619E084DAB9 \ 
	&& apt-get update \
        && apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
        r-doc-info \
        r-recommended \
        libcurl4-gnutls-dev \
        libxml2-dev

RUN	sudo apt-get install -y \
	pandoc \
	texlive \
	texlive-xetex \
	pandoc-citeproc \
	texlive-latex-extra

RUN     mkdir -p /etc/R/ \
        && echo "options(repos = list(CRAN = 'https://cran.rstudio.com/'), \
        download.file.method = 'libcurl')" \
        > /etc/R/Rprofile.site

RUN     apt-get install -y --no-install-recommends \
        curl \
        git \
        git-doc \
        libapparmor1 \
        libssl-dev \
        libedit2 \
        markdown \
        psmisc \
        supervisor \
        sudo

RUN	apt-get install screen

RUN     git config --system user.name ${USER} \
        && git config --system user.email ${USER}@localhost \
        && git config --system push.default simple \
        && echo "dst:science" | chpasswd

RUN     apt-get install -y --no-install-recommends \
        wget \
        ca-certificates

RUN     wget -c -nv http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb \
        && dpkg -i rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb \
        && rm rstudio-server-${RSTUDIO_VERSION}-${ARCH}.deb

RUN     echo "r-libs-user=~/R/packages" >> /etc/rstudio/rsession.conf

ENV     PATH `which rstudio-server`:${PATH}

RUN     apt-get clean

COPY    supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN     mkdir -p /var/log/supervisor \
        && chgrp staff /var/log/supervisor \
        && chmod g+w /var/log/supervisor \
        && chgrp staff /etc/supervisor/conf.d/supervisord.conf

VOLUME  ${HOME}

EXPOSE  80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
