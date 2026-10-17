Определяем доступные устроойства

<img width="662" height="439" alt="Screenshot 2026-10-17 183153" src="https://github.com/user-attachments/assets/d037ac2e-cf4e-4605-b23d-dbd02f05158f" />

Запускаем скрипт
Первое действие - создание новых LG и LV, перенос / раздела на новый LVM

<img width="1168" height="667" alt="Screenshot 2026-10-17 183612" src="https://github.com/user-attachments/assets/03fa5abc-4b4c-4a38-a983-52d171e86659" />

<img width="917" height="359" alt="Screenshot 2026-10-17 183807" src="https://github.com/user-attachments/assets/3f572494-9612-4b81-9fc0-b99fca1db5a2" />

После перезагрузки проверяем разделы и смотрим что / перенесен на новый LVM

<img width="892" height="249" alt="Screenshot 2026-10-17 183930" src="https://github.com/user-attachments/assets/e34783a3-57f3-4387-a275-c240ed8d1062" />

Запускаем скрипт повторно, с параметром after-reboot - уменьшаем размер старого раздела под root до 8Gb и переносим / обратно

<img width="926" height="725" alt="Screenshot 2026-10-17 184304" src="https://github.com/user-attachments/assets/40b4f285-6d92-4573-84d6-249aa415836a" />

<img width="693" height="247" alt="Screenshot 2026-10-17 184414" src="https://github.com/user-attachments/assets/c01f1366-d709-4da8-8ec3-4945b926b87b" />

Запускаем скрипт еще раз, с параметром after-reboot-2 - выделение тома под зеркало и /home. Перенос /var и /home

<img width="918" height="779" alt="Screenshot 2026-10-17 184542" src="https://github.com/user-attachments/assets/03ad4673-a16a-487c-a19a-5b38c968febe" />

После перезагрузки убеждаемся что /var и /home перенесены

<img width="1117" height="704" alt="Screenshot 2026-10-17 184803" src="https://github.com/user-attachments/assets/5e3b9fbb-31d2-4611-b91a-14c89ec88c64" />

Создаем несколько файлов в /home, создаем снапшот, удаляем часть файлов, восстанавливаемся из снапшота и проверяем что файлы восстановились

<img width="696" height="779" alt="Screenshot 2026-10-17 185636" src="https://github.com/user-attachments/assets/3892cfeb-f959-4087-b8bb-12a2ca3b7abe" />
