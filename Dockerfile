# FROM composer:lts as deps
# WORKDIR /app
# RUN --mount=type=bind,source=composer.json,target=composer.json \
#     --mount=type=bind,source=composer.lock,target=composer.lock \
#     --mount=type=cache,target=/tmp/cache \
#     composer install --no-dev --no-interaction

# FROM php:8.2-apache as final
# RUN docker-php-ext-install pdo pdo_mysql
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# COPY --from=deps app/vendor/ /var/www/html/vendor
# COPY ./src /var/www/html
# USER www-data
# Use PHP 8.2 with Apache

FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    sudo

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Install project dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Create test results directory with proper permissions
RUN mkdir -p /var/www/html/test-results \
    && chmod -R 777 /var/www/html/test-results

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
