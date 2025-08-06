# Use official PHP image with required extensions
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    npm \
    libzip-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libmcrypt-dev \
    libreadline-dev \
    libicu-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring zip exif pcntl bcmath gd intl calendar

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev --ignore-platform-req=ext-calendar --ignore-platform-req=ext-intl

# Install Node modules and build frontend assets
RUN npm install && npm run build || true

# Laravel specific
RUN php artisan key:generate || true
RUN php artisan migrate --force || true

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]

