# ArtemAdm_infra

# Выполнено ДЗ №9 Деплой и управление конфигурацией с Ansible

 - [v] Основное ДЗ
 - [] Задание со *

## В процессе сделано:
 - Пункт 1 // Используем плейбуки, хендлеры и шаблоны для конфигурации окружения и деплоя тестового приложения. Подход один плейбук, один сценарий (play)
 - Пункт 2 // Аналогично один плейбук, но много сценариев
 - Пункт 3 // И много плейбуков.
 - Пункт 4 // Изменим провижн образов Packer на Ansible-плейбуки

##	Как запустить проект:
 - terraform apply

##	Как проверить работоспособность:
	ansible app -m ping
	ansible db -m ping
	ansible all -m ping -i inventory.yml
	
	ansible app -m shell -a 'ruby -v; bundler -v'
	ansible db -m command -a 'systemctl status mongod'

	прописываем дейсвующие IP ansible/inventory
	добавляем в файле ansible/app.yml db_host: IP хоста базы данных

	ansible-playbook site.yml
	Заходим по IP app:9292 и убеждаемся что работает приложение и есть доступ к базе
