Создать свой DEB пакет (используем Ubuntu 24.04 и deb пакеты).

Установка доп софта

<img width="1074" height="429" alt="Screenshot 2026-11-04 224806" src="https://github.com/user-attachments/assets/8a847417-ddbb-4f25-b7e2-0eb63060bb4c" />

Для загрузки исходников Nginx необходимо включить deb-src в APT

<img width="842" height="264" alt="Screenshot 2026-11-04 225144" src="https://github.com/user-attachments/assets/61faaff4-ea02-416a-b090-bb5e37eaebd9" />

<img width="900" height="458" alt="Screenshot 2026-11-04 225227" src="https://github.com/user-attachments/assets/d20c0e82-52c7-4492-a942-e6e0af74b88b" />

Создаём рабочую директорию и скачиваем исходники

<img width="1017" height="930" alt="Screenshot 2026-11-04 225517" src="https://github.com/user-attachments/assets/a043d8a4-0871-4134-9fb8-939c229e7d8c" />

Устанавливаем все пакеты, необходимые для сборки Nginx

<img width="1097" height="353" alt="Screenshot 2026-11-04 225600" src="https://github.com/user-attachments/assets/afc61ffb-3acb-41e9-b98e-33dad6144c4c" />

Также нужно скачать и собрать исходный код модуля ngx_brotli

<img width="1097" height="567" alt="Screenshot 2026-11-04 231750" src="https://github.com/user-attachments/assets/d85afe7c-ec4d-4587-b2c2-1946f87126b8" />

<img width="1103" height="577" alt="Screenshot 2026-11-04 231933" src="https://github.com/user-attachments/assets/10206360-4081-491d-8a60-76bc0d5b69bf" />

<img width="1015" height="648" alt="Screenshot 2026-11-04 232004" src="https://github.com/user-attachments/assets/6e09f79c-5123-43f7-822c-4aed61d37cab" />

Нужно поправить сам spec файл, чтобы Nginx собирался с необходимыми нам опциями. Для debian это "--add-module=/home/$USER/ngx_brotli \" в debian/rules:

<img width="1061" height="1009" alt="Screenshot 2026-11-04 232744" src="https://github.com/user-attachments/assets/0794471e-3d79-4645-8749-3455ac2da21f" />

Запускаем сборку. Флаг -b означает сборку только бинарных пакетов (без исходников). Флаг -us -uc отключает подпись пакетов, т.к. используем тестово и локально:

<img width="1778" height="1009" alt="Screenshot 2026-11-04 232853" src="https://github.com/user-attachments/assets/37c4b100-c848-46ce-8d4b-3f845da443b3" />

<img width="1777" height="1012" alt="Screenshot 2026-11-04 233045" src="https://github.com/user-attachments/assets/0abb12e0-9013-4e15-8d39-34aaf4032597" />

Убедимся, что пакеты создались:

<img width="955" height="305" alt="Screenshot 2026-11-04 233112" src="https://github.com/user-attachments/assets/9e81fc4f-1bc5-4a02-9d5c-e8ee94ecaadb" />

Устанавливаем пакет, проверяем, что Nginx работает и модуль Brotli загружен:

<img width="1818" height="1179" alt="Screenshot 2026-11-04 233412" src="https://github.com/user-attachments/assets/fe42c2a4-a3cd-48c3-926b-287757075304" />

<img width="1300" height="551" alt="Screenshot 2026-11-04 233631" src="https://github.com/user-attachments/assets/17c5480d-0b90-45ae-8428-83392ff23256" />

<img width="1778" height="193" alt="Screenshot 2026-11-04 235821" src="https://github.com/user-attachments/assets/3ce7cc49-6721-4320-a24c-184e1de956b8" />

Для создания локального APT-репозитория используем утилиту reprepro. Создаем директорию, файл конфигурации дистрибутива и файл опций:

<img width="926" height="289" alt="Screenshot 2026-11-05 000138" src="https://github.com/user-attachments/assets/b6992dbe-4bc0-47f3-927f-79d892f630b1" />

Копируем собранные .deb файлы во incoming и добавляем их в репозиторий

<img width="1136" height="35" alt="Screenshot 2026-11-05 000323" src="https://github.com/user-attachments/assets/68d09107-b9d4-48fa-b067-bf7daf9fc398" />

<img width="1114" height="534" alt="Screenshot 2026-11-05 000713" src="https://github.com/user-attachments/assets/9ca9c39f-b03e-4610-9695-d544df74dab0" />

Добавим файл конфигурации Nginx с каталогом apt-repo и проверим через браузер:

<img width="1432" height="1140" alt="Screenshot 2026-11-05 001049" src="https://github.com/user-attachments/assets/2d96c625-9e8c-4e18-a725-dea526832fb9" />

<img width="819" height="326" alt="Screenshot 2026-11-05 001834" src="https://github.com/user-attachments/assets/68c56548-bd60-4044-9649-09df56611436" />

Подключим репозиторий и посмотрим список пакетов в нём:

<img width="982" height="324" alt="Screenshot 2026-11-05 010015" src="https://github.com/user-attachments/assets/9ca9ead5-bc36-4f70-b123-9f109c12cebf" />

Добавим пакет percona в репозиторий

<img width="1789" height="763" alt="Screenshot 2026-11-05 002812" src="https://github.com/user-attachments/assets/3eecc4a7-58f4-4ed8-95da-5700e88f5864" />

Обновим списки пакетов и проверим добавленый percona:

<img width="802" height="343" alt="Screenshot 2026-11-05 003030" src="https://github.com/user-attachments/assets/228853bf-c863-444e-adee-61b915167dcd" />

Установим пакет percona:

<img width="2525" height="713" alt="Screenshot 2026-11-05 003155" src="https://github.com/user-attachments/assets/ffd7c506-aea8-4deb-8901-5f2fa95b9454" />
