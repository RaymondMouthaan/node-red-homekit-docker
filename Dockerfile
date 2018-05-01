FROM nodered/node-red-docker:slim-v8
USER root
ENV HOST_NAME mydiskstation

# Install required packages
RUN apk add --no-cache git python make g++ avahi-compat-libdns_sd avahi-dev dbus su-exec

# Insert HOST_NAME into avahi-daemon.conf
RUN sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf && sed -i "s/.*host-name.*/host-name='$HOST_NAME'/" /etc/avahi/avahi-daemon.conf
RUN mkdir -p /var/run/dbus && mkdir -p /var/run/avahi-daemon
RUN chown messagebus:messagebus /var/run/dbus && chown avahi:avahi /var/run/avahi-daemon && dbus-uuidgen --ensure

RUN chown root:node-red /sbin/su-exec && chmod +s /sbin/su-exec

USER node-red
#RUN npm install node-red-contrib-homekit
RUN npm install @boneskull/node-red-contrib-homekit

# Clean up
RUN su-exec apt del git python make g++ && \
    su-exec rm -rf /var/cache/apk/*
    
COPY entrypoint.sh /usr/src/node-red
RUN su-exec root chmod 755 /usr/src/node-red/entrypoint.sh

ENTRYPOINT /usr/src/node-red/entrypoint.sh
