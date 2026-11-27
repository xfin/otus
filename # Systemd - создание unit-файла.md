1) Создаём файл с конфигурацией для сервиса и /var/log/watchlog.log

<img width="1085" height="151" alt="Screenshot 2026-11-22 215232" src="https://github.com/user-attachments/assets/296d494a-5e57-4ed3-95ad-83b53d576f82" />

Создаём скрипт для отправки лога в системный журнал

<img width="1079" height="287" alt="Screenshot 2026-11-22 215406" src="https://github.com/user-attachments/assets/8f310ecf-9eed-43b0-8b79-6a2c0d2ebbb7" />

Создаём юниты для сервиса и для таймера

<img width="1101" height="395" alt="Screenshot 2026-11-22 215546" src="https://github.com/user-attachments/assets/ca2e0a90-a94a-40e2-8da8-577926c26d15" />

Запускаем таймер systemctl start watchlog.timer и смотрим лог

<img width="1096" height="59" alt="Screenshot 2026-11-27 191254" src="https://github.com/user-attachments/assets/a7909c5f-b00c-466b-acd2-778c7300b74b" />

2) Устанавливаем spawn-fcgi и необходимые для него пакеты

<img width="1099" height="576" alt="Screenshot 2026-11-27 191419" src="https://github.com/user-attachments/assets/53948a02-620a-480d-b767-f3a32a501293" />

Создаём файл с настройками для сервиса в файле /etc/spawn-fcgi/fcgi.conf и создаём юнит-файл /etc/systemd/system/spawn-fcgi.service

<img width="1102" height="438" alt="Screenshot 2026-11-27 192047" src="https://github.com/user-attachments/assets/018c06a9-2c67-4243-b099-858d3c24d3d0" />

Запускаем и убеждаемся, что все успешно работает

<img width="1090" height="584" alt="Screenshot 2026-11-27 192152" src="https://github.com/user-attachments/assets/a7cceb34-63b2-489b-a8e0-9ff689fea5ea" />

3) Устанавливаем Nginx

<img width="1109" height="306" alt="Screenshot 2026-11-27 192218" src="https://github.com/user-attachments/assets/1dad9804-67f9-4721-b8f7-1b803462190e" />

Создаём Unit для работы с шаблонами nginx@.service

<img width="1098" height="572" alt="Screenshot 2026-11-27 192355" src="https://github.com/user-attachments/assets/e166943c-feb8-45f1-9778-19bc346f39fc" />

Создаём два файла конфигурации /etc/nginx/nginx-first.conf и /etc/nginx/nginx-second.conf из исходного nginx.conf
модифицировав пути до PID-файлов и разделением по портам

<img width="1098" height="76" alt="Screenshot 2026-11-27 192953" src="https://github.com/user-attachments/assets/85a17201-e6a5-4484-8a09-ba7bec440747" />

Запускаем и проверяем работу

<img width="1106" height="512" alt="Screenshot 2026-11-27 193045" src="https://github.com/user-attachments/assets/062c8bc7-6ded-466f-81ce-ad7782123165" />

<img width="1323" height="378" alt="Screenshot 2026-11-27 193134" src="https://github.com/user-attachments/assets/bca7ceed-07af-4e32-9123-9bacca2162b4" />
