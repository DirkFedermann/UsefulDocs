# Install LAMP Dev Stack on WSL2 (Ubuntu 22.04)
WSL2 is the second version of WSL (Windows Subsystem for Linux) that is compared to WSL1 it actually uses the Linux Kernel inside a managed VM and has support for full system call compatibility.
Not something we explicitly need, but the increased performance is always nice.

So this tutorial will utilize WSL2 - which is also the default version when installing a Linux distribution with WSL and we will install Ubuntu.

If you want to dig deeper into the topic, I can highly recommend the official documentation of WSL from Microsoft: https://learn.microsoft.com/en-us/windows/wsl/


## Install WSL2 and latest Ubuntu
WSL is not enabled by default on all Windows versions and installations.
To enable it, we need to open up a Powershell with Administrative Rights.
For that we press the Windows-Key on the keyboard and type in Powershell, right click on the result and select Open as Administrator.
After that type in this line and press Enter:
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
It might take a while to activate it, but what you definitely have to do is restart Windows, so the changes are adopted.

After the restart, you can open up a simple command prompt or Powershell and type in:
```
wsl --install -d Ubuntu
```
This will install the latest version of Ubuntu (as of time of writing 22.04).
Depending on your internet connection it might take a while, after the download it automatically gets installed

Check if an Instance of WSL is running and in what version:
```
wsl -l -v
```
if it is using WSL1 use this command to change it:
```
wsl --set-version Ubuntu 2
```
WSL2 is vastly surpirior in the performance and feature-set compared to WSL1 - except if you use files across the OS.
For more information, check the Microsoft Site here: https://learn.microsoft.com/en-us/windows/wsl/compare-versions

## Initial Prep Work

Now that Ubuntu is installed and running, you will get prompted to input an username and password.
Use a password you can remember easily, you will enter it frequently using the terminal.

Not all the packages that are being installed during the initial install is up-to-date, so we need to first update and upgrade everything:
```
sudo apt update && sudo apt upgrade
```
Then install some other basic packages that will be used during this tutorial and are useful in general:
```
sudo apt install nano zip unzip curl net-tools 
```
It is useful to set the locale settings to what you are used to, for dates, numbers, currency, etc.
For me it is German. So I use this command to change the locale:
```
sudo locale-gen de_DE de_DE.utf8
```
What other locales are supported, can be seen by using this command:
```
cat /usr/share/i18n/SUPPORTED
```


## Install Apache2

We want to install the LAMP (Linux, Apache2, MySQL, PHP) Development Stack. We have installed the first part - Linux. Now comes the second part - Apache2.

Apache2 is a web server that is used to serving web pages that are requested by a client (i.e. a Browser) via the HTTP.
Apache2 is the most commonly used web server. There is also nginx and some other smaller web server, but here we concentrate on Apache2.

To install Apache2 use this command:
```
sudo apt install apache2 
```
After it installed, use this command to start the service:
```
sudo service apache2 start
```
Now you can check, if the server is running and is accessible by going to: http://localhost
You should see the Apache2 Default Page.
If you don't see anything or run into a timeout, check if the service is running with this command:
```
sudo service apache2 status
```
or check you firewall settings in Windows/Antivirus program, if Port 80 is blocked (for WSL).

There are some Apache2 Modules that are helpful and some required to be enabled, in order to use the features we want (for example vhost_alias or ssl).
To make sure we have these enabled, use these a2enmod commands to enable them. After that we need to restart Apache2:
```
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod vhost_alias
sudo a2enmod headers
sudo a2enmod cache
sudo a2enmod expires
sudo a2enmod actions
sudo a2enmod alias
sudo a2enmod proxy_fcgi

sudo service apache2 restart
```

rewrite - This module is used to rewrite URLs and can be used to create search engine-friendly URLs, to redirect requests to new locations, or to modify incoming requests.
ssl - This module provides SSL/TLS encryption for Apache2, allowing you to serve your website securely over HTTPS.
vhost_alias - This module allows to define a template for mapping incoming requests to a specific document root directory based on the requested hostname.
headers - This module lets you modify HTTP headers in the server's responses, which can be useful for setting security-related headers or custom headers for caching.
cache - This module can cache content on the server side, allowing subsequent requests for the same content to be served more quickly.
expires - This module lets you set expiration dates for certain types of files, which can help improve page load times for repeat visitors.
actions - This module lets you define actions that can be taken on certain types of files, such as executing a CGI script when a particular file extension is requested.
alias - This module lets you map URLs to specific directories or files on the server.
proxy_fcgi - This module allows you to proxy requests from Apache2 to a FastCGI server, which can handle the request and return a response back to Apache. It is useful for web applications that are written in PHP or Python.

We will set up virtual hosts with their own subdomain later.

Now we want to adjust the Apache2 Settings for permissions to match the username, to prevent some weird permissions errors in the future:
```
sudo nano /etc/apache2/envvars
```
and there change the following lines from www-data to your username:
```
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
```
And then restart Apache2 again with
```
sudo service apache2 restart
```


## Install PHP

Now we are tackling the P in LAMP. Yes I know the M is missing, but we need the P for the M.

For that we need to first add the repository personal package archive of Ondrej's PHP and because we are using Apache2 also the PPA of Ondrej's Apache2 Package.
After that a quick apt upgrade to load the new repositories:
```
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2
sudo apt upgrade
```
Now we can install PHP. I have here the two current major releases, PHP 7.4 and 8.2, with some general useful extensions.
Sometimes you still need (as of time of writing) PHP 7.4 because a CMS or an Plugin/Extension doesn't work on the newer 8.2 (yet).

### Install PHP 7.4
```
sudo apt-get install php7.4 libapache2-mod-php7.4 php7.4-bcmath php7.4-cli php7.4-common php7.4-curl php7.4-fpm php7.4-gd php7.4-json php7.4-mbstring php7.4-mysql php7.4-intl php7.4-opcache php7.4-readline php7.4-xdebug php7.4-xml php7.4-zip
```
### Install PHP 8.2
```
sudo apt-get install php8.2 libapache2-mod-php8.2 php8.2-bcmath php8.2-cli php8.2-common php8.2-curl php8.2-fpm php8.2-gd php8.2-mbstring php8.2-mysql php8.2-intl php8.2-opcache php8.2-readline php8.2-xdebug php8.2-xml php8.2-zip
```

To change the PHP Version for the CLI you can use this command and then select the version you want:
```
sudo update-alternatives --config php
```


## Install MariaDB

Now to the M Part. But instead of using the mysql-server, I use MariaDB. That is what is installed on my server and it works.

To install MariaDB and initiate the mysql installation, use these commands:
```
sudo apt install mariadb-server
sudo service mariadb start
sudo mysql_secure_installation
```
If you are on an older Ubuntu version, you might need to start MariaDB via this command:
```
sudo service mysql start
```
You will be asked to enter the current root password. But since it is the first installation, there is none. So just press Enter.
The next question is about switching to unix_socket authentication. But since the root user is out-of-box already set to that, we can answer that with n.
Now you are gonna be asked, if you want to set a root password. Press N and then Enter so you don't set a root password.
It can happen, that a package update can break the database system by removing access to the admin account.

From there you can just accept all other question by pressing Y and Enter .

Setting up admin Account for MariaDB

For things like phpmyadmin we need an admin account with a password.
For that we go into the mariadb console:
```
sudo mariadb
```
and then typing
```
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;
exit
```
Now we created an account with the name admin and the password admin.
Since this is only intended to be used in a local development environment it is more important to have a simple way, rather than a secure way.

## Install phpMyAdmin

An easy way to manage MySQL databases are using phpMyAdmin.

To install phpMyAdmin you type in:
```
sudo apt install phpmyadmin
```
After installing it, you will see a Package configuration and getting ask to select the web server you have installed and should be reconfigured.
Since we have Apache2 installed, we select apache2 and press the spacebar to get the asterisks in the brackets and then press Enter .

The next question you get ask, is if you want to configure database for phpmyadmin. Select <Yes> and press Enter.

Now you get ask to type in a MySQL application password for phpMyAdmin.
We type in admin for now, with a Tab select <Ok> and press Enter.
After confirming the password the again, the installation will get finished.

Now you can access phpMyAdmin via this link: http://localhost/phpmyadmin
