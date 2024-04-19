#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to echo a task and introduce a delay
echo_task() {
    echo "Executing: $1"
    sleep 2
}

# Add Ondřej Surý's PPA for PHP
add_php_ppa() {
    echo_task "Adding Ondřej Surý's PPA for PHP"
    sudo add-apt-repository -y ppa:ondrej/php
}

# Update package index
update_package_index() {
    echo_task "Updating package index"
    sudo apt update
}

# Install required packages
install_packages() {
    echo_task "Installing packages: $*"
    sudo apt install -y "$@"
}

# Install MySQL Server
install_mysql_server() {
    echo_task "Installing MySQL Server"
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password '
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '
    sudo apt-get -y install mysql-server
}

# Secure MySQL installation using Expect
secure_mysql() {
    echo_task "Securing MySQL installation"
    expect <<EOF
    spawn sudo mysql_secure_installation

    expect "Would you like to setup VALIDATE PASSWORD component?"
    send "y\r"
    expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG"
    send "1\r"
    expect "Remove anonymous users?"
    send "y\r"
    expect "Disallow root login remotely?"
    send "n\r"
    expect "Remove test database and access to it?"
    send "y\r"
    expect "Reload privilege tables now?"
    send "y\r"
EOF
}

# Set Default PHP version
set_default_php_version() {
    echo_task "Setting PHP 8.2 as default"
    sudo update-alternatives --set php /usr/bin/php8.2
    sudo a2enmod php8.2
}

# Clone Laravel repository
clone_laravel_repository() {
    echo_task "Cloning the Laravel repository from GitHub"
    echo_task "Removing laravel dir if it exist's"
    sudo rm -rf /var/www/html/laravel
    sudo git clone https://github.com/laravel/laravel /var/www/html/laravel
}

# Function to navigate to the Laravel directory
navigate_to_laravel_directory() {
    echo_task "Navigating to the Laravel directory"
    cd /var/www/html/laravel
}

# Install Composer (Dependency Manager for PHP)
install_composer() {
    echo_task "Installing Composer"
    sudo apt install -y composer
}

# Upgrade Composer to version 2
upgrade_composer() {
    echo_task "Upgrading Composer to version 2"
    sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    sudo php composer-setup.php --install-dir /usr/bin --filename composer
}

# Install Laravel dependencies using Composer
install_laravel_dependencies() {
    echo_task "Installing Laravel dependencies using Composer"
    export COMPOSER_ALLOW_SUPERUSER=1
    sudo -S <<< "yes" composer install
}

# Set permissions for Laravel directories
set_laravel_permissions() {
    echo_task "Setting permissions for Laravel directories"
    sudo chown -R www-data:www-data /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache
    sudo chmod -R 775 /var/www/html/laravel/storage/logs
}

# Set up Apache Virtual Host configuration for Laravel
configure_apache_virtual_host() {
    echo_task "Setting up Apache Virtual Host configuration for Laravel"
    sudo cp /var/www/html/laravel/.env.example /var/www/html/laravel/.env
    sudo chown www-data:www-data /var/www/html/laravel/.env
    sudo chmod 640 /var/www/html/laravel/.env

    sudo tee /etc/apache2/sites-available/laravel.conf >/dev/null <<EOF
<VirtualHost *:80>
    ServerName 192.168.1.20
    ServerAlias *
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
        AllowOverride All
    </Directory>
</VirtualHost>
EOF
}

# Generate Laravel application key
generate_laravel_key() {
    echo_task "Generating application key"
    sudo php /var/www/html/laravel/artisan key:generate
}

# Run Laravel migration to create MySQL database tables
run_laravel_migration() {
    echo_task "Running Laravel migration to create MySQL database tables"
    sudo php /var/www/html/laravel/artisan migrate --force
}

# Function to set permissions for Laravel database directory
set_laravel_database_permissions() {
    echo_task "Setting permissions for Laravel Database"
    sudo chown -R www-data:www-data /var/www/html/laravel/database/
    sudo chmod -R 775 /var/www/html/laravel/database/
}

# Function to check and manage Apache site configurations
manage_apache_sites() {
    # Check if the default Apache site is enabled
    if sudo a2query -s 000-default.conf; then
        echo_task "Default Apache site already disabled"
    else
        # Disable the default Apache site
        echo_task "Disabling the default Apache site"
        sudo a2dissite 000-default.conf
    fi

    # Check if the Laravel site is enabled
    if sudo a2query -s laravel.conf; then
        echo_task "Laravel site already enabled"
    else
        # Enable the Laravel site
        echo_task "Enabling the Laravel site"
        sudo a2ensite laravel.conf
    fi

    # Reload Apache to apply changes
    echo_task "Reloading Apache to apply changes"
    sudo systemctl reload apache2
}

# Main function to deploy LAMP stack and Laravel application
main() {
    add_php_ppa
    update_package_index
    install_packages expect apache2 mysql-server php libapache2-mod-php php-mysql php8.2 php8.2-curl php8.2-dom php8.2-xml php8.2-mysql php8.2-sqlite3 git
    secure_mysql
    set_default_php_version
    clone_laravel_repository
    navigate_to_laravel_directory
    install_composer
    upgrade_composer
    install_laravel_dependencies
    set_laravel_permissions
    configure_apache_virtual_host
    generate_laravel_key
    run_laravel_migration
    set_laravel_database_permissions
    manage_apache_sites

    echo "PHP LARAVEL APPLICATION DEPLOYMENT COMPLETE!"
}

# Execute main function
main
