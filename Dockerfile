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


# Step 1: Use the PHP 8.2 base image with Apache
FROM php:8.2-apache AS base

# Step 2: Install necessary PHP extensions (pdo, pdo_mysql)
RUN docker-php-ext-install pdo pdo_mysql

# Step 3: Set PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Step 4: Accept the 'vendor' artifact passed from pipeline
# ARG VENDOR_ARTIFACT is passed from the pipeline
ARG VENDOR_ARTIFACT

# Step 5: Copy application code from the build context (source code in the `src` folder)
COPY ./src /var/www/html

# Step 6: Copy the vendor directory from the artifact
# Assuming the artifact is named 'vendor-artifact' and it's available from the pipeline
COPY $(Build.ArtifactStagingDirectory)/$(VENDOR_ARTIFACT) /var/www/html/vendor

# Step 7: Set Apache user to run the app (for security and permissions)
USER www-data

# Step 8: Expose the port Apache runs on (optional for local testing)
EXPOSE 80

# Step 9: Set the working directory (optional but can be useful)
WORKDIR /var/www/html

