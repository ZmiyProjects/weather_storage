import sys
from sqlalchemy import sql
from my_func import simple_get_values
from flask import jsonify


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
        query = sql.text('EXEC web.insert_user :UserLogin, :Password, :RoleId')
        if UserData._connection(engine, query, **kwargs):
            return {}, 201
        return {}, 400

    @staticmethod
    # Возвращает объект Responce при использовании имеющихся функций, почему?
    def update(engine, **kwargs):
        query = sql.text('EXEC web.update_user_json :json, :id')
        if UserData._connection(engine, query, **kwargs):
            return UserData.get_one(engine, kwargs['id'])
        return {}, 400

    @staticmethod
    def delete(engine, **kwargs):
        query = sql.text('EXEC web.delete_user :id')
        if UserData._connection(engine, query, **kwargs):
            return {}, 204
        return {}, 400

    @staticmethod
    def check_password(engine, username, password):
        query = sql.text('SELECT web.check_password(:username, :password)')
        if engine.execute(query, username=username, password=password).fetchone()[0]:
            return True
        return False

    @staticmethod
    def get_role(engine, username):
        query = sql.text('SELECT web.init_user(:username);')
        return engine.execute(query, username=username).fetchone()[0]

    @staticmethod
    def get_all(engine):
        query = sql.text('SELECT web.users_json()')
        return simple_get_values(engine, query)

    @staticmethod
    def get_one(engine, user_id):
        query = sql.text('SELECT web.one_user_json(:id)')
        return simple_get_values(engine, query, id=user_id)

    @staticmethod
    def get_roles(engine):
        query = sql.text('SELECT web.roles_json()')
        return simple_get_values(engine, query)