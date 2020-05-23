from werkzeug.security import check_password_hash

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


class UserData:
    @staticmethod
    def _connection(engine, query, **kwargs):
        try:
            with engine.begin() as conn:
                conn.execute(query, kwargs)
            return True
        except:
            print(sys.exc_info())
            return False

    @staticmethod
    def insert(engine, **kwargs):
        query = sql.text('CALL web.insert_user(:user_login, :password, :role_id)')
        if UserData._connection(engine, query, **kwargs):
            return {}, 201
        return {}, 400

    @staticmethod
    # Возвращает объект Responce при использовании имеющихся функций, почему?
    def update(engine, **kwargs):
        query = sql.text('CALL web.update_user_json(:json, :id)')
        if UserData._connection(engine, query, **kwargs):
            return UserData.get_one(engine, kwargs['id'])
        return {}, 400

    @staticmethod
    def delete(engine, **kwargs):
        query = sql.text('CALL web.delete_user(:id)')
        if UserData._connection(engine, query, **kwargs):
            return {}, 204
        return {}, 400

    @staticmethod
    def check_password(engine, username, password):
        query = sql.text('SELECT web.check_password(:username)')
        password_hash = engine.execute(query, username=username).scalar()
        if password_hash is None:
            return False
        return check_password_hash(password_hash, password)

    @staticmethod
    def get_role(engine, username):
        query = sql.text('SELECT web.init_user(:username);')
        return engine.execute(query, username=username).scalar()

    @staticmethod
    def get_all(engine):
        query = sql.text('SELECT web.users_json()')
        return simple_get_set_values(engine, query)

    @staticmethod
    def get_one(engine, user_id):
        query = sql.text('SELECT web.one_user_json(:id)')
        return simple_get_values(engine, query, id=user_id)

    @staticmethod
    def get_roles(engine):
        query = sql.text('SELECT web.roles_json()')
        return simple_get_set_values(engine, query)
