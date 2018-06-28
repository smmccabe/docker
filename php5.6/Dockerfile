FROM php:5.6-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev mysql-client git libbz2-dev libgmp-dev acl unzip gnupg bc
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-configure gmp
RUN docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip bcmath bz2 gmp

RUN echo 'sendmail_path=/bin/true' > /usr/local/etc/php/conf.d/sendmail.ini

#install latest chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y google-chrome-stable

#install chromedriver
RUN CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
  && wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ \
  && unzip ~/chromedriver_linux64.zip -d ~/ \
  && rm ~/chromedriver_linux64.zip \
  && mv -f ~/chromedriver /usr/local/bin/chromedriver \
  && chmod 0755 /usr/local/bin/chromedriver

#install drush, to use for site and module installs
RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush \
  && chmod +x drush \
  && mv drush /usr/local/bin

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

#allows for parallel composer downloads
RUN composer global require "hirak/prestissimo:^0.3"

#drupal console
RUN composer global require drupal/console:@stable

#code standards
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
 && chmod +x phpcs.phar \
 && mv phpcs.phar /usr/local/bin/phpcs

RUN composer global require drupal/coder \
  && phpcs --config-set installed_paths /composer/vendor/drupal/coder/coder_sniffer

RUN composer global require phpmd/phpmd

RUN composer global require sebastian/phpcpd

RUN composer global require smmccabe/phpdebt

RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && rm nodesource_setup.sh \
  && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install yarn

RUN curl -sS https://platform.sh/cli/installer | php
