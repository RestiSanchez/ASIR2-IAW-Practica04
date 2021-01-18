#! /bin/bash
set -x

# Actualizamos la lista de paquetes
apt update

# Instalamos el MySQL Server
apt install mysql-server -y

# Instalamos las librerias PHP para MySQL
apt install debconf-utils -y

# Declaración de variables

IP_PRIVADA_FRONT=3.221.150.99 # Indica la interfaz de red del servidor de MySQL que permite conexiones
BD_ROOT_PASSWD=root 

# Actualizamos la contraseña de root de MySQL
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$BD_ROOT_PASSWD'; "

# le damos permisos
mysql -u root  <<< " FLUSH PRIVILEGES ; "

#############################################################
# Ejecutamos el script de base de datos de la aplicación web#
#############################################################

# Clonamos el repositorio
cd /home/ubuntu
rm -rf iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/


# Eliminamos contenido que no sea útil
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp


# Importamos el script de creación de la base de datos
mysql -u root -p$BD_ROOT_PASSWD < /home/ubuntu/iaw-practica-lamp/db/database.sql

#---------------------------------------------------------------#
#Configuramos MySQL para permitir conexiones desde la IP privada
#---------------------------------------------------------------#
sudo sed -i "s/127.0.0.1/$IP_PRIVADA_FRONT/" /etc/mysql/mysql.conf.d/mysqld.cnf

#Reiniciamos servicio MySQL
systemctl restart mysql

#---------------------------------------------------------------#





