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
# -----------------------
# FROM php:8.2-apache as final

# # Install PHP extensions
# RUN docker-php-ext-install pdo pdo_mysql

# # Set PHP configuration
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# # Copy application code and vendor directory (installed via pipeline)
# COPY ./src /var/www/html
# COPY ./vendor /var/www/html/vendor  # Make sure you copy the 'vendor' from pipeline build

# # Use the Apache user to run the app
# USER www-data
# -----------

# Use PHP 8.2 with Apache
FROM php:8.2-apache as final

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Set PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Accept the 'vendor' artifact passed from pipeline
ARG VENDOR_ARTIFACT

# Copy application code and vendor directory from artifact
COPY ./src /var/www/html

# Ensure the correct location for the artifact directory
COPY /$(Build.ArtifactStagingDirectory)/$(VENDOR_ARTIFACT) /var/www/html/vendor

