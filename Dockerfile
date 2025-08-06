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

# Copy application code
COPY . .

# Set correct permissions
RUN chmod -R 775 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev \
    --ignore-platform-req=ext-calendar \
    --ignore-platform-req=ext-intl

# Generate Laravel app key
RUN php artisan key:generate || true

# Run migrations (ignore errors if already migrated)
RUN php artisan migrate --force || true

# ✅ Clear Laravel caches to avoid config/view issues
RUN php artisan config:clear \
 && php artisan cache:clear \
 && php artisan view:clear \
 && php artisan route:clear

# Build frontend assets (ignore error if build script missing)
RUN npm install && npm run build || true

# Expose app port
EXPOSE 8080

# Start Laravel server
CMD php artisan config:cache \
 && php artisan migrate --force || true \
 && php artisan serve --host=0.0.0.0 --port=8080
