#!/bin/bash

# Скрипт для установки копии веб-сервиса

# $1 - путь к директории, в которую осуществляется установка (обязательный аргумент)
# $2 - количество обработчиков (workers), по умолчанию количество ядер/потоков CPU*2+1 (необязательный аргумент)
# $3 - ip и порт, на которых будет запускаться приложение, по умолчанию 0.0.0.0:8080 (необязательный аргумент)

# Проверка количества аргументов
(( $# >= 1 && $# <= 3 )) || { echo "Недопустимое количество аргументов!"; exit 1; }

# Проверка наличия уже установленной копии ПО
# с данной целью осуществляется проверка наличия файла /etc/systemd/system/yandex.service (unit - файл  для gunicorn)
# если подтверждается наличие unit-файла установка прерывается
if [[ -f /etc/systemd/system/weather.service ]]; then
    echo 'Приложение уже установлено! Если вам требуется переустановить приложение предварительно удалите текущую копию запустив uninstall.sh, находящийся в папке с установленной копией'
    echo 'затем повторно запустите установщик'
    exit 1
fi

host_var='0.0.0.0:8080' # ip адрес и порт, используемые для доступа к сервису
let "workers=$(grep -c ^processor /proc/cpuinfo)*2+1" # Вычисление количества обработчиков (workers) для gunicorn, по умолчанию используется рекомендованная формула ядра_CPU*2+1
python_re='Python 3.[67][0-9.]*$' # Шаблон для регулярного выражения, проверяющего соответствие используемого интерпритатора Python требуемым версиям ( 3.6+ )
version_code=0

# Проверка корректности первого аргумента
if ! [ -d $(dirname $1) ]; then
    echo 'Указан недостижимый путь к целевой дректории!'
    exit 1
  elif [ -d $1 ]; then
    echo 'Целевая директория уже существует!'
    exit 1
fi

# Проверка наличия необходимой версии python на основании шаблона python_re.
if [[ $(python --version) =~ $python_re ]]; then
    let "version_code=1"
  elif [[ $(python3 --version) =~ $python_re ]]; then
      let "version_code=2"
  else
     echo 'Необходимая версия Python не установлена!'
     exit 1
fi

# Проверка наличия второго аргумента (workers)
# Количество обработчиков, при пользовательской настройке должно быть не менее 3 и не более рекомендованного количества для процессора.
if [ -n "$2" ]; then
  if (( $2 >= 3 && $2 <= $workers )); then
     workers=$2
    else
      echo "Указано недопустимое число обработчиков(workers)!"
      exit 1
  fi
fi

# Проверка наличия третьего аргумента (ip и порт), корректность заданного ip не проверяется
if [ -n "$3" ]; then
    host_var=$3
fi

# Создание БД для REST API веб сервиса
sqlcmd -U SA -i $(dirname $0)/MSSQL/Weather.sql

# Создание виртуального окружения и
# Копирование библиотечных файла и кода проекта

mkdir $1
cp $(dirname $0)/FlaskServer/ $1 -r

if (( $version_code == 1  )); then
    python -m venv $1/weathervenv
  elif (( $version_code == 2 )); then
      python3 -m venv $1/weathervenv
fi

# Активация виртуального окружения python для установки необходимых python-пакетов.
source $1/weathervenv/bin/activate

# установка в виртуальную среду пакетов, необходимых для работы приложения
pip install -r $(dirname $0)/FlaskServer/requerements.txt

# Генерация Unit-файла для gunicorn по шаблону
sed -e "s!PROJECT_WORKERS!$workers!;  s!PROJECT_PATH!$1!g; s/USER_NAME/$USER/; s/PROJECT_HOST/$host_var/" weatherunit.service > $(dirname $0)/weather.service

# Перемешение Unit файла в /etc/systemd/system/
sudo mv $(dirname $0)/weather.service /etc/systemd/system/
sudo systemctl daemon-reload

cp $(dirname $0)/commander.sh $1

# Предоставление осуществляющему установку пользователю прав на запуск скриптов, инкапсулирующих базовые операции управления приложением.
chmod u+x $1/commander.sh

