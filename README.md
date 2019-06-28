# ArtemAdm_infra

# Выполнено ДЗ №4

 - [v] Основное ДЗ

## В процессе сделано:
 - Пункт 1 //Установим и настроим gcloud для работы с нашим аккаунтом;
 - Пункт 2 //Создадим хост с помощью gcloud;
 - Пункт 3 //Установим на нем ruby для работы приложения;
 - Пункт 4 //Установим MongoDB и запустим;
 - Пункт 5 //Задеплоим тестовое приложение, запустим и проверим его работу;
 - Пункт 6 //Самостоятельная работа
 - Пункт 7 //Дополнительное задание
## Установим и настроим gcloud для работы с нашим аккаунтом;
   Для установки требуеться python2.7.9+
   скачиваем ПО
   wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-252.0.0-linux-x86_64.tar.gz
   Запускаем установщик   
   ./google-cloud-sdk/install.sh
   Запускаем init
   ./google-cloud-sdk/bin/gcloud init
   На google аккаунте поулчаем ключик для аунтификации
   Проверяем что наш акк подтянулся
   gcloud auth list
   Credentialed Accounts
   ACTIVE ACCOUNT
   * art____@gmail.com 
## Создадим хост с помощью gcloud
   gcloud compute instances create reddit-app \
   --boot-disk-size=10GB \
   --zone europe-west2-b \
   --image-family ubuntu-1604-lts \
   --image-project=ubuntu-os-cloud \
   --machine-type=g1-small \
   --tags puma-server \
   --restart-on-failure
## Устанавливаем Ruby
   подуключаемся по ssh к хосту
   ssh -i ~/.ssh/id_pub artemadm@35.246.108.51
   Обновляемся и устанавливаем Ruby
   sudo apt update
   sudo apt install -y ruby-full ruby-bundler build-essential
## Устанавливаем MongoDB
   Устанавливаем ключи и добавляем репу
   sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
   sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
   Обновялем индек и стави mongod
   sudo apt update
   sudo apt install -y mongodb-org
   запускаем mongod и ставим в автостарт
   sudo systemctl start mongod
   sudo systemctl enable mongod
## Деплой приложения
   Клонируем репу
   git clone -b monolith https://github.com/express42/reddit.git
   переходим в скачаную директорию и устанавливаем приложение
   cd reddit && bundle install
   запускаем приложени и проверяем что сервер запустился и на каком порту
   puma -d
   ps aux | grep puma
   настраеваем через веб правила фаервола на открытие порта 9292 и привязываем тег
## Самостоятельная работа
   создать 3 скрипта:   
    Скрипт install_ruby.sh
	#!/bin/bash
	# Clone
	git clone -b monolith https://github.com/express42/reddit.git
	# Install bundle
	cd reddit
	bundle install
	# Start server
	puma -d
	# Test app
	ps aux | grep puma
	#!/bin/bash
	sudo apt update
	sudo apt install -y ruby-full ruby-bundler build-essential
	echo "Version Ruby:"
	ruby -v
	echo "Version Bundler:"
	bundler -v
    install_mongodb.sh
	#!/bin/bash
	# Add key
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
	# Add REPO
	sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
	# Refresh APT
	sudo apt update
	#Install MongoDB-3.2
	sudo apt install -y mongodb-org
	# Start MongoDB
	sudo systemctl start mongod
	# Add autostart MongoDB service
	sudo systemctl enable mongod
    deploy.sh
	#!/bin/bash
	# Clone
	git clone -b monolith https://github.com/express42/reddit.git
	# Install bundle
	cd reddit
	bundle install
	# Start server
	puma -d
	# Test app
	ps aux | grep puma

## Дополнительное задание
   Создание скрипта startup script. После поднятия инстанса, установка схем приложений
	startup_script.sh
	#!/bin/bash
	# Add key
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 -
	# Add REPO
	sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xultiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
	# Refresh APT
	sudo apt update
	#Install MongoDB-3.2
	sudo apt install -y mongodb-org
	# Start MongoDB
	sudo systemctl start mongod
	# Add autostart MongoDB service
	sudo systemctl enable mongod
	# Status Sevice
	#sudo systemctl status mongod
	#!/bin/bash
	sudo apt update
	sudo apt install -y ruby-full ruby-bundler build-essential
	#echo "Version Ruby:"
	#ruby -v
	#echo "Vеrsion Bundler:"
	#bundler -v
	#!/bin/bash
	# Clone
	git clone -b monolith https://github.com/express42/reddit.gi
	# Install bundle
	cd reddit
	bundle install
	# Start server
	puma -d
	# Test app
	#ps aux | grep puma
   
   Команда для запуска gcloud
    gcloud compute instances create reddit-test \
    --boot-disk-size=10GB \
    --zone europe-west2-b \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --metadata-from-file startup-script=/tmp/install.sh \
    --restart-on-failure

   Создание правила фаервола при помощи gcloud
    gcloud compute firewall-rules create default-puma-server \
    --allow=tcp:9292 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=puma-server
#--# Задание
testapp_IP = 35.246.108.51
testapp_port = 9292

