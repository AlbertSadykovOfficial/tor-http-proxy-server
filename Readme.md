# HTTP Proxy server via TOR

## 1. Docker-образ:
[https://hub.docker.com/r/albertsadykovofficial/tor-proxy](https://hub.docker.com/r/albertsadykovofficial/tor-proxy)


## 2. Использование:
Из контейнера проброшен 9052 порт для HTTP-прокси,
чтобы получить доступ к сервису, следует его пробросить

Добавьте секцию ports:
```yaml
version: "3"
services:
  proxy:
    ...
    ports:
      - 10000:9052
    ...
```

### Запуск
Поднимаем прокси (это может занять некоторое время)
```bash
docker-compose up -d
```

### Проверка
ip-address - адрес, где запущен прокси

port - Порт, который проброшен наверх
```sh
curl -Lx http://<ip-address>:<port>  https://icanhazip.com
```

### Остановка
Остановка
```bash
docker-compose stop
```

### Примерное время работы:
Запрос из Севастополя в Москву через python-библиотеку requests

(10 запросов) На адрес https://www.reg.ru/asdasdasdas (0,1 Mb)
```
Без прокси: 0.411 сек === AVG(0.46, 0.36, 0.40, 0.35, 0.60, 0.49, 0.30, 0.29, 0.29, 0.57)
С прокси расположенном в Москве: 0.431 сек === AVG(0.40, 0.59, 0.39, 0.37, 0.36, 0.44, 0.38, 0.61, 0.37, 0.40)
Через ТОР с выходной точкой в Украине (Киев): 2.720 сек === AVG(2.63, 2.67, 2.78, 2.64, 2.88, 2.55, 3.02, 2.41, 2.94, 2.68)
```

## 3. Параметры Тор:
Чтобы скофигурировать тор по-своему, нужно создать файл-конфигурации и
пробросить его через volumes в контейнер на место расположения файла 
кофигурации тор:

Добавьте секцию volumes:
```yaml
version: "3"
services:
  proxy:
    ...
    volumes:
      - "./torrc:/etc/tor/torrc"
    ...
```

Значения по-умолчанию (добавьте их в свой файл конфигураций, если пробрасываете файл):
```
SocksPort 0.0.0.0:9050 IsolateDestAddr
ControlPort 0.0.0.0:9051
TransPort 0.0.0.0:9040
HTTPTunnelPort 0.0.0.0:9052
DataDirectory /var/lib/tor
```

Установим обновление ip адреса - каждые 60 секунд с проверкой обновления каждые 15 секунд:
```
MaxCircuitDirtiness 60
NewCircuitPeriod 15
```

ExitNodes - Желательные выходные узлы (Россия, Украина, Беларусь)

ExcludeNodes - Не включать следующие страны в путь (США, Великобритания)

(Если ваш мост будет в стране в ExcludeNodes, то тор может не запуститься
см. гаву 4. Устранение неполадок, поэтому указываем параметр StrictNodes 0,
чтобы сеть в таком случае все равно строилась)
```
ExitNodes {ru},{ua},{by}
ExcludeNodes {us},{gb} StrictNodes 0
```

Все параметры Тор:

[https://2019.www.torproject.org/docs/tor-manual.html.en](https://2019.www.torproject.org/docs/tor-manual.html.en)


## 4. Устранение неполадок
Если будет bootstrapping error - это значит, тор не может найти мостовые узлы, для
устранения этой пролемы следует перейти на сайт тор и получить сокет-адреса мостов,
после чего внести их в конфигурационный файл (socket = ip:port):

Сайт тор:

[https://bridges.torproject.org/options/](https://bridges.torproject.org/options/)


Параметры кофигурации:
```
UseBridges 1
bridge 185.61.119.8:444
bridge 80.247.238.246:444
```

## 5. Кластер прокси-серверов (docker-swarm пример)
Можно поднять кластер прокси-серверов, чтобы иметь несколько разных ip
одновременно (каждый элемент кластера будет иметь свой ip-адрес).

(Запуск может занять некоторое время)

(Кластер запускался, если только указывались напрямую параметры мостов
(см. главы: 3. Параметры Тор и 4. Устранение неполадок))

Добавьте секцию deploy:
```yaml
version: "3"
services:
  proxy:
    ...
    deploy:
      mode: replicated
      replicas: 4
    ...
```

### Запуск

Инициализация Swarm-менеджера
```bash
docker swarm init
```

Создадим приложение (без переменных окружения)

(Будут созданы и запущены: сеть и сервисы)

(Это может занять некоторое время)
```bash
docker stack deploy --compose-file docker-compose.yaml <your-name>
```

Посмотреть контейнеры приложения:
```bash
docker stack services <your-name>
```

### Проверка
ip-address - адрес, где запущен прокси

port - Порт, который проброшен наверх
```sh
curl -Lx http://<ip-address>:<port>  https://icanhazip.com
```

### Остановка и Удаление
Удаление приложения
```bash
docker stack rm <your-name>
```

Отключение менеджера (управляющего роем) 
```bash
docker swarm leave --force
```