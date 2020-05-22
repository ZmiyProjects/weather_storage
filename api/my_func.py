from flask import jsonify
from sqlalchemy import sql
import sys


def simple_get_values(engine, query: sql.text, **kwargs):
    values = engine.execute(query, kwargs).scalar()
    if values is None:
        return jsonify('Неверный идентификатор!'), 400
    return jsonify(values), 200


def simple_get_set_values(engine, query: sql.text, **kwargs):
    return jsonify([i[0] for i in engine.execute(query, kwargs).fetchall()]), 200


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
