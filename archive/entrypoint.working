#!/bin/bash
[[ -e /var/run/dbus.pid ]] && gosu root rm -f /var/run/dbus.pid
[[ -e /var/run/avahi-daemon/pid ]] && gosu root rm -f /var/run/avahi-daemon/pid
[[ -e /var/run/dbus/system_bus_socket ]] && gosu root rm -f /var/run/dbus/system_bus_socket
gosu root service dbus restart
gosu root service avahi-daemon restart
npm start -- --userDir /data
