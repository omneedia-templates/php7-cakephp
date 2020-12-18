FROM ubuntu:18.04

ENV PATH $PATH:/root/.composer/vendor/bin
ENV DOCUMENT_ROOT /var/www/html
ENV PORT 80
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y software-properties-common software-properties-common && \
    add-apt-repository ppa:ubuntugis/ppa && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
    gdal-bin \
    apache2 \
    mcrypt \
    php7.2 \
    php7.2-cli \
    libapache2-mod-php7.2 \
    php7.2-gd \
    php7.2-json \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-pgsql \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-xsl \
    php7.2-zip \
    php7.2-curl \
    php7.2-intl \
    curl \
    zip \
    unzip \
    git \
    cron \
    php-dev \
    libmcrypt-dev \
    php-pear

RUN pecl channel-update pecl.php.net
RUN pecl install mcrypt-1.0.1

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer.phar

COPY config/apache2.conf /etc/apache2/apache2.conf
COPY config/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

WORKDIR /var/www

COPY config/run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
COPY config/php.ini /etc/php/7.2/apache2/php.ini
RUN a2enmod rewrite

COPY app/ /var/www/
RUN chmod 777 -Rf /var/www

RUN composer install --no-scripts

COPY config/cron /etc/cron.d/rex
RUN chmod 0644 /etc/cron.d/rex
RUN crontab /etc/cron.d/rex
RUN touch /var/log/cron.log

CMD cron && "/usr/local/bin/run"
