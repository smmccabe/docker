FROM php:apache

RUN a2enmod rewrite

# install the PHP extensions we need

RUN apt-get update && apt-get install -y gnupg libpng-dev libjpeg-dev libpq-dev mysql-client git libbz2-dev
RUN apt-get update && apt-get install -y libgmp-dev libxml2-dev acl unzip gnupg bc bzip2 wget libzip-dev
RUN pecl install xdebug-2.7.0beta1 && docker-php-ext-enable xdebug
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip bcmath bz2 gmp soap xls

RUN echo 'sendmail_path=/bin/true' > /usr/local/etc/php/conf.d/sendmail.ini

#install phantomjs
RUN apt-get update && apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 \
  && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
  && tar jxf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
  && mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs \
  && chmod +x /usr/local/bin/phantomjs

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

#install phan dependencies
RUN git clone https://github.com/nikic/php-ast.git \
  && cd php-ast \
  && phpize \
  && ./configure \
  && make install \
  && echo 'extension=ast.so' > /usr/local/etc/php/conf.d/ast.ini \
  && cd .. \
  && rm php-ast -rf

#install drush, to use for site and module installs
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
  && chmod +x drush.phar \
  && mv drush.phar /usr/local/bin/drush

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
RUN curl https://drupalconsole.com/installer -L -o drupal.phar \
  && chmod +x drupal.phar \
  && mv drupal.phar /usr/local/bin/drupal

#code standards
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
  && chmod +x phpcs.phar \
  && mv phpcs.phar /usr/local/bin/phpcs

RUN composer global require drupal/coder \
  && phpcs --config-set installed_paths /composer/vendor/drupal/coder/coder_sniffer

RUN wget https://github.com/smmccabe/phpmd/releases/download/2.7.0/phpmd.phar \
  && chmod +x phpmd.phar \
  && mv phpmd.phar /usr/local/bin/phpmd

RUN wget https://github.com/smmccabe/phpdebt/releases/download/0.4.0/phpdebt \
  && chmod +x phpdebt \ 
  && mv phpdebt /usr/local/bin/phpdebt

RUN wget https://phar.phpunit.de/phploc.phar \
  && chmod +x phploc.phar \
  && mv phploc.phar /usr/local/bin/phploc

RUN composer global require sebastian/phpcpd

# Readme check
RUN wget https://raw.githubusercontent.com/smmccabe/readmecheck/master/readmecheck \
  && chmod +x readmecheck \
  && mv readmecheck /usr/local/bin/readmecheck

# Node
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y nodejs

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install yarn

# Install SensioLabs' security advisories checker
RUN curl -sL http://get.sensiolabs.org/security-checker.phar -o security-checker.phar \
  && chmod +x security-checker.phar \
  && mv security-checker.phar /usr/local/bin/security-checker

RUN curl -sS https://platform.sh/cli/installer | php

RUN apt-get install shellcheck

RUN wget https://github.com/smmccabe/commercebot/releases/download/0.0.3/commercebot-linux \ 
  && chmod +x commercebot-linux \ 
  && mv commercebot-linux /usr/local/bin/commercebot
