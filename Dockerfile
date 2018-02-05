FROM php:apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev mysql-client git libbz2-dev libgmp-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip bcmath bz2 gmp soap

RUN echo 'sendmail_path=/bin/true' > /usr/local/etc/php/conf.d/sendmail.ini

#install phan dependencies
RUN git clone https://github.com/nikic/php-ast.git \
  && cd php-ast \
  && phpize \
  && ./configure \
  && make install \
  && echo 'extension=ast.so' > /usr/local/etc/php/conf.d/ast.ini \
  && cd .. \
  && rm php-ast -rf

#install phan
RUN curl -L https://github.com/etsy/phan/releases/download/0.6/phan.phar -o phan.phar \
  && chmod +x phan.phar \
  && mv phan.phar /usr/local/bin/phan

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

RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && rm nodesource_setup.sh \
  && apt-get install -y nodejs

RUN curl -o- -L https://yarnpkg.com/install.sh | bash

RUN yarn install -g gulp-cli \
  && yarn install -g gulp-sass

RUN curl -sS https://platform.sh/cli/installer | php

RUN pecl install xdebug \
    && echo "zend_extension=$(find / -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini

# Install SensioLabs' security advisories checker
RUN curl -sL http://get.sensiolabs.org/security-checker.phar -o security-checker.phar \
  && chmod +x security-checker.phar \
  && mv security-checker.phar /usr/local/bin/security-checker
