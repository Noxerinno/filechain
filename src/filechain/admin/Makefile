all :
	docker-compose up -d 
	python3 init.py

restart :
	docker-compose stop
	docker-compose start

clean :
	docker-compose down
	docker system prune