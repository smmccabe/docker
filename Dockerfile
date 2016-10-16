FROM php:apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev mysql-client git \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip
  
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
  
#code standards
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
 && chmod +x phpcs.phar \
 && mv phpcs.phar /usr/local/bin/phpcs
