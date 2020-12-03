all :
	# docker-compose up -d 
	# python3 init.py
	chmod u+x ./init.sh
	./init.sh

restart :
	docker-compose stop
	docker-compose start

clean :
	docker-compose down
	docker volume rm client_ipfs_data
	docker volume rm client_ipfs-cluster_data 
	docker system prune
