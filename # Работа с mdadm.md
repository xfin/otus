# Работа с mdadm

Смотрим доступные диски и запускаем скрипт создания рейд-1
mdadm выдал:
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
потому как на диски пустые и на них небыло суперблоков рейда

<img width="1352" height="1182" alt="Screenshot 2026-10-12 001115" src="https://github.com/user-attachments/assets/e1749c7b-d188-40e2-96fa-9d4530d476eb" />

Ждем пока отсинхронизируются диски

<img width="783" height="515" alt="Screenshot 2026-10-12 001331" src="https://github.com/user-attachments/assets/2d6f1626-836d-480b-a1cb-59b142e10cd1" />

Фейлим один из дисков и производим замену

<img width="920" height="1279" alt="Screenshot 2026-10-12 001653" src="https://github.com/user-attachments/assets/2f4dbbde-4276-4864-b22e-4e8c9f6c8cce" />

Далее создаем GPT таблицу, разделы и монтируем разделы

<img width="851" height="272" alt="Screenshot 2026-10-12 002058" src="https://github.com/user-attachments/assets/4aa4351d-efef-41e5-addf-89c00a218b73" />

<img width="1136" height="1033" alt="Screenshot 2026-10-12 002155" src="https://github.com/user-attachments/assets/02ffbd77-24b3-43bf-a23a-a456cfa0a04a" />

<img width="1338" height="493" alt="Screenshot 2026-10-12 002232" src="https://github.com/user-attachments/assets/ece5b7dd-ecf1-45fe-a6e7-a349d7a2471f" />
