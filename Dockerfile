FROM alpine:latest

MAINTAINER Albert Sadykov <albertsadykov@ro.ru>

RUN apk upgrade --no-cache --no-progress
RUN apk add --no-cache --no-progress tor

RUN echo "SocksPort 0.0.0.0:9050 IsolateDestAddr" > /etc/tor/torrc && \
	echo "ControlPort 0.0.0.0:9051" >> /etc/tor/torrc && \
	echo "TransPort 0.0.0.0:9040" >> /etc/tor/torrc && \
	echo "HTTPTunnelPort 0.0.0.0:9052" >> /etc/tor/torrc && \
	echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc

EXPOSE 9052

USER tor

CMD tor -f /etc/tor/torrc