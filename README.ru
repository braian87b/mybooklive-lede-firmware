
Прошивка предназначена для установки нв однодисковый сетевой накопитель Western Digital 'MyBook Live'.
Построена на основе проекта LEDE (ex-OpenWRT): http://www.lede-project.org.

Данная версия предполагает, что установка производится на чистый жесткий диск.

(!) ВСЕ СУЩЕСТВУЮЩИЕ НА ДИСКЕ ДАННЫЕ БУДУТ УТЕРЯНЫ (!)

Для установки необходим компьюьер с установленной Linux-системой, или загружаемой в внешнего носителя
системой Linux типа Live-CD, Live-USB и т.д.
Прошивка скачивается с github.com, скриптом установки используются следующие утилиты: sgdisk, mke2fs, lsblk.
Для debian-подобных систем доустановить необходимые программы можно командой:

    sudo apt-get install git gdisk e2fsprogs util-linux

Скрипт установки необходимо запускать с правами суперпользователя (из-под 'root').
Диск для записи прошивки необходимо подключить в разъём SATA компьютера, и в терминале выполнить:

    cd ~
    git clone https://github.com/toyan/mybooklive-lede-firmware.git
    cd ./mybooklive-lede-firmware
    su
    ./mbl-lede-install-ru

Далее скрипт предложит указать диск для записи прошивки.
Обычно при подключении нового диска к компьютеру ему присваевается следующая буква алфавита (здесь вместо Х) в имени 'sdX'.
Например, если у вас один диск в компьютере, то вероятнее всего, он будет с именем 'sda'.
Тогда, если Вы подключили второй диск, ему будет присвоено имя 'sdb'.
Если вы загрузились в систему с флешки, тогда и она будет иметь какое-то своё имя, и тогда ваш целевой диск может иметь
имя 'sdc'.
Скрипт выводит информацию о подключенных дисках, и по умолчанию выбирает диск с самой последней буквой из имеющищихся
в системе.
Вам нужно, исходя из выведенной схемы подключенных дисков, правильно выбрать целевой для записи прошивки и указать
в ответ на запрос, например 'sdc'.

Будьте внимательны при выборе целевого диска!
Ошибка при указании диска может привести к повреждению базовой системы! Никаких дополнительных проверок не производится!

После записи прошивки, подключите диск к MBL, подключите питание, и дождитесь, пока промигается зелёный светодиод
и замигает синий.
В этой версии прошивки это означает, что инициализация устройства успешно завершена, и все сервисы запущены.
В браузере набирите адрес MBL - должно появиться окно авторизации доступа к веб-интерфейсу.

По умолчанию после загрузки включен DHCP-клиент, т.е. IP-адрес устройство получает при загрузке от DHCP-сервера вашей сети,
как правило это роутер. Также в конфигурации в качестве статического прописан адрес 192.168.1.11.

Если же вам необходимо задать другой статический адрес, то это можно сделать сразу после записи прошивки,
перед отключением диска:

    mkdir tmp
    mount /dev/sdX2 tmp    # здесь X - буква вашего целевого диска

И в файле ./tmp/etc/config/network в блоке config interface 'lan', пользуясь любым linux-редактором, заменить:

    option proto 'dhcp' на option proto 'static'
    option ipaddr '192.168.1.11' на нужный вам статический IP-адрес

Сохранить изменения, и набрать:

    umount tmp
    sync

Доступ к веб-интерфейсу и по SSH-протоколу: логин 'root', пароль не задан (пустой).
Доступ к ресурсам samba: логин 'admin', пароль 'welc0me'.

    Задать/поменять пароли: зайдя по SSH (PuTTY), набрать команду 'passwd root' (и/или 'passwd admin').
Чтобы дополнительно добавить пользователя для доступа к диску по сети, нужно добавить его сначала как пользователя
системы командой "adduser <имя>", затем добавить его в пользователи самбы: smbpasswd <имя>.

    Веб-интерфейс bittorrent-клиента 'Transmission' доступен по адресу http://<ip-адрес-MBL>:9091/transmission/web/
Для старта закачки достаточно через samba загрузить torrent-файл в папку /DataVolume/Public/watch-dir/transmission.
Закачка начнётся автоматически, файл будет загружен в /DataVolume/Download.

    Firewall (межсетевой экран) в прошивке отключен. 

    Если при ssh-подключении через PuTTY (в среде Windows) у вас неправильно отображается псевдо-графика, задайте
в настройках сессии PuTTY в 'Connection' -> 'Data' -> 'Terminal-type string' значение 'putty-256color'.

--- Известные проблемы:

    - Система/Точки монтирования (System/Mount Points): при исполнении "Сохранить и применить" ("Save and Apply")
происходит зависание веб-интерфейса. При этом доступ по SSH сохраняется. Все изменения, которые вы совершили
в этом разделе, тоже сохраняются. После установки прошивки нет необходимости что-либо изменять в этом разделе.
По умолчанию там всё настроено для нормальной работы.
Если же вам нужно внести измененения, после "Сохранить и применить" просто перезагрузите устройство командой
"reboot" в терминале или по питанию. Ваши изменения при этом будут сохранены.

--- Особенности прошивки:

v1.01 (2017-04-05)

    - собрана на основе платформы LEDE-17.01.0-stable-r3205
    - linux-ядро v4.4.50, собрано с PageSize=4K, поддержкой AHCI, AIO, Direct-I/O, CIFS (+SMB3), NFS (+v4.2);
	* Параметр PageSize=4K обеспечивает оптимальное использование памяти, одновременно делает невозможным
	  доступ к данным на разделе /DataVolume, оставшемся после использования оригинальной прошивки
	  MyBook Live от WD и её debian-клонов;
    - размер блока файловой системы раздела данных *) bs=4K, RAID не используется, размер раздела rootfs = 4Gb.
	* Этот параметр обеспечмвает максимальную совместимость фацловой системы с большинством десктоп-компьютeров,
	  также обеспечивает оптимальный расход дисковой памяти, особенно при наличии большого числа небольших файлов,
	  но при этом производительность файловой системы ниже, чем у оригинала от WD, где используется bs=64K;
    - русскоязычный веб-интерфейс;
    - 5 скинов для веб-интерфейса;
    - возможность установки/удаления пакетов через веб-интерфейс;
    - функционал power-save (засыпание/пробуждение диска);
    - настракваемые режимы работы led-светодиодов устройства;
    - отображение графиков загрузки системы в режиме реального времени. 

    Предустановлено и настроено:

    - bittorrent-клиент Transmission v2.92;
    - DLNA медиа-сервер Minidlna v1.1.5;
    - сетевой файл-сервер Samba v3.6;
    - файловый менеджер Midnight Commander v4.8.18 (256 color).
