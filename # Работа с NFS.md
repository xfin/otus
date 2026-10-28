Две ВМ: 

- nfss - сервер (10.0.30.12)
- nfsc - клиент (10.0.30.13)

На сервере:
  Устанавливаем сервер NFS

<img width="1199" height="1339" alt="Screenshot 2026-10-28 223924" src="https://github.com/user-attachments/assets/f70e1179-8aeb-47b7-8ff8-732814a016e2" />


  Проверяем наличие слушающих портов 2049/udp, 2049/tcp,111/udp, 111/tcp. Создаём и настраиваем директорию, которая будет экспортирована. 
  Cоздаём в файле /etc/exports структуру для экспорта. Экспортируем ранее созданную директорию и проверяем.


<img width="1196" height="381" alt="Screenshot 2026-10-28 224622" src="https://github.com/user-attachments/assets/11403563-c596-46b6-ab59-7d7e32c64f8f" />


На клиенте:
  Устанавливаем NFS-клиент

<img width="1111" height="1173" alt="Screenshot 2026-10-28 224805" src="https://github.com/user-attachments/assets/ef2d100a-9675-424a-a3b1-283f7a153097" />


  Добавляем в /etc/fstab строку монтирования nfs шары. Перечитываем файлы конфигурации systemd. Заново обрабатываем все записи в /etc/fstab, относящиеся к сетевым монтированиям.

<img width="1083" height="97" alt="Screenshot 2026-10-28 225202" src="https://github.com/user-attachments/assets/cfb4e205-5d81-4bf3-a2ca-a9b394593a0d" />

  Т.к. обращений к /mnt/share еще небыло, доп параметры не показываются. Перейдем в каталог /mnt/share и повторим вывод. Видим что теперь команда имеет полный вывод и отображает нужную версию NFSv3.

<img width="2154" height="40" alt="Screenshot 2026-10-28 225242" src="https://github.com/user-attachments/assets/007de043-9cd7-46d3-bfa3-b85703f4abf1" />


На сервере:
  Создаем тестовый файл

<img width="485" height="40" alt="Screenshot 2026-10-28 225419" src="https://github.com/user-attachments/assets/43401869-551c-438d-848f-1447725d8a04" />


На клиенте:
  Проверяем что файл появился. Создаем еще один файл. Проверяем что файл создан.

<img width="547" height="251" alt="Screenshot 2026-10-28 225544" src="https://github.com/user-attachments/assets/4049de55-c462-4f04-84c3-50378975a2fd" />

  
  Перезагружаем клиента. Проверяем что файлы на месте.

<img width="583" height="173" alt="Screenshot 2026-10-28 230001" src="https://github.com/user-attachments/assets/cdb26196-2abb-4429-a891-360658393cae" />


На сервере:
  Перезагружаем сервер. Проверяем наличие файлов. Проверяем экспорты и работу RPC.

<img width="959" height="247" alt="Screenshot 2026-10-28 230403" src="https://github.com/user-attachments/assets/4fd1cdf9-787f-48d9-bb1a-1b2688e9835f" />

На клиенте:
  Еще раз перезагружаем. Проверяем что всё смонтировалось. Проверяем наличие ранее созданных файлов. Создаем еще один файл и проверяем что он создался.

<img width="2155" height="457" alt="Screenshot 2026-10-28 230656" src="https://github.com/user-attachments/assets/ffc5859a-99cb-47c6-8855-cef9e446ec11" />

