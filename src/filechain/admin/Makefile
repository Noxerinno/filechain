all : clean
	# docker-compose up -d 
	# python3 init.py
	chmod u+x ./init.sh
	./init.sh

restart :
	docker-compose stop
	docker-compose start

clean :
	docker-compose down
	# docker volume rm admin_ipfs_data
	# docker volume rm admin_ipfs-cluster_data
	sudo rm -rf ./compose/data/
	docker system prune