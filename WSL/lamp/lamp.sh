#!/bin/bash

# local development domain
devDomain="local.dev"
# documentRoot (without trailing slash)
documentRoot="/var/www/html"
# Location of the ssl certificates
certFileLocation="/home/dfedermann/.local/share/mkcert"
# Current IP Address of the WSL
ipAddress=$(hostname -I)


##################################################
############ DONT EDIT ANYTHING BELOW ############
####### UNLESS YOU KNOW WHAT YOU ARE DOING #######
##################################################

# Looking for PHP versions that are installed
phpVersions=() # DO NOT EDIT
for phpfolder in /etc/php/*; do
	phpfolder_name=$(basename "$phpfolder")
	if [[ "$phpfolder_name" =~ ^[0-9]+\.[0-9]+$ ]]; then
		phpVersions+=("$phpfolder_name")
	fi
done

# Help Text
help=$(cat <<-END
used commands:
	\tstart - starts the web development services
	\tstop - stops the web development services
	\trestart - restarts the web development services

	\tadd - adds a project
	\t	\tadd [projectname] [php-version] [public-folder]
	\t	\tsudo lamp add test 8.2 public

	\tremove - removes a project
	\t	\tremove [projectname]
	\t	\tremove test


Available PHP Versions: ${phpVersions[@]}
END
)

# Check if script was called with sudo
if [[ $EUID != 0 ]]; then
	echo "Please run with sudo!"
	exit 1
fi

# starting services
if [[ $1 = "start" ]]; then
	echo "	* Starting Apache2"
	sudo service apache2 start
	echo "	* Starting mariadb"
	sudo service mariadb start
	echo "	* Starting PHP Versions"
	for phpVersion in "${phpVersions[@]}"; do
		echo "		* Starting PHP$phpVersion-fpm"
		sudo service "php$phpVersion-fpm" start
	done


# stopping services
elif [[ $1 = "stop" ]]; then
	echo "	* Stopping Apache2"
	sudo service apache2 stop
	echo "	* Stopping mariadb"
	sudo service mariadb stop
	echo "	* Stopping PHP Versions"
	for phpVersion in "${phpVersions[@]}"; do
		echo "		* Stopping PHP$phpVersion-fpm"
		sudo service "php$phpVersion-fpm" stop
	done


# restarting services
elif [[ $1 = "restart" ]]; then
	echo "	* Restarting Apache2"
	sudo service apache2 restart
	echo "	* Restarting mariadb"
	sudo service mariadb restart
	echo "	* Restarting PHP Versions"
	for phpVersion in "${phpVersions[@]}"; do
		echo "		* Restarting PHP$phpVersion-fpm"
		sudo service "php$phpVersion-fpm" restart
	done


# add a project
elif [[ $1 = "add" ]]; then
	# Check if a projectname is defined
	if [[ -n "$2" ]]; then
		projectName="$2"
		# Check if the defined project name is not already exists
		if [[ -f "/etc/apache2/sites-available/$projectName.conf" ]]; then
			echo "Error: Project is already exists"
			exit 1
		fi
	else
		echo "Error: Projectname needed"
		exit 1
	fi

	# Check if PHP version is defined
	if [[ -n "$3" ]]; then
		projectPhp=$(echo "$3" | grep -oE '[0-9]+\.[0-9]+')
		# Check if defined PHP version is installed
		if [[ ! "${phpVersions[*]} " =~ " ${projectPhp} " ]]; then
			echo "Error: Defined PHP version is not installed"
			printf "Installed PHP versions: %s" "${phpVersions[@]}"
			exit 1
		fi
	fi

	# Check if a Public folder is defined, if not use the project folder as documentroot
	if [[ -n "$4" ]]; then
		projectFolder="$projectName/$4"
	else
		projectFolder="$projectName"
	fi
	# Check if projectFolder does not exist
	if ! [[ -d "$documentRoot/$projectFolder" ]]; then
		echo "Error: Project Folder does not exist. Please create it first"
		echo "$projectFolder"
		exit 1
	fi


	# Generate Apache2 project .conf
	cat > "/etc/apache2/sites-available/$projectName.$devDomain.conf" << EOF
<VirtualHost *:80>
	ServerName $projectName.$devDomain
	DocumentRoot $documentRoot/$projectFolder

	<Directory $documentRoot/$projectFolder>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	# Enable PHP
	<FilesMatch \.php$>
		SetHandler "proxy:unix:/run/php/php$projectPhp-fpm.sock|fcgi://localhost/"
	</FilesMatch>

	ErrorLog \${APACHE_LOG_DIR}/$projectName-error.log
	CustomLog \${APACHE_LOG_DIR}/$projectName-access.log combined
</VirtualHost>
<VirtualHost *:443>
	Servername $projectName.$devDomain
	DocumentRoot $documentRoot/$projectFolder

	<Directory $documentRoot/$projectFolder>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	# Enable PHP
	<FilesMatch \.php$>
		SetHandler "proxy:unix:/run/php/php$projectPhp-fpm.sock|fcgi://localhost/"
	</FilesMatch>

	ErrorLog \${APACHE_LOG_DIR}/$projectName-error.log
        CustomLog \${APACHE_LOG_DIR}/$projectName-access.log combined

	SSLEngine on
	SSLCertificateFile $certFileLocation/$projectName.$devDomain.pem
	SSLCertificateKeyFile $certFileLocation/$projectName.$devDomain-key.pem
</VirtualHost>
EOF
#######################

	# Generate SSL Certs
	mkcert "-cert-file $certFileLocation/$projectName.$devDomain.pem -key-file $certFileLocation/$projectName.$devDomain-key.pem $projectName.$devDomain"

	# Enable site and reload Apache2
	sudo a2ensite "$projectName.$devDomain.conf"
	sudo service apache2 reload

	# Adding Project to Windows hosts file
	echo ""
	printf "Don't forget to add the following line in your Windows hosts file located here: C:\\Windows\\System32\\drivers\\etc"
	echo "$ipAddress	$projectName.$devDomain"

# Remove project
elif [[ $1 = "remove" ]]; then
	if [[ -n $2 ]]; then
		projectName="$2"
	else
		echo "Error: Please define a Project Name you want to delete"
		exit 1
	fi

	if [[ -f "/etc/apache2/sites-available/$projectName.$devDomain.conf" ]]; then
		echo "Removing $projectName..."
		sudo rm "/etc/apache2/sites-available/$projectName.$devDomain.conf"
		echo "disable Apache2 .conf"
		sudo a2dissite "$projectName.$devDomain.conf"
		echo "reloading Apache2"
		sudo service apache2 reload
		echo "deleting certs"
		sudo rm "$certFileLocation/$projectName.$devDomain.pem"
		sudo rm "$certFileLocation/$projectName.$devDomain-key.pem"
		echo "$projectName removed"
		echo ""
		printf "Don't forget to remove the following line in your Windows hosts file located here: C:\\Windows\\System32\\drivers\\etc"
		echo "$ipAddress		$projectName.$devDomain"
	else
		echo "Error: Project does not exist"
		exit 1
	fi
else
	echo -e "$help"
fi
