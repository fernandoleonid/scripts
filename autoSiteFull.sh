#!/bin/bash

function criarZona(){
	dominio=$1

echo " 
zone \"$dominio\" {
	type master; 
	file \"/etc/bind/db.$dominio\";
};" >> /etc/bind/named.conf.default-zones

	cp ./db.modelo /etc/bind/db.$dominio
	sed -i s/localhost/$dominio/g /etc/bind/db.$dominio 
	systemctl restart bind9
}


function criarSite() {

	dominio=$1

	echo "
	<VirtualHost *:80>
		ServerName www.$dominio
		ServerAdmin root@$dominio
		DocumentRoot /var/www/$dominio
	</VirtualHost>" >> /etc/apache2/sites-available/$dominio.conf
 
	a2ensite $dominio.conf &> /dev/null

	systemctl reload apache2 &> /dev/null

	mkdir /var/www/$dominio

	touch /var/www/$dominio/index.html

	echo "
	<html>
		<head> 
			<title>Site $dominio</title>
			<meta charset='utf-8'>
		</head>
		<body>
			<center>
				<font size='50' color='red'>
				$dominio
			       	</font>
				<p><img src='construcao.png' height='50%' width='50%'>
			</center>

		</body>
	</html>
	" > /var/www/$dominio/index.html
	cp ./construcao.png /var/www/$dominio/
}

function criarUsuario (){ 
	dominio=$1
	usuario=$(echo $dominio|cut -d"." -f1)
	useradd -m -d /var/www/$dominio -p $(openssl passwd "123") -s /bin/bash $usuario
	chown $usuario.$usuario /var/www/$dominio
}


function msg () {
	echo $1
}

for linha in $(cat dominios.txt) 
do
       criarZona $linha
       criarSite $linha
       criarUsuario $linha
done

