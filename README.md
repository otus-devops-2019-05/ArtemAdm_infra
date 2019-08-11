# ArtemAdm_infra

# Выполнено ДЗ №10 Ansible:работа с ролями и окружениями

 - [v] Основное ДЗ
 - [] Задание со *
 - [] Задание со **

## В процессе сделано:
 - Пункт 1 // Переносим созданные плейбуки в раздельные роли
 - Пункт 2 // Описываем два окружения
 - Пункт 3 // Используем коммьюнити роль nginx
 - Пункт 4 // Используем Ansible Vault для наших окружений

##	Как запустить проект:
 - terraform apply

##	Как проверить работоспособность:
	ansible app -m ping
	ansible db -m ping
	ansible all -m ping -i environments/stage/inventory
	ansible all -m ping -i environments/prod/inventory
	
	прописываем "дейсвующие IP" ansible/environments/stage/inventory иди ansible/environments/prod/inventory
	добавляем в файле ansible/environments/stage/group_vars/app db_host: "IP хоста" базы данных

	ansible-playbook playbook/site.yml (stage)
	ansible-playbook -i environments/prod/inventory  playbook/site.yml
	Заходим по "IP app":80 и убеждаемся что работает приложение и есть доступ к базе

	Подключаемся по ssh "IP app"
	su admin и вводим passwd который задавали.
