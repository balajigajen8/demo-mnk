# Use the official PHP image with Nginx
FROM php:8.0-fpm

# Install dependencies and Nginx
RUN apt-get update && apt-get install -y \
    nginx \
    libpng-dev libjpeg-dev libfreetype6-dev zip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql \
    && apt-get clean

# Set the working directory
WORKDIR /var/www

# Copy Laravel app into the container
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy Nginx configuration
COPY nginx/default.conf /etc/nginx/sites-available/default

# Set the correct permissions
RUN chown -R www-data:www-data /var/www

# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm
