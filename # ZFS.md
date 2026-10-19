Смотрим список доступных дисков, ставим пакет zfs-utils, создаём 4 пула из двух дисков в режиме RAID 1, смотрим 
информацию о размере пула, количеству занятого и свободного места, дедупликации и т.д.,
добавляем разные алгоритмы сжатия в каждую файловую систему,
проверяем, что все файловые системы действительно имеют разные методы сжатия:

<img width="906" height="780" alt="Screenshot 2026-10-19 205124" src="https://github.com/user-attachments/assets/64908a84-b392-4c17-9cc5-8fc26724e6b6" />


Скачиваем один и тот же текстовый файл во все пулы:

<img width="2525" height="1229" alt="Screenshot 2026-10-19 205520" src="https://github.com/user-attachments/assets/a218902c-4e14-4fd9-885a-317e271836af" />


Видим что самый оптимальный метод сжатия у нас используется в пуле otus3 - gzip-9
Проверяем, сколько места занимает один и тот же файл в разных пулах и степень сжатия файлов:

<img width="784" height="513" alt="Screenshot 2026-10-19 205624" src="https://github.com/user-attachments/assets/c4b2f887-00f8-419d-8c75-73459c8a6230" />



Определяем настройки пула:
Скачиваем архив в домашний каталог, разархивируем, импортируем данный каталог в пул, импортируем данный пул в ОС

<img width="2555" height="626" alt="Screenshot 2026-10-19 210301" src="https://github.com/user-attachments/assets/0c353bdc-150a-460f-a9ea-7cc7390c1ef7" />


Проверяем информацию о каждом диске, состоянии сканирования и об ошибках чтения, записи и совпадения хэш-сумм:

<img width="921" height="1233" alt="Screenshot 2026-10-19 210312" src="https://github.com/user-attachments/assets/800450fb-125e-4faa-8ee7-2c8aec18ac22" />


Определяем настройки:

<img width="732" height="1339" alt="Screenshot 2026-10-19 210354" src="https://github.com/user-attachments/assets/569a80b2-54c5-4b87-be48-8afdfa827b00" />


Запрос сразу всех параметров файловой системы:

<img width="562" height="1334" alt="Screenshot 2026-10-19 210430" src="https://github.com/user-attachments/assets/9d53f3fc-8794-423f-ac23-147949e96038" />


Уточняем конкретные параметры:

<img width="443" height="286" alt="Screenshot 2026-10-19 210540" src="https://github.com/user-attachments/assets/3b40ae3e-4233-4ed5-a905-5c3e70e9345a" />


Работа со снапшотом и поиск сообщения от преподавателя:

Скачиваем файл указанный в задании, восстанавливаем файловую систему из снапшота (тут система почему-то ругнулась cannot receive new filesystem stream: incomplete stream, возможно файл еще небыл докачен и процесс происходил в фоне, со второго раза всё прошло успешно), 
ищем в каталоге /otus/test файл с именем “secret_message”, смотрим содержимое найденного файла, видим ссылку на курс OTUS - https://otus.ru/lessons/linux-hl/


<img width="1583" height="452" alt="Screenshot 2026-10-19 210954" src="https://github.com/user-attachments/assets/d402d674-1601-49b2-8c30-43ead013da6f" />

