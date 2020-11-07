# prepare environment
prepare:
	@sudo iptables -L DOCKER-USER | grep "ACCEPT     all" ext >/dev/null 2>&1 || sudo iptables -I DOCKER-USER -j ACCEPT
	@docker network inspect ext >/dev/null 2>&1 || docker network create --driver=bridge --subnet=172.16.255.0/24 ext

# build images
build:	prepare
	docker-compose build

# start scenario
start:	
	docker-compose up -d

# stop scenario
stop:
	docker-compose down

# consoles

client: 
	docker exec -it usecase_extclient_1 bash

proxy:
	docker exec -it usecase_proxy_1 bash

aqm:
	docker exec -it usecase_aqm_1 bash

acs:
	docker exec -it usecase_acs_1 bash

dns:
	docker exec -it usecase_dns_1 bash

abc:
	docker exec -it usecase_abc_1 bash

fog:
	docker exec -it usecase_fog_1 bash

ids:
	docker exec -it usecase_ids_1 bash

www:
	docker exec -it usecase_www_1 bash

fw:
	docker exec -it usecase_fw_1 bash

rt-simint:
	docker exec -it usecase_rt-simint_1 bash
