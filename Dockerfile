FROM php:8.2-apache
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies and clear cache in a single layer
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions in a single layer
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install application dependencies
RUN composer update
RUN composer install
RUN npm install
RUN npm run build

# Set permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/storage

# Apache configuration
RUN a2enmod rewrite

# Expose port 80
EXPOSE 80

# Start Apache service
CMD ["apache2-foreground"]
