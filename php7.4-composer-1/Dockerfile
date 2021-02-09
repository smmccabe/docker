FROM php:7.4-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y gnupg libpng-dev libjpeg-dev libpq-dev default-mysql-client git libbz2-dev libonig-dev
RUN apt-get update && apt-get install -y libgmp-dev libxml2-dev acl unzip bc bzip2 wget libzip-dev libxslt-dev libmagickwand-dev
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd
RUN docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip bcmath bz2 gmp soap xsl intl calendar 
RUN pecl install imagick && docker-php-ext-enable imagick
RUN pecl install pcov && docker-php-ext-enable pcov

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

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && php /tmp/composer-setup.php --version=1.10.17 --no-ansi --install-dir=/usr/local/bin --filename=composer && rm -rf /tmp/composer-setup.php

RUN wget -c https://phpmd.org/static/latest/phpmd.phar \
  && chmod +x phpmd.phar \
  && mv phpmd.phar /usr/local/bin/phpmd

RUN wget https://github.com/smmccabe/phpdebt/releases/download/1.0.2/phpdebt.phar \
  && chmod +x phpdebt.phar \
  && mv phpdebt.phar /usr/local/bin/phpdebt

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

# Install security advisories checker
RUN curl -sL https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64 -o security-checker \
    && chmod +x security-checker \
    && mv security-checker /usr/local/bin/security-checker

RUN curl -sS https://platform.sh/cli/installer | php

# Install shellcheck utility.
RUN SCVERSION="stable" \
  && apt-get install xz-utils \
  && curl -sLO https://github.com/koalaman/shellcheck/releases/download/${SCVERSION?}/shellcheck-${SCVERSION?}.linux.x86_64.tar.xz \
  && tar -xJvf shellcheck-${SCVERSION}.linux.x86_64.tar.xz \
  && mv "shellcheck-${SCVERSION}/shellcheck" /usr/local/bin/ \
  && rm -rf "shellcheck-${SCVERSION}"

RUN npm -g install smmccabe/commercebot
  
RUN apt-get update && apt-get install -y rsync  
