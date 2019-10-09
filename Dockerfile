FROM php:7.1.4-apache
MAINTAINER denLabo LLC


# Install the packages
RUN apt-get update -q -y && apt-get install -y unzip wget mysql-client && \
	docker-php-ext-install pdo_mysql mysqli mbstring

# Define the Commit ID of sqldesigner
ARG SQLDESIGNER_COMMIT="1fbeedecab201c5194c0c31cd18d9d476e43baab"

# Install the sqldesigner
RUN wget "https://github.com/Lt-Mayonesa/sqldesigner/archive/${SQLDESIGNER_COMMIT}.zip" && \
	unzip -d /tmp "${SQLDESIGNER_COMMIT}.zip" && \
	mv "/tmp/sqldesigner-${SQLDESIGNER_COMMIT}/"* /var/www/html/

# Change an ID of the user and group to allow to write from apache to Docker Data Volume directory
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Enable storing of backend's save file with host via Docker Data Volume
RUN mkdir -p /backend-data/php-file/ && \
	mkdir -p /backend-data/php-sqlite/ && \
	touch /backend-data/php-file/.dummy && \
	touch /backend-data/php-sqlite/index.html && \
	cp --no-clobber /var/www/html/backend/php-file/data/default /backend-data/php-file/ && \
	cp --no-clobber /var/www/html/backend/php-sqlite/wwwsqldesigner.sqlite /backend-data/php-sqlite/ && \
	chown -R www-data:www-data /var/www/html/ && \
	chown -R www-data:www-data /backend-data/
VOLUME ["/backend-data/php-file/", "/backend-data/php-sqlite/"]

# Define the sqldesigner backend to be enable
ARG SQLDESIGNER_BACKENDS="php-mysql|php-sqlite|php-file"
ARG SQLDESIGNER_DEFAULT_BACKEND="php-file"

# Change the sqldesigner configration about the available backends
RUN	ls --directory /var/www/html/backend/* | grep --invert-match --extended-regexp "${SQLDESIGNER_BACKENDS}" | xargs rm --recursive --force && \
	CONFIG_LINE_AVAILABLE_BACKENDS="AVAILABLE_BACKENDS: [\"$(echo "${SQLDESIGNER_BACKENDS}" | sed --expression="s/|/\",\"/g")\"]," && \
	sed --in-place --expression="s/AVAILABLE_BACKENDS:.*/${CONFIG_LINE_AVAILABLE_BACKENDS}/" /var/www/html/js/config.js && \
	CONFIG_LINE_DEFAULT_BACKEND="DEFAULT_BACKEND: [\"${SQLDESIGNER_DEFAULT_BACKEND}\"]," && \
	sed --in-place --expression="s/DEFAULT_BACKEND:.*/${CONFIG_LINE_DEFAULT_BACKEND}/" /var/www/html/js/config.js && \
	cat /var/www/html/js/config.js

# Change a save path of php-file and php-sqlite backend so that the save file can be store on host
RUN STR_SAVE_DIR_PATH="\/backend-data\/php-file\/" && \
	sed --in-place --expression="s/\"data\//\"${STR_SAVE_DIR_PATH}/" /var/www/html/backend/php-file/index.php && \
	LINE_SQLITE_PATH="define(\"FILE\", \"\/backend-data\/php-sqlite\/wwwsqldesigner.sqlite\");" && \
	sed --in-place --expression="s/define(\s*\"FILE\"\s*,\s*\"wwwsqldesigner.sqlite\"\s*);/${LINE_SQLITE_PATH}/" /var/www/html/backend/php-sqlite/index.php

# Change a MySQL database configuration of php-mysql backend so that to support to the environment variables
ENV MYSQL_SERVER="" MYSQL_USER="" MYSQL_PASSWORD="" MYSQL_DATABASE=""
RUN sed --in-place -E "s/(define\(\"SERVER\",)\"localhost\"(\);)/\1 \$_ENV['MYSQL_SERVER'] \2/g" /var/www/html/backend/php-mysql/index.php && \
	sed --in-place -E "s/(define\(\"USER\",)\"\"(\);)/\1 \$_ENV['MYSQL_USER'] \2/g" /var/www/html/backend/php-mysql/index.php && \
	sed --in-place -E "s/(define\(\"PASSWORD\",)\"\"(\);)/\1 \$_ENV['MYSQL_PASSWORD'] \2/g" /var/www/html/backend/php-mysql/index.php && \
	sed --in-place -E "s/(define\(\"DB\",)\"home\"(\);)/\1 \$_ENV['MYSQL_DATABASE'] \2/g" /var/www/html/backend/php-mysql/index.php

# Change the default value of the save keyword
ARG SQLDESIGNER_DEFAULT_SAVE_KEYWORD=""
RUN if [ -n "${SQLDESIGNER_DEFAULT_SAVE_KEYWORD}" ]; then \
		echo "<script> d.setOption('lastUsedName', '${SQLDESIGNER_DEFAULT_SAVE_KEYWORD}'); </script>" >> /var/www/html/index.html; \
		sed --in-place -E "s/this._name = \"\";/this._name = \"${SQLDESIGNER_DEFAULT_SAVE_KEYWORD}\";/g" /var/www/html/js/io.js;\
	fi

# Enable the Basic Authentication
ARG BASIC_AUTH_HTPASSWD=""
RUN if [ -n "${BASIC_AUTH_HTPASSWD}" ]; then \
		echo "AuthUserFile /var/www/html/.htpasswd\nAuthName sqldesigner\nAuthType Basic\nrequire valid-user" > /var/www/html/.htaccess; \
		echo "${BASIC_AUTH_HTPASSWD}" > /var/www/html/.htpasswd; \
	fi
