FROM php:apache
RUN apt-get update -q
RUN apt-get install -y -q libpng-dev
RUN apt-get install -y -q libzip-dev
RUN apt-get install -y -q libxml2-dev
RUN apt-get install -y -q libonig-dev
RUN apt-get install -y -q libjpeg62-turbo-dev
RUN apt-get install -y -q libfreetype6-dev
RUN apt-get install -y -q libcurl4-openssl-dev
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install -j$(nproc) mysqli
RUN docker-php-ext-install -j$(nproc) mbstring
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) curl
RUN docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-install -j$(nproc) exif
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-enable mysqli gd mbstring xml curl zip exif
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf