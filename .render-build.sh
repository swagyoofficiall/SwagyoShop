#!/bin/bash
sudo apt-get update
sudo apt-get install -y php8.2 php8.2-cli php8.2-mbstring php8.2-xml php8.2-zip php8.2-pgsql
composer install --no-dev
php artisan key:generate
