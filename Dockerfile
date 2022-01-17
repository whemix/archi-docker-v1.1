FROM debian:stable-slim

ARG ARCHI_VER=4.9.2
ARG COARCHI_VER=0.8.1.202112061132

RUN apt update && \
    apt install -y wget unzip dbus xvfb libswt-gtk-4-java && \
    #wget -O "archi.tgz" --post-data="dl=Archi-Linux64-${ARCHI_VER}.tgz" "https://www.archimatetool.com/downloads/archi/" && \
    wget -O "archi.tgz" --post-data="dl=${ARCHI_VER}/Archi-Linux64-${ARCHI_VER}.tgz" "https://www.archimatetool.com/downloads/archi/" && \
    tar zxf "archi.tgz" -C /opt/ && \
    ##wget -O coarchi.zip "https://www.archimatetool.com/downloads/coarchi/org.archicontribs.modelrepository_${COARCHI_VER}.archiplugin" && \
    wget -O coarchi.zip "https://www.archimatetool.com/downloads/coarchi1/coArchi_${COARCHI_VER}.archiplugin" && \
    mkdir -p ~/.archi4/dropins && \
    unzip coarchi.zip -d ~/.archi4/dropins && \
    rm archi.tgz coarchi.zip && \
    apt remove -y wget unzip && \
    apt autoremove -y && apt clean

COPY build-report.sh /app/
WORKDIR /app
CMD /app/build-report.sh
