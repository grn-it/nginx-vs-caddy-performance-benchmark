duration = 60

benchmark:
	printf "Nginx vs Caddy performance benchmark\r\n\r\n"
	printf "Nginx version: "; docker-compose exec nginx nginx -v | grep -oP '(?<=nginx/)[0-9.]+' | tr -d "\n\t\r"; printf "\r\n"
	printf "Caddy version: "; docker-compose exec caddy caddy version | grep -oP '(?<=v)[0-9.]+' | tr -d "\n\t\r"; printf "\r\n"
	printf "PHP version: "; docker-compose exec php_fpm php -v | grep -oP '(?<=PHP )[0-9.]+' | tr -d "\n\t\r"; printf "\r\n"
	printf "Symfony version: "; docker-compose exec symfony bin/console -V --no-ansi | grep -oP '(?<=Symfony )[0-9.]+' | tr -d "\n\t\r"; printf "\r\n\r\n"
	printf "Number of requests to static html-file\r\n";
	printf "Nginx: "
	docker-compose exec h2load h2load --duration=${duration} --h1 http://nginx/index.html | grep -oP '[0-9]+ (?=succeeded)' | tr -d "\n\t\r"; printf "per minute\r\n"
	printf "Caddy: "
	docker-compose exec h2load h2load --duration=${duration} --h1 http://caddy/index.html | grep -oP '[0-9]+ (?=succeeded)' | tr -d "\n\t\r"; printf "per minute\r\n"
	printf "\r\n"
	printf "Number of requests to PHP-FPM. Processed by Symfony controller\r\n";
	printf "Nginx: "
	docker-compose exec h2load h2load --duration=${duration} --h1 http://nginx | grep -oP '[0-9]+ (?=succeeded)' | tr -d "\n\t\r"; printf "per minute\r\n"
	printf "Caddy: "
	docker-compose exec h2load h2load --duration=${duration} --h1 http://caddy | grep -oP '[0-9]+ (?=succeeded)' | tr -d "\n\t\r"; printf "per minute\r\n"
