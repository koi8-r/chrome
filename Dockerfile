# FROM debian:buster-slim
FROM debian:buster
MAINTAINER Burchenya Valentin <vp.burchenya@oz.net.ru>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install --no-install-recommends -qy \
    apt-utils \
    xvfb \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    x11-apps \
    x11vnc

RUN wget -q https://dl.google.com/linux/linux_signing_key.pub -O - | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list
RUN apt-get update -qq && apt-get install -qqy google-chrome-unstable
# google-chrome-stable
# google-chrome-beta
# google-chrome-unstable

# TODO:
#   - unix passwd vnc auth
#   - vnc ssl
#   - start vnc from regular user

ENV DISPLAY :99
RUN x11vnc -storepasswd '123qwe!@#' "/root/.vncpasswd"
RUN start-stop-daemon --start --quiet --pidfile /tmp/X.pid   --make-pidfile --background --exec /usr/bin/Xvfb -- \
    "${DISPLAY}" \
    -screen 0 1024x768x24 \
    -ac +extension GLX +render \
    -noreset
RUN start-stop-daemon --start --quiet --pidfile /tmp/vnc.pid --make-pidfile --background --exec /usr/bin/x11vnc -- \
    -display "${DISPLAY}" \
    -wait 10 \
    -forever \
    -rfbauth "/root/.vncpasswd" \
    -listen 0.0.0.0 \
    -geometry 1024x768
# RUN sleep 10 && xclock

ENTRYPOINT bash

