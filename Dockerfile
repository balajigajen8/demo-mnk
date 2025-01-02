# Use the official PHP image with FPM
FROM php:8.0-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev libjpeg-dev libfreetype6-dev zip git unzip curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www

# Copy application files to the container
COPY . .

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Ensure Composer dependencies are installed correctly
RUN composer install --no-dev --optimize-autoloader --verbose || { \
    echo "Composer install failed"; \
    cat /var/www/composer.log; \
    exit 1; \
}

# Copy custom Nginx configuration
COPY nginx/default.conf /etc/nginx/sites-available/default

# Ensure proper permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage /var/www/bootstrap/cache

# Expose the port for Nginx
EXPOSE 80

# Start Nginx and PHP-FPM services
CMD ["sh", "-c", "service nginx start && php-fpm"]
