FROM alpine:edge

ENV JMETER_VERSION "5.4.3"
ENV JMETER_HOME /tmp/apache-jmeter-${JMETER_VERSION}
ENV PATH ${JMETER_HOME}/bin:$PATH
ENV DISPLAY ":99"
ENV RESOLUTION "1366x768x24"
ENV VNC_PASS "password"

RUN  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache curl xfce4-terminal xvfb x11vnc xfce4 openjdk8-jre bash \
    && wget -qO- -O /tmp/jmeter.tgz https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    && tar -xvf /tmp/jmeter.tgz -C /tmp \
    && rm /tmp/jmeter.tgz \
    && wget -qO- -O /tmp/jpgc-json.zip http://jmeter-plugins.org/files/packages/jpgc-json-2.7.zip \
    && unzip -n /tmp/jpgc-json.zip -d /tmp/apache-jmeter-${JMETER_VERSION} \
    && rm /tmp/jpgc-json.zip

RUN x11vnc -storepasswd ${VNC_PASS} /etc/x11vnc.pass

EXPOSE 5900

WORKDIR /root

CMD ["bash", "-c", "nohup bash -c \"/usr/bin/Xvfb :99 -screen 0 1366x768x24 -ac +extension GLX +render -noreset && export DISPLAY=99 > /dev/null 2>&1 &\"\
    && nohup bash -c \"x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :99 -forever -bg -nopw -rfbport 5900 -rfbauth /etc/x11vnc.pass > /dev/null 2>&1\"\
    && nohup bash -c \"jmeter -Jjmeter.laf=CrossPlatform > /dev/null 2>&1 &\"\
    && tail -f /dev/null"]