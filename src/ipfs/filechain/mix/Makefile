all :
	# docker-compose up -d 
	# python3 init.py
	chmod u+x ./new_script.sh
	./new_script.sh

restart :
	docker-compose stop
	docker-compose start

clean :
	docker-compose down
	docker volume rm admin_ipfs_data
	docker volume rm admin_ipfs-cluster_data 
	docker system prune
