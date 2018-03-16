
FROM node:6-wheezy

#####################################
# Git:
#####################################
ARG INSTALL_GIT=true
ENV INSTALL_GIT ${INSTALL_GIT}
RUN if [ ${INSTALL_GIT} = true ]; then \
    apt-get update && \
    apt-get install -y git && \
    rm -r /var/lib/apt/lists/* \
;fi

#####################################
# Parsoid:
#####################################
RUN \
  git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid --depth 1 && \
  cd parsoid && \
  npm install

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

ADD ./config.yaml /parsoid/

#RUN rm -r /var/lib/apt/lists/*

WORKDIR /parsoid

CMD npm start
