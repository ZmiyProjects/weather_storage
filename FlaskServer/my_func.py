from flask import jsonify
import json
from sqlalchemy import sql
import sys


def check_json(true_keys: list, values: list) -> bool:
    """Проверка строгого соответствия JSON структуры нужному формату"""
    for i in values:
        if len(true_keys) != len(i.keys()):
            return False
        if not all([j in true_keys for j in i.keys()]):
            return False
    return True


def check_json_in(true_keys: list, values: dict) -> bool:
    """Проверка соответствия JSON структуры формату при условии, что некоторые ключи могут отсутствовать"""
    if len(true_keys) < len(values.keys()) or values == {}:
        return False
    if not all([j in true_keys for j in values.keys()]):
        return False
    return True


def simple_get_values(engine, query: sql.text, **kwargs):
    values = engine.execute(query, kwargs).fetchall()
    if values[0][0] is None:
        return jsonify('Неверный идентификатор!'), 400
    result = "".join([i[0] for i in engine.execute(query, kwargs).fetchall()])
    return jsonify(json.loads(result)), 200


def simple_import_values(engine, query, **kwargs):
    try:
        with engine.begin() as conn:
            conn.execute(query, kwargs)
        return True
    except:
        print(sys.exc_info()[0])
        return False


# функция для отправки запросов на обновление/удаление записей
def simple_change(engine, query, **kwargs):
    with engine.begin() as conn:
        conn.execute(query, kwargs)