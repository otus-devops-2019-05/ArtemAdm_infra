# ArtemAdm_infra

# Выполнено ДЗ №5 Сборка образов VM при помощи Packer

 - [v] Основное ДЗ
 - [v] Задание со *

## В процессе сделано:
 - Пункт 1 // Установка Packer
 - Пункт 2 // Создаем Packer template
 - Пункт 3 // Деплоим приложение
 - Пункт 4 // Установка зависимостей и запуск приложения
 - Пункт 5 // Самостоятельные задания
 - Пункт 6 // Задание со *

##	Пункт 1 //Установка Packer
	Packer скачиваеться с офф репозитория https://www.packer.io/downloads.html с выбором своей ОЗУ.
	После скачивания разархивируеться zip командой unzip packer_1.4.2_linux_amd64.zip .
	Файл packer копируем в переменую $PATH . В моем случчае это /usr/local/bin:

##      Пункт 2 //Создаем Packer template
	Создаем папку packer в рабочем каталоге git. В папке файл ubuntu16.json
	{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "infra-189607",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "ubuntu-1604-lts",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
            "machine_type": "f1-micro"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}

	Узнаем Project-id командой gcloud projects list и вписываем в поле "project_id"
	В файле будет производиться сборка системы с параметрами, после установки системы будут установлены с скриптов ruby и mongodb.
	После создаться образ системы и удалиться система.
	Прогоняем шаблон на ошибки  командой packer validate ./ubuntu16.json
	и запускаем шаблон на сборку packer build ubuntu16.json

##      Пункт 3 //Деплоим приложение
	В GCE создаем виртулку, выбираем в настрйоках boot disk, переходим в Custom image и выбираем наш образ

##      Пункт 4 //Установка зависимостей и запуск приложения	
	Подключаемся по ссш и проверяем установку ruby и mongodb
	git clone -b monolith https://github.com/express42/reddit.git
	cd reddit && bundle install
	puma -d
	Заходим на выданый белый адрес на порт 9292 и удостоверяемся в работе приложения.

##      Пункт 5 //Самостоятельные задания
###	1. Были внесены изменения в файл ubuntu16.json:
{
  "variables": {
	"gcp_builders_project_id": "infra-111304",
	"gcp_builders_source_image": "ubuntu-1604-lts",
	"gcp_builders_machine_type": "g1-small"
  },
	 "builders": [
        {
            "type": "googlecompute",
            "project_id": "{{user `gcp_builders_project_id`}}",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "{{user `gcp_builders_source_image`}}",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}

###	2. Создадим шаблон variables.json
{
  "gcp_builders_project_id": "infra-111304",
  "gcp_builders_source_image": "ubuntu-1604-lts",
  "gcp_builders_machine_type": "g1-small",
  "gcp_builders_disk_size": "10",
  "gcp_builders_disk_type": "pd-ssd",
  "gcp_builders_image_description": "Test Infra image HW#5",
  "gcp_builders_tags": "puma-server"
}
###	3. Иследывания других обций
{
   "builders": [
        {
            "type": "googlecompute",
            "project_id": "{{user `gcp_builders_project_id`}}",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "{{user `gcp_builders_source_image`}}",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
            "machine_type": "{{user `gcp_builders_machine_type`}}",
            "disk_size": "{{user `gcp_builders_disk_size`}}",
            "disk_type": "{{user `gcp_builders_disk_type`}}",
            "image_description": "{{user `gcp_builders_image_description`}}",
            "tags": "{{user `gcp_builders_tags`}}",
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}

##      Пункт 6 //Задание со *
	Необходимо запечь образ с работающей программой puma
	Шаблон immutable.json находящейся в директории packer
{
  "builders": [
         {
                "type": "googlecompute",
                "project_id": "{{user `gcp_builders_project_id`}}",
                "image_name": "reddit-full-{{timestamp}}",
                "image_family": "reddit-full",
                "source_image_family": "{{user `gcp_builders_source_image`}}",
                "zone": "europe-west3-b",
                "ssh_username": "appuser",
                "machine_type": "{{user `gcp_builders_machine_type`}}",
                "disk_size": "{{user `gcp_builders_disk_size`}}",
                "disk_type": "{{user `gcp_builders_disk_type`}}",
                "image_description": "{{user `gcp_builders_image_description`}}",
                "tags": "{{user `gcp_builders_tags`}}"
         }
      ],
  "provisioners": [
         {
                "type": "shell",
                "script": "scripts/install_ruby.sh",
                "execute_command": "sudo {{.Path}}"
         },
         {
                "type": "shell",
                "script": "scripts/install_mongodb.sh",
                "execute_command": "sudo {{.Path}}"
         },
         {
                "type": "file",
                "source": "files/reddit",
                "destination": "~/raddit"
         },
         {
                "type": "file",
                "source": "files/puma.service",
                "destination": "/tmp/puma.service"
         },
         {
                "type": "shell",
                "inline": [
                "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",
                "sudo systemctl enable puma",
                "cd ~/raddit",
                "bundle install"
                ]
         }
  ]
}
	
	Дополнительный файлы в packer/files
	Скачан заранее образ raddit который в provisioners копируеться на вновь созданый серер.
	Для запуска приложения puma при старте системы используеться systemd unit. Создан файл puma.service
[Unit]
Description=Unit from puma
After=network.target

[Service]
Type=simple

WorkingDirectory=/home/appuser/raddit
ExecStart=/usr/local/bin/pumactl start

[Install]
WantedBy=multi-user.target  

	Который при деплое из шаблона копируеться в /tmp и после копируеться в /etc/systemd/system/puma.service
	и активируеться в астостарте командой systemctl enable puma
	
	Для ускарения деплоя системы создан скрипт create-redditvm.sh в директории config-scripts
	gcloud compute instances create reddit-test \
--boot-disk-size=10GB \
--zone europe-west2-b \
--image-family reddit-full \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \

После старта удостоверяемся что вход по http://***:9292 доступен.
