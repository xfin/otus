# Обновление ядра системы
<img width="887" height="35" alt="Screenshot 2026-10-04 220750" src="https://github.com/user-attachments/assets/b30f23e7-b92d-454d-a2be-01fcb9f46165" />
При попытке установки последней версии ядра (7.2.6) с сайта https://kernel.ubuntu.com/mainline/ появлялись ошибки run-parts: missing operand.
Выяснилось что это известный и признанный баг, он был обнаружен в mainline-пакетах 6.19.11 и 7.0.0 - ошибка в maintainer scripts пакета ядра: run-parts вызывался сразу с двумя каталогами (/etc/kernel/... и /usr/share/kernel/...), 
тогда как версия run-parts, установленная в Ubuntu 24.04, принимает только один каталог.

<img width="2558" height="893" alt="Screenshot 2026-10-04 220839" src="https://github.com/user-attachments/assets/8c954980-875e-45b3-b241-405e19096a52" />

<img width="1128" height="494" alt="Screenshot 2026-10-04 225352" src="https://github.com/user-attachments/assets/51b9f66e-b304-44f6-9e07-cf75a9d89f1c" />

В качестве рабочего варианта была выбрана версия Linux 7.1.3. Перед установкой были проверены maintainer scripts данного пакета. 
В отличие от проблемного 7.2.6, в 7.1.3 каталоги /etc/kernel/*.d и /usr/share/kernel/*.d обрабатываются отдельными вызовами run-parts, 
поэтому ошибка missing operand не возникает. И процесс проходит штатно: новое ядро - обновление grub - перезагрузка - проверка версии ядра

<img width="2555" height="964" alt="Screenshot 2026-10-04 220826" src="https://github.com/user-attachments/assets/69940741-f73a-4f4b-9793-4b631a0b7edd" />

<img width="893" height="1204" alt="Screenshot 2026-10-04 223731" src="https://github.com/user-attachments/assets/6471fcba-fb58-481d-9d0a-b5a31fb5f382" />

<img width="868" height="267" alt="Screenshot 2026-10-04 223839" src="https://github.com/user-attachments/assets/1b6b4247-41e6-4838-a5d7-36bd592a8164" />

<img width="1206" height="41" alt="Screenshot 2026-10-04 223939" src="https://github.com/user-attachments/assets/6e3366e2-7067-4e70-942c-d269f85ead03" />
