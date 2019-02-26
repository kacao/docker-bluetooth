#STEP 1 of multistage build ---Compile Bluetooth stack-----

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
#environment variables

#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:stretch

ENV BLUEZ_VERSION 5.50 

#dynamic build arguments coming from the /hooks/build file

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#install prerequisites
RUN apt-get update  \
    && apt-get install -y apt-utils dbus git curl build-essential libglib2.0-dev \
    bluez bluez-tools pulseaudio-module-bluetooth \
    bluez-obexd default-dbus-session-bus alsa-utils pavucontrol paman paprefs pavumeter \
    libical-dev libdbus-1-dev libreadline-dev libudev-dev systemd \
    python3-dev python3-wheel python3-pip python3-setuptools \
    libglib2.0-dev libffi-dev libbluetooth-dev \
    libssl-dev libxml2-dev libxslt1-dev zlib1g-dev
#RUN cd /tmp \ 
#    &&  apt-get -d -o dir::cache=`pwd` -o Debug::NoLocking=1 install libboost-python-dev \
#    && dpkg --ignore-depends=python2.7 --install /tmp/libboost-python-dev.deb \
#    && cd -
#get BCM chip firmware
RUN mkdir /etc/firmware \
    && curl -o /etc/firmware/BCM43430A1.hcd -L https://github.com/OpenELEC/misc-firmware/raw/master/firmware/brcm/BCM43430A1.hcd \
#create folders for bluetooth tools
    && mkdir -p '/usr/bin' '/usr/libexec/bluetooth' '/usr/lib/cups/backend' '/etc/dbus-1/system.d' \
       '/usr/share/dbus-1/services' '/usr/share/dbus-1/system-services' '/usr/include/bluetooth' \
       '/usr/share/man/man1' '/usr/share/man/man8' '/usr/lib/pkgconfig' '/usr/lib/bluetooth/plugins' \
       '/lib/udev/rules.d' '/lib/systemd/system' '/usr/lib/systemd/user' '/lib/udev' \
#install userland raspberry tools
    && git clone --depth 1 https://github.com/raspberrypi/firmware /tmp/firmware \
    && mv /tmp/firmware/hardfp/opt/vc /opt \
    && echo "/opt/vc/lib" >/etc/ld.so.conf.d/00-vmcs.conf \
    && /sbin/ldconfig
RUN apt-get install vlc-nox
RUN pip3 install --upgrade pip wheel setuptools
RUN pip3 install pybluez
RUN pip3 install homeassistant
#clean up
RUN rm -rf /tmp/* \
    && apt-get remove git curl \
    && apt-get -yqq autoremove \
    && apt-get -y clean
#    && rm -rf /var/lib/apt/lists/*

#copy files
COPY "./init.d/*" /etc/init.d/
#do startscript
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
