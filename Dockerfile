FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NZBHYDRA2_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nemchik"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	curl \
	jq \
	unzip && \
 apt-get install --no-install-recommends -y \
	openjdk-11-jre-headless \
	python3 && \
 echo "**** install nzbhydra2 ****" && \
 if [ -z ${NZBHYDRA2_RELEASE+x} ]; then \
	NZBHYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 NZBHYDRA2_VER=${NZBHYDRA2_RELEASE#v} && \
 curl -o \
 /tmp/nzbhydra2.zip -L \
	"https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VER}/nzbhydra2-${NZBHYDRA2_VER}-linux.zip" && \
 mkdir -p /app/nzbhydra2 && \
 unzip /tmp/nzbhydra2.zip -d /app/nzbhydra2 && \
 curl -o \
 /app/nzbhydra2/nzbhydra2wrapperPy3.py -L \
	"https://raw.githubusercontent.com/theotherp/nzbhydra2/master/other/wrapper/nzbhydra2wrapperPy3.py" && \
 chmod +x /app/nzbhydra2/nzbhydra2wrapperPy3.py && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 5076
VOLUME /config
