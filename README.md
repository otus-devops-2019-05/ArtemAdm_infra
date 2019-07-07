# ArtemAdm_infra

# Выполнено ДЗ № Практика IaC использованием Terraform

 - [v] Основное ДЗ
 - [] Задание со *

## В процессе сделано:
 - Пункт 1 // Установка Terraform
 - Пункт 2 // Развитие проекта Infra
 - Пункт 3 // Настройка SSH
 - Пункт 4 // Настройка Firewall
 - Пункт 5 // Настройка Provisioners
 - Пункт 6 // Variables
 - Пункт 7 // Самостоятельные задания
 - Пункт 8 // Задание с *
 - Пункт 9 // Задание с **
##	Пункт 1 // Установка Terraform
	Скачиваем terrafom версии 0.11.11 с офсайта(https://www.terraform.io/downloads.html) под нужную ОС. wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
	Распаковываем  архив unzip и установочный файл помещаем в PATH /usr/bin/
	Проверяем версию terraform -v

##      Пункт 2 // Развитие проекта Infra
	Создаем директорию terraform и в ней главный конфигаруционный файл main.tf
	
	terraform {
	# Версия terraform
	required_version = "0.11.11"	}
	provider "google" {
	# Версия провайдера
	version = "2.0.0"
	# ID проекта
	project = "${var.project}"
	reg
	resource "google_compute_instance" "app" {
	name = "reddit-app"
	machine_type = "g1-small"
	zone = "europe-west1-b"
	# определение загрузочного диска
	boot_disk {
	initialize_params {
	image = "reddit-base"	}	}
	# определение сетевого интерфейса
	network_interface {
	# сеть, к которой присоединить данный интерфейс
	network = "default"
	# использовать ephemeral IP для доступа из Интернет
	access_config {}	}	}

	Загружаем провайдера terraform init
	Проверяем конфиг на ошибки terraform plan
	Если ошибок не обнаружено запускаем установку terraform apply

##      Пункт 3 // SSH
	Узнаем IP командой terraform show | grep nat_ip
	Добавляем медатаные ssh ключа в main файл
	metadata {
	# путь до публичного ключа
	ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"	}
	
	Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
	После подключаемся по ssh к серверу ssh appuser@<внешний_IP>
	
	Создаем outputs.tf и приводим к виду:
	output "app_external_ip" {
	value = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"}

	Обновляем переменую terraform refresh
	Можем теперь узнать IP адрес командой terraform output

	Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
	Добавляем Тег к ресурсу 
	resource "google_compute_instance" "app" {
	tags = ["reddit-app"]}
	
	Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply

##      Пункт 4 // Firewall
	Создаем правило в фаерволе. В main добавляем раздел

        resource "google_compute_firewall" "firewall_puma" {
        name = "allow-puma-default"
        # Название сети, в которой действует правило
        network = "default"
        # Какой доступ разрешить
        allow {
        protocol = "tcp"
        ports = ["9292"]	}
        # Каким адресам разрешаем доступ
        source_ranges = ["0.0.0.0/0"]
        # Правило применимо для инстансов с перечисленными тэгами
        target_tags = ["reddit-app"]        }

        Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
        Добавляем Тег к ресурсу
        resource "google_compute_instance" "app" {
        tags = ["reddit-app"]	}

        Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
        Добавляем Тег к ресурсу
        resource "google_compute_instance" "app" {
        tags = ["reddit-app"]   }

        Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply

##      Пункт 5 // Provisioners	
	Указываем провидинеру скопировать локальный файл в указаное место на удаленном хосте

	provisioner "file" {
	source = "files/puma.service"
	destination = "/tmp/puma.service" }

	Создаем папку files в директории terraform и создаем файл puma.service

	[Unit]
	Description=Puma HTTP Server
	After=network.target
	[Service]
	Type=simple
	User=appuser
	WorkingDirectory=/home/appuser/reddit
	ExecStart=/bin/bash -lc 'puma'
	Restart=always
	[Install]
	WantedBy=multi-user.target
	
	Добавляем еще один провинжинер для деплоя приложения 
	
	provisioner "remote-exec" {
	script = "files/deploy.sh" }

	Создаем файл deploy.sh в директории terraform/files c содержимым
	#!/bin/bash
	set -e
	APP_DIR=${1:-$HOME}
	git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
	cd $APP_DIR/reddit
	bundle install
	sudo mv /tmp/puma.service /etc/systemd/system/puma.service
	sudo systemctl start puma
	sudo systemctl enable puma

	Перед блоком провинжинеров добавляем параметр подключения к VM

	connection {
	type = "ssh"
	user = "appuser"
	agent = false
	# путь до приватного ключа
	private_key = "${file("~/.ssh/appuser")}"  }

	Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
	
	Проверяем работу приложения, указываем в браузере наш внешний IP и порт 9292

##      Пункт 6 //  Input vars
	Создаем файл variables.tf в директории terraform для параметризирования конфигурационого файла и определяем переменные

	variable project {
	description = "Project ID"	}
	variable region {
	description = "Region"
	# Значение по умолчанию
	default = "europe-west1"	}
	variable public_key_path {
	# Описание переменной
	description = "Path to the public key used for ssh access"	}
	variable disk_image {
	description = "Disk image"	}

	В файле main теперь указываем переменные

	provider "google" {
	version = "2.0.0"
	project = "${var.project}"
	region = "${var.region}"	}
	
	boot_disk {
	initialize_params {
	image = "${var.disk_image}"	}	}

	metadata {
	ssh-keys = "appuser:${file(var.public_key_path)}"	}

	Определяем переменые используя файл terraform.tfvars из которого terraform загружает значения автоматически. наполняем его следующими значениями

	project = "infra-179015"
	public_key_path = "~/.ssh/appuser.pub"
	disk_image = "reddit-base"

	Финальная проверка. Удаляем ресурсы terraform destroy
	Проверяем на наличие ошибок конфи terraform plan и устанавливаем изминения terraform apply
	Проверяем работу приложения, указываем в браузере наш внешний IP и порт 9292		

##      Пункт 7 //  Самостоятельные задания
###     1. Определите input переменную для приватного ключа, использующегося в определении подключения для провижинеров (connection); 
	metadata {
	ssh-keys = "appuser:${file(var.public_key_path)}"	}

###	2. Определите input переменную для задания зоны в ресурсе "google_compute_instance" "app". У нее * должно быть значение по умолчанию*;
	zone         = "${var.zone}"
	в файл variables.tf задаем значения 

	variable region {
	description = "Region"
	default = "europe-west1"	}

###	3. Отформатируйте все конфигурационные файлы используя команду terraform fmt;
	в папке terraform вводим команду
	terraform fmt 
	
	Тем самым terraform приводит в правильный вид конфиги.

###     4. Так как в репозиторий не попадет ваш terraform.tfvars, то нужно сделать рядом файл terraform.tfvars.example, в котором будут указаны переменные для образца.
	Выполенено

##      Пункт 8 //Задание со *
###     1. Опишите в коде терраформа добавление ssh ключа пользователя appuser1 в метаданные проекта. Выполните terraform apply и проверьте результат (публичный ключ можно брать пользователя appuser)
	ssh-keys = "appuser1:${file(var.app1_public_key_path)}"
###     2. Опишите в коде терраформа добавление ssh ключей нескольких пользователей в метаданные проекта (можно просто один и тот же публичный ключ, но с разными именами пользователей, например appuser1, appuser2 и т.д.).
	ssh-keys = "appuser:${file(var.public_key_path)} \nappuser1:${file(var.app1_public_key_path)}"
###     3. Добавьте в веб интерфейсе ssh ключ пользователю appuser_web в метаданные проекта
	resource "google_compute_project_metadata_item" "sshKeys" {
	key   = "sshKeys"
	value = "appuser_web:${file(var.web_publickey)}"	}
	Проблем не было обнаруженно ...
##	Пункт 9 //Задание с **
Создайте файл lb.tf и опишите в нем в коде terraform создание HTTP балансировщика, направляющего трафик на наше развернутое приложение на инстансе reddit-app. Проверьте доступность приложения по адресу балансировщика. Добавьте в output переменные адрес балансировщика.
	Создаем в файле lb.tf 

	resource "google_compute_instance_group" "api" {
	project = "${var.project}"
	name    = "${var.name}-instance-group"
	zone    = "${var.zone}"
	instances = [ "${google_compute_instance.api.self_link}",	]
	lifecycle {
	create_before_destroy = true	}
	named_port {
	name = "http"
	port = 80	}	}

	resource "google_compute_instance" "api" {
	project      = "${var.project}"
	name         = "${var.name}-instance"
	machine_type = "f1-micro"
	zone         = "${var.zone}"
	 ### Мы помечаем экземпляр тегом, указанным в правиле брандмауэра
	tags = ["reddit-app"]
	boot_disk {
	initialize_params {
	image = "${var.disk_image}"	}	}

	### Убедитесь, что у нас запущено колба
	metadata {
	ssh-keys = "appuser:${file(var.public_key_path)} \nappuser1:${file(var.app1_public_key_path)}"	}

	connection {
	type  = "ssh"
	user  = "appuser"
	agent = false

	# путь до приватного ключа
	private_key = "${file(var.privat_key_path)}"	}

	# Запустить экземпляр в подсети по умолчанию
	network_interface {
	subnetwork = "default"

	# Это дает экземпляру публичный IP-адрес для подключения к интернету. Обычно у вас будет Cloud NAT,
	# но ради простоты мы назначаем публичный IP для подключения к интернету
	# чтобы иметь возможность запускать сценарии запуска
	access_config {}	}	}

	resource "google_compute_backend_service" "api" {
	name      = "staging-service"
	port_name = "http"
	protocol  = "HTTP"

	backend {
	group = "${google_compute_instance_group.api.self_link}"	}

	health_checks = [ "${google_compute_http_health_check.staging_health.self_link}" ]
	#  depends_on = [
	#    "${google_compute_instance_group.api}"
	#  ]
	}

	resource "google_compute_http_health_check" "staging_health" {
	name = "${var.name}-hc"

	#  request_path = "/health_check"
	#http_health_check {
	port = 80
	request_path = "/api"
	check_interval_sec = 5
	timeout_sec        = 5	}


	Удалось создать instance group и backend. К сожалению больше сил и времени нету на это ДЗ :(

