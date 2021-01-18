#!/bin/bash

# Marcamos los pasos
set -x
# Actualizamos la lista de paquetes
apt update

#Actualizamos los paquetes
apt upgrade -y

###########################
#Comenzamos la instalación#
###########################

# Instalamos apache
apt install apache2 -y

# Instalamos los módulos de PHP
apt install php libapache2-mod-php php-mysql -y

#######################################
# Instalamos herramientas adicionales #
#######################################

# Declaración las variables 
HTTPPASSWD_USER=resti
HTTPASSWD_PASSWD=root
HTTPPASSWD_DIR=/home/ubuntu
#IP privada del back-end
IP_PRIVADA_MYSQL=172.31.0.216

#########
#Adminer#
#########

# Creamos carpeta
mkdir /var/www/html/Adminer
# Nos movemos a esta ruta
cd /var/www/html/Adminer

# Instalamos Adminer
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php

# Renombrar el archivo descargado por index
mv adminer-4.7.7-mysql.php index.php

############
#PhpMyAdmin#
############


#Instalamos la utilidad unzip para descomprimir el codigo fuente
apt install unzip -y

#Descargamos el código fuente de phpMyAdmin del repositorio oficial
cd /home/ubuntu

# Por si hay que repetir script
# rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

#Descomprimimos el archivo .zip
unzip phpMyAdmin-5.0.4-all-languages.zip -y

#Borramos el archivo .zip ya que lo tenemos ya descomprimido
rm -rf phpMyAdmin-5.0.4-all-languages.zip

#Movemos el directorio de phpMyAdmin al directorio /var/www/html
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin

#Configuramos el archivo config.inc.php de phpMyAdmin
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IP_PRIVADA_MYSQL/" /var/www/html/phpmyadmin/config.inc.php
sed -i "s/localhost/$IP_PRIVADA_MYSQL/" /var/www/html/phpmyadmin/config.php

##########
#GoAccess#
##########

echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt-get update -y
apt-get install goaccess -y

# Creación de un direcctorio para consultar GoAccess

mkdir -p /var/www/html/stats
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -bc $HTTPPASSWD_DIR/.htpasswd $HTTPPASSWD_USER $HTTPASSWD_PASSWD

# Copiamos el archivo de configuración de Apache
cp /home/ubuntu/000-default.conf /etc/apache2/sites-available/

# Reiniciamos el servicio
systemctl restart apache2

# ----------------------------#
# Instalamos la aplicación web#
# ----------------------------#

# Clonamos el repositorio
cd /var/www/html
rm -rf iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/


# Eliminamos contenido que no sea útil
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp

#Cambiamos los permisos
chown www-data:www-data * -R

# Reiniciamos el apache
systemctl restart apache2

# Cambiamos a la ruta original

cd /home/ubuntu

