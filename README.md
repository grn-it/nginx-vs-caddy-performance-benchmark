# Nginx vs Caddy Performance Benchmark

This benchmark shows the number of processed requests per minute for the Nginx and Caddy web servers.  
Both web servers are downloaded from official docker images with no additional configuration settings to increase performance.

Tests for Nginx and Caddy:
- Maximum number of downloaded [static html-file](https://github.com/grn-it/nginx-vs-caddy-performance-benchmark/blob/main/.docker/symfony/public/index.html) per minute
- Maximum number of requests per minute redirected to PHP-FPM and processed by the [Symfony controller](https://github.com/grn-it/nginx-vs-caddy-performance-benchmark/blob/main/.docker/symfony/src/Controller/DefaultController.php)

The stand has the following docker images:
- Nginx
- Caddy
- PHP-FPM
- Symfony
- h2load

Resource limits for containers:
- Nginx: 10% CPU, 1GB RAM
- Caddy: 10% CPU, 1GB RAM

Benchmark was done on a machine with configuration:
- CPU: i9-9900K
- RAM: 16 GB
- SSD: Samsung SSD 970 EVO Plus 500GB

## Install
```
git clone https://github.com/grn-it/nginx-vs-caddy-performance-benchmark
cd nginx-vs-caddy-performance-benchmark
docker-compose build
docker-compose up
```

## Run benchmark
```
make -s benchmark
```
## Results
```
Nginx version: 1.21.5
Caddy version: 2.4.6
PHP version: 8.1.1
Symfony version: 6.0.2

Number of requests to static html-file
Nginx: 27049 per minute
Caddy: 5790 per minute

Number of requests to PHP-FPM. Processed by Symfony controller
Nginx: 3957 per minute
Caddy: 3316 per minute
```
