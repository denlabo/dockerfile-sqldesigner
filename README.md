# dockerfile-sqldesigner

Dockerfile for sqldesigner.

The [sqldesigner](https://github.com/Lt-Mayonesa/sqldesigner) is a forked version by Lt-Mayonesa of [WWW SQL Designer](https://github.com/ondras/wwwsqldesigner), which also Material Design applied and so cool.


----


## Quick Start

```
$ docker run -it --rm -p 8080:80 -v sqldesigner-file-data:/backend-data/php-file/ -v sqldesigner-sqlite-data:/backend-data/php-sqlite/ denlabo/sqldesigner
```

Then, access to http://localhost:8080/ on your web browser.


----


## Get Started

If you want to customize something, let start with following commands.
Otherwise, try to just Quick Start.

```
$ git clone https://github.com/denlabo/dockerfile-sqldesigner.git
$ cd dockerfile-sqldesigner/

$ docker build -t sqldesigner .
$ docker run -it --rm -p 8080:80 -v php-file-data:/backend-data/php-file/ -v php-sqlite-data:/backend-data/php-sqlite/ sqldesigner
```


----


## About Saving Your Designed Schemes

You can save and load your designed schemes to **php-file** backend or **php-sqlite** backend, in default.

Also you don't worry anything :)
The saved file of those backends can be kept with using Named Volume of [Docker Data Volume](https://docs.docker.com/engine/tutorials/dockervolumes/#data-volumes) , even if docker container is rebuilt.

This dockerfile supports the following backends of the sqldesigner.

* php-file
	* It saves schemes designed by you to a XML file.
* php-sqlite
	* It saves schemes designed by you to a SQLite database (a single binary file).
* php-mysql &nbsp;&nbsp;(If MySQL server is available.)
	* It saves schemes designed by you to a specified MySQL server.
	* You can also launching MySQL server using the [**mysql** image](https://hub.docker.com/_/mysql/) and docker-compose. [See details](#using-with-docker-compose).


----





## Tips

### Basic Authentication

You can enable the Basic Authentication with append ``BASIC_AUTH_HTPASSWD`` parameter
 as the Build Argument of ``docker build`` command, as follows.

	$ docker build -t sqldesigner --build-arg BASIC_AUTH_HTPASSWD="foo:TYp0bgwle9J.w\nfizz:f5qp7mnMb5Yfs" .

A value of BASIC_AUTH_HTPASSWD parameter can be generated with ``htpasswd`` command.

### Change the Default Backend

In the initial state, **php-file** is selected as the default backend.
You can also choose the backend from other enabled backends, on the web interface.

However, you can change the default backend with append ``SQLDESIGNER_DEFAULT_BACKEND`` parameter
 as the Build Argument of ``docker build`` command, as follows.

	$ docker build -t sqldesigner --build-arg SQLDESIGNER_DEFAULT_BACKEND="php-sqlite" .


----


## Additional Tips for Saving Your Designed Schemes

If you needed, you can also store a backend's saved data to the specified directory on the host, or store to specified MySQL server.

### php-file backend - Store to the Specified Directory on the Host

You can store an XML file (designed schemes) of **php-file** backend to the specified directory on the host, with using ``-v`` option of ``docker run`` command.

Example for store to MySchemes directory on your home directory:
```
$ docker run -it --rm -p 8080:80 -v ~/MySchemes:/var/www/html/backend/php-file/data/ sqldesigner
```

Also refer to Docker documentation: [Mount a host directory as a data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume).

### php-sqlite backend - Store to the Specified Directory on the Host

You can store a database file (includes designed schemes) of **php-sqlite** backend to the specified directory on the host, with using ``-v`` option of ``docker run`` command.

Example for store to MySchemeDB directory on your home directory:
```
$ mkdir -p ~/MySchemeDB
$ wget -O ~/MySchemeDB/wwwsqldesigner.sqlite https://github.com/Lt-Mayonesa/sqldesigner/blob/1fbeedecab201c5194c0c31cd18d9d476e43baab/backend/php-sqlite/wwwsqldesigner.sqlite?raw=true

$ docker run -it --rm -p 8080:80 -v ~/MySchemeDB:/var/www/html/backend/php-sqlite/data/ sqldesigner
```

Also refer to Docker documentation: [Mount a host directory as a data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume).

### php-mysql backend - Store to MySQL server built on Docker-Compose<a name="using-with-docker-compose"></a>

You can store your designed schemes to the MySQL server that built by [**mysql** image](https://hub.docker.com/_/mysql/) and Docker-Compose, via **php-mysql** backend.

An example of docker-compose.yml is [here](https://github.com/denlabo/dockerfile-sqldesigner/blob/master/docker-compose.yml).

```
$ docker-compose build
$ docker-compose up -d
```

### php-mysql backend - Store to External MySQL server

You can store your designed schemes to the specified MySQL server via **php-mysql** backend.


Firstly, You need initialize the database with [here](https://github.com/denlabo/dockerfile-sqldesigner/blob/master/database/php-mysql-schema.sql).

Then, run ``docker run`` command as follows.
In this time, you need to set the following parameters:

* MYSQL_SERVER
	* A host name of your MySQL server.
* MYSQL_USER
	* An user name of your MySQL server.
* MYSQL_PASSWORD
	* A password of your MySQL server.
* MYSQL_DATABASE
	* A database name on your MySQL server.

```
$ docker run -it --rm -p 8080:80 -e MYSQL_SERVER=mysql.example.com MYSQL_USER=user MYSQL_PASSWORD=password MYSQL_DATABASE=database sqldesigner
```


----


## Maintainer of Dockerfile

[denLabo LLC](http://github.com/denlabo).
-- We make this dockerfile with appreciate for the sqldesigner. Thanks!


----


## About License

The [sqldesigner that forked by Lt-Mayonesa](https://github.com/Lt-Mayonesa/sqldesigner) is being distributed under the BSD 3-clause "New" or "Revised" License:
https://github.com/Lt-Mayonesa/sqldesigner/blob/master/license.txt
