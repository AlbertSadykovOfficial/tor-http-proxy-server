# TOR Proxy Server (Dockerfile)

## Docker-образ доступен через Docker Hub:
https://hub.docker.com/r/albertsadykovofficial/tor-proxy

## Конфигурация
### Конфигурация тор по-умолчанию:
9052 - Порт HTTP прокси-сервера
```
	SocksPort 0.0.0.0:9050 IsolateDestAddr
	ControlPort 0.0.0.0:9051
	TransPort 0.0.0.0:9040
	HTTPTunnelPort 0.0.0.0:9052
	DataDirectory /var/lib/tor
```

### Кастомная конфигурация
Чтобы изменить значения по-умолчанию, следует создать свой
кофигурационный тор-файл и пробросить его на место существующего
файла конфигураций:
```
	<file-path>:/etc/tor/torcc
```