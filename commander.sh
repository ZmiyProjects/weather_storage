#!/bin/bash


if [ $1 == "start" ]; then
    sudo systemctl start weather.service
    sudo systemctl enable weather.service
elif [ $1 == "stop" ]; then
    sudo systemctl stop weather.service
    sudo systemctl disable weather.service
elif [ $1 == "status" ]; then
    sudo systemctl status weather.service
elif [ $1 == "uninstall" ]; then
# Удаление приложения и всех его файлов, в том числе базы данных и пользователя для работы с БД.
# При этом директория, в которую установлено приложение не удаляется.

# Проверяется  запущен ли в настоящий момент веб-сервис, удаление запущенного веб-сервиса не допускается.
    if [[ -n "$($(dirname $0)/commander.sh status | grep -o running)" ]]; then
        echo 'Удаление работающего веб-сервиса не допускается!'
        echo 'Для удаление ПО предварительно остановите его работу, запустив скрипт stop, находящийся в директорией с установленной копией.'
        echo 'Затем перезапустите операцию удаления.'
        exit 1
    fi
# Удаление Unit - файла для gunicorn
    sudo rm /etc/systemd/system/weather.service
    sudo systemctl daemon-reload
# Удаление всех файлов, находящихся в директории, куда был установлена копия данного ПО. Сама директория не удаляется.
    rm -R $(dirname $0)/*
else
    echo "Недопустимая команда!"
    exit 1
fi

