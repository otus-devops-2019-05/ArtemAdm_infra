# ArtemAdm_infra

# Выполнено ДЗ №10 Ansible:работа с ролями и окружениями

 - [v] Основное ДЗ
 - [] Задание со *
 - [] Задание со **

## В процессе сделано:
 - Пункт 1 // Локальная разработка при помощи Vagrant, доработка ролей для провижининга в Vagrant
 - Пункт 2 // Тестирование ролей при помощи Molecule и Testinfra
 - Пункт 3 // Переключение сбора образов пакером на использование ролей

##	Как запустить проект:
 - vagrant up
 - molecule create

##	Как проверить работоспособность:
	vargrant status
	vagrant ssh appserver
	  telnet 10.10.10.10 27017
	vagrant ssh dbserver
	curl 10.10.10.20:9292

	molecule list
	molecule login -h instance
	molecule verify 

	
