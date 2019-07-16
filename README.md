# ArtemAdm_infra

# Выполнено ДЗ №7 Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform.
 - [v] Основное ДЗ
 - [V] Задание со *
 - [] Задание со **

## В процессе сделано:
 - Пункт 1 // Правила файервола
 - Пункт 2 // Взаимосвязи ресурсов
 - Пункт 3 // Структуризация ресурсов
 - Пункт 4 // Модули
 - Пункт 5 // Параметризация модулей
 - Пункт 6 // Задание со *
 - Пункт 7 // Задание со **

##	Пункт 1 // Правила файервола
	Просматриваем правила в фаерволе gcloud - gcloud compute firewall-rules list
	При помощи команды import добавляем информацию о созданом без помощи Terraform ресурсе в state файл.
	terraform import google_compute_firewall.firewall_ssh default-allow-ssh
	
##      Пункт 2 // Взаимосвязи ресурсов
	Задаем IP адрес для app  в виде внешнего ресурса
	resource "google_compute_address" "app_ip" {
	  name = "reddit-app-ip"  }

	Добавляем созданный IP к нашему app
	network_interface {
	  network = "default"
	  access_config = {
	  nat_ip = "${google_compute_address.app_ip.address}"  }  }
##      Пункт 3 // Структуризация ресурсов
	Вынесем БД на отдельный инстанс VM. В директории packer создаем 2 шаблона db.json и app.json.
	db.json	
{   "builders": [        {
            "type": "googlecompute",
            "project_id": "{{user `gcp_builders_project_id`}}",
            "image_name": "reddit-base-db",
            "image_family": "reddit-base",
            "source_image_family": "{{user `gcp_builders_source_image`}}",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
            "machine_type": "{{user `gcp_builders_machine_type`}}",
            "disk_size": "{{user `gcp_builders_disk_size`}}",
            "disk_type": "{{user `gcp_builders_disk_type`}}",
            "image_description": "{{user `gcp_builders_image_descriptiondb`}}",
            "tags": "{{user `gcp_builders_tags`}}"        }    ],
	    "provisioners": [
            {            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"        }    ]  }

	app.json
	{   "builders": [        {
            "type": "googlecompute",
            "project_id": "{{user `gcp_builders_project_id`}}",
            "image_name": "reddit-base-app",
            "image_family": "reddit-base",
            "source_image_family": "{{user `gcp_builders_source_image`}}",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
            "machine_type": "{{user `gcp_builders_machine_type`}}",
            "disk_size": "{{user `gcp_builders_disk_size`}}",
            "disk_type": "{{user `gcp_builders_disk_type`}}",
            "image_description": "{{user `gcp_builders_image_descriptionapp`}}",
            "tags": "{{user `gcp_builders_tags`}}"        }    ],
	    "provisioners": [        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"        }    ]  }

	Проверяем на валидность конфиги packer validate -var-file=variables.json app.json и packer validate -var-file=variables.json db.json. Создаем образы packer build -var-file=variables.json app.json и packer build -var-file=variables.json db.json
	
	Разбиваем конфиг main.tf на несколько конфигов. В конфиге app.tf вынесем конфигурацию VM APP в конфиге db.tf соответсвенно VM DB
	app.tf
	resource "google_compute_instance" "app" {
	name = "reddit-app"
	machine_type = "g1-small"
	zone = "${var.zone}"
	tags = ["reddit-app"]
	boot_disk {
	initialize_params { image = "${var.app_disk_image}" }  }
	network_interface {
	network = "default"
	access_config = {
	nat_ip = "${google_compute_address.app_ip.address}"  }  }
	metadata {
	ssh-keys = "appuser:${file(var.public_key_path)}"  }  }
	resource "google_compute_address" "app_ip" { name = "reddit-app-ip" }
	resource "google_compute_firewall" "firewall_puma" {
	name = "allow-puma-default"
	network = "default"
	allow {
	protocol = "tcp", ports = ["9292"]  }
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["reddit-app"]  }

	Наполняем файл variables.tf новой переменной
	variable app_disk_image {
	description = "Disk image for reddit app"
	default = "reddit-app-base"  }

	db.tf
	resource "google_compute_instance" "db" {
	name = "reddit-db"
	machine_type = "g1-small"
	zone = "${var.zone}"
	tags = ["reddit-db"]
	boot_disk {
	initialize_params {
	image = "${var.db_disk_image}"  }  }
	network_interface {
	network = "default"
	access_config = {}  }
	metadata {
	ssh-keys = "appuser:${file(var.public_key_path)}"  }  }
	resource "google_compute_firewall" "firewall_mongo" {
	name = "allow-mongo-default"
	network = "default"
	allow {
	protocol = "tcp"
	ports = ["27017"]  }
	target_tags = ["reddit-db"]
	source_tags = ["reddit-app"]  }

	Наполняем файл variables.tf новой переменной
	variable db_disk_image {
	description = "Disk image for reddit db"
	default = "reddit-db-base"  }

	Создаем файл vpc.tf и вынесем правилл фаервола для ssh доступа, которое применимо для всех инстансов нашей сети
	resource "google_compute_firewall" "firewall_ssh" {
	name = "default-allow-ssh"
	network = "default"
	allow {
	protocol = "tcp"
	ports = ["22"]  }
	source_ranges = ["0.0.0.0/0"]  }

	файл main.tf у нас дожен остаться следующим
	provider "google" {
	version = "2.0.0"
	project = "${var.project}"
	region = "${var.region}"  }

	Применяем настройки terraform apply. После успешного создания ресурсов удаляем  terraform destroy

##      Пункт 4 // Модули 
	В каталоге terraform создаем директорию modules. В директории modules создаем директории db, app. Переносим (mv) db.tf в modules/db/main.tf. Затем определим переменные, которые у нас используются в db.tf и объявляются в variables.tf в файл переменных модуля modules/db/variables.tf
	С app делаем так же.
	Файл outputs.tf переносим в modules/app/outputs.tf
	В файл main.tf, где у нас определен провайдер вставим секции вызова созданных нами модулей.
	provider "google" {
	version = "2.0.0"
	project = "${var.project}"
	region = "${var.region}"	}
	module "app" {
	source = "modules/app"
	public_key_path = "${var.public_key_path}"
	zone = "${var.zone}"
	app_disk_image = "${var.app_disk_image}"  }
	module "db" {
	source = "modules/db"
	public_key_path = "${var.public_key_path}"
	zone = "${var.zone}"
	db_disk_image = "${var.db_disk_image}"  }

	Загружаем модули командой terraform get
	можем убедиться что модули подгруженны tree .terraform
	
	В файле outputs.tf изменяем текс на следующий, этим самым указываем на обработку IP с файл в модуел
	output "app_external_ip" {
	value = "${module.app.app_external_ip}"	}
###	Самостоятельное задание
	Создаем модул VPC, определяем настройки фаервола в нем
	../modules/vpc/main.tf
	resource "google_compute_firewall" "firewall_ssh" {
	  name = "${var.name-frw}-allow-ssh"
	  network = "default"
	  allow {
	    protocol = "tcp"
	    ports    = ["22"]	  }
	  source_ranges = "${var.source_ranges}"	}

	main.tf
	module "vpc" {
	  source        = "../modules/vpc"
	  name-frw      = "stage"
	  source_ranges = ["0.0.0.0/0"]	}

	Проверяем подключение по ssh. на наш внешний IP
##      Пункт 5 // Параметризация модулей
	В созданном модуле vpc используем переменную для конфигурации допустимых адресов.
	terraform/vpc/main.tf
	resource "google_compute_firewall" "firewall_ssh" {
	name = "default-allow-ssh"
	network = "default"
	allow {
	protocol = "tcp"
	ports = ["22"]	}
	source_ranges = "${var.source_ranges}"	}

	terraform/vpc/variables.tf
	variable source_ranges {
	description = "Allowed IP addresses"
	default = ["0.0.0.0/0"]	}

	Теперь мы можем задавать диапазоны IP адресов для правила файервола при вызове модуля.
	terraform/main.tf
	module "vpc" {
	source = "modules/vpc"
	source_ranges = ["80.250.215.124/32"]	}
	# вводим вместо 80.250.215.124 свой паблик IP
	
###	Самостоятельное задание
	1. Изменил IP на любой не свой IP, подключиться не удалось
	2. После возвращения своего IP, подключение по ssh стало доступно 
	3. Вернул  0.0.0.0/0 в source_ranges. 
	
##      Пункт 6 //Задание со *
###     1. Настройте хранение стейт файла в удаленном бекенде (remote backends) для окружений stage и prod, используя Google Cloud Storage в качестве бекенда. Описание бекенда нужно вынести в отдельный файл backend.tf
	В папке stage создан файл:
	terraform {
	  backend "gcs" {
	    bucket = "storage-bucket-adv2"
	    prefix = "stage" }  }

	В папке prod создан файл:
	terraform {
	  backend "gcs" {
	    bucket = "storage-bucket-adv"
	    prefix = "stage" }	}

	Запускаем в каждой папке команду terraform init, после конфигурационный файл terraform.tfstate переноситься в бакет 
###     2. Перенесите конфигурационные файлы Terraform в другую директорию (вне репозитория). Проверьте, что state-файл (terraform.tfstate) отсутствует. Запустите Terraform в обеих директориях и проконтролируйте, что он "видит" текущее состояние независимо от директории, в которой запускается 
	Проверяем что файл terraform.tfstate отсутвует в папках stage и prod. Удаляем конфигурацию терраформа terraform destroy и создаем заного terraform apply. Всё работает. 
###     3. Попробуйте запустить применение конфигурации одновременно, чтобы проверить работу блокировок
	Все блоки firewall были перенесены в terraform/modules/vpc/main.tf и добавлены переменные var.name-frw (идея в том что variables обозначает stage или prod) и при создании одновременно двух конфигураций terraform фаервол не будет писать об ошибках что имееться уже такое правило firewall  
	resource "google_compute_firewall" "firewall_ssh" {
	  name = "${var.name-frw}-allow-ssh"
	  network = "default"
	  allow {
	    protocol = "tcp"
	    ports    = ["22"]  }
	  source_ranges = "${var.source_ranges}"  }
	resource "google_compute_firewall" "firewall_puma" {
	  name    = "${var.name-frw}-puma-firewall"
	  network = "default"
	  allow {
	    protocol = "tcp"
	    ports    = ["9292"]  }
	  source_ranges = ["0.0.0.0/0"]
	  target_tags   = ["reddit-app"]  }
	resource "google_compute_firewall" "firewall_mongo" {
	  name    = "${var.name-frw}allow-mongo-default"
	  network = "default"
	  allow {
	    protocol = "tcp"
	    ports    = ["27017"]  }
	  target_tags = ["reddit-db"]
	  source_tags = ["raddit-app"]  }

	Добавление в файл конфигурации terraform/modules/app/main.tf переменной в блок app_ip, смысл такой же как и выше
	resource "google_compute_address" "app_ip" {
	  name = "${var.name-ip}-app-ip"  }

	Была обнаружена проблема что в бесплатной версии GCP на один регион указать статический IP только один. Выход из этой ситуации следующий:
	В файл terraform/stage/main.tf регион и зона europe-west2
	region  = "europe-west2"
	zone    = "europe-west2-b"

	и в модуле firewall указана имя "stage" 
	module "vpc" {
	  source        = "../modules/vpc"
	  name-frw      = "stage"
	  source_ranges = ["0.0.0.0/0"]  }
	
	В файл terraform/stage/main.tf параметры зоны и региона остаються дефолтными
	В модуле app и firewall указана имя "prod"
	module "app" {
	...
	name-ip             = "prod"
	...

	module "vpc" {
	...
	  name-frw          = "prod"
	...

	После всех настроек одновременно запускаються две конфигурации terraform
##	Пункт 7 //Задание с **
###	1. Добавьте необходимые provisioner в модули для деплоя и работы приложения. Файлы, используемые в provisioner, должны находится в директории модуля.
###	2. Опционально можете реализовать отключение provisioner в зависимости от значения переменной

