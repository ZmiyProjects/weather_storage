from flask import Flask, request, jsonify, Response
from sqlalchemy import create_engine, sql
import sys
import json
from datetime import datetime


from my_func import *

app = Flask(__name__)
app.config.from_object('config.MSSQLConfig')
db = create_engine(app.config['DATABASE_URI'])


@app.route('/static/wind_direction', methods=['GET'])
def get_wind_direction():
    query = sql.text('SELECT Static.get_cloudiness_json()')
    return simple_get_values(db, query)


@app.route('/static/cloudiness', methods=['GET'])
def get_cloudiness():
    query = sql.text('SELECT Static.get_wind_direction_json()')
    return simple_get_values(db, query)


# Загрузка/извлечение сведений по всем известным странам
@app.route('/country', methods=['POST', 'GET'])
def all_countries():
    if request.method == 'POST':
        struct = json.dumps(request.json)
        query = sql.text("EXEC Import.insert_country_json :json")
        with db.begin() as conn:
            conn.execute(query, json=struct)
        return {}, 201
    elif request.method == 'GET':
        query = sql.text('SELECT Import.country_json()')
        result = "".join([i[0] for i in db.execute(query).fetchall()])
        return jsonify(json.loads(result)), 200


# Получение/обновление/удаление сведений по конкретной стране
@app.route('/country/<int:country_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_country(country_id):
    if request.method == 'GET':
        query = sql.text('SELECT Import.one_country_json(:id)')
        result = db.execute(query, id=country_id).fetchone()[0]
        if result is None:
            return jsonify(message='Страна с указанным идентификатором не существует!'), 400
        return jsonify(*json.loads(result)), 200
    elif request.method == 'DELETE':
        del_query = sql.text('EXEC Import.delete_country :id')
        try:
            simple_change(db, del_query, id=country_id)
            return {}, 204
        except:
            print(sys.exc_info())
            return {}, 400
    elif request.method == 'PATCH':
        upd_query = sql.text('EXEC Import.update_country :json, :id')
        new_value = sql.text('SELECT Import.one_country_json(:id)')
        try:
            simple_change(db, upd_query, json=json.dumps(request.get_json()), id=country_id)
            return simple_get_values(db, new_value, id=country_id)
        except:
            print(sys.exc_info())
            return {}, 400


# Загрузка/извлечение данных о регионах в рамках определенной страны
@app.route('/country/<int:country_id>/region', methods=['POST', 'GET'])
def all_regions(country_id):
    if request.method == 'POST':
        struct = request.get_json()
        query = sql.text('EXEC Import.insert_region_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=country_id):
            return {}, 201
        return jsonify(message='exception!'), 400
    elif request.method == 'GET':
        query = sql.text('SELECT Import.region_json()')
        return simple_get_values(db, query, id=country_id)


# Получение/обновление/удаление сведений по конкретному региону
@app.route('/region/<int:region_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_region(region_id):
    if request.method == 'GET':
        query = sql.text('SELECT Import.one_region_json(:id)')
        result = db.execute(query, id=region_id).fetchone()[0]
        if result is None:
            return jsonify(message='Регион с указанным идентификатором не существует!'), 404
        return jsonify(*json.loads(result)), 200
    elif request.method == 'DELETE':
        del_query = sql.text('EXEC Import.delete_region :id')
        try:
            simple_change(db, del_query, id=region_id)
            return {}, 204
        except:
            print(sys.exc_info())
            return {}, 400
    elif request.method == 'PATCH':
        upd_query = sql.text('EXEC Import.update_region :json, :id')
        new_value = sql.text('SELECT Import.one_region_json(:id)')
        try:
            simple_change(db, upd_query, json=json.dumps(request.get_json()), id=region_id)
            return simple_get_values(db, new_value, id=region_id)
        except:
            print(sys.exc_info())
            return {}, 400


# Загрузка/извлечение данных о населенных пунктах в рамках определенной страны
@app.route('/region/<int:region_id>/locality', methods=['POST', 'GET'])
def all_locality(region_id):
    if request.method == 'POST':
        struct = request.json
        query = sql.text('EXEC Import.insert_locality_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=region_id):
            return {}, 201
        return jsonify(message='exception!'), 400
    elif request.method == 'GET':
        query = sql.text('SELECT Import.locality_json()')
        return simple_get_values(db, query, id=region_id)


# Получение/обновление/удаление сведений по конкретному населённому пункту
@app.route('/locality/<int:locality_id>', methods=['POST', 'PATCH', 'DELETE'])
def get_locality(locality_id):
    if request.method == 'GET':
        query = sql.text('SELECT Import.one_locality_json(:id)')
        result = db.execute(query, id=locality_id).fetchone()[0]
        if result is None:
            return jsonify(message='Населённый пункт с указанным идентификатором не существует!'), 404
        return jsonify(*json.loads(result)), 200
    elif request.method == 'DELETE':
        del_query = sql.text('EXEC Import.delete_locality :id')
        try:
            simple_change(db, del_query, id=locality_id)
            return {}, 204
        except:
            print(sys.exc_info())
            return {}, 400
    elif request.method == 'PATCH':
        upd_query = sql.text('EXEC Import.update_locality :json, :id')
        new_value = sql.text('SELECT Import.one_locality_json(:id)')
        try:
            simple_change(db, upd_query, json=json.dumps(request.get_json()), id=locality_id)
            return simple_get_values(db, new_value, id=locality_id)
        except:
            print(sys.exc_info())
            return {}, 400


# Загрузка/извлечение данных о всех обслуживающих метеостанции организациях
@app.route('/organization', methods=['POST', 'GET'])
def all_organizations():
    if request.method == 'POST':
        struct = request.json
        query = sql.text('EXEC Import.insert_organization_json :json')
        print(struct)
        if simple_import_values(db, query, json=json.dumps(struct)):
            return {}, 201
        return {}, 400
    elif request.method == 'GET':
        query = sql.text('SELECT Import.organization_json()')
        return simple_get_values(db, query)


# Получение/обновление/удаление сведений о конкретной организации
@app.route('/organization/<int:organization_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_organization(organization_id):
    if request.method == 'GET':
        query = sql.text('SELECT Import.one_organization_json(:id)')
        return simple_get_values(db, query, id=organization_id)
    elif request.method == 'DELETE':
        del_query = sql.text('EXEC Import.delete_organization :id')
        try:
            simple_change(db, del_query, id=organization_id)
            return {}, 204
        except:
            print(sys.exc_info())
            return {}, 400
    elif request.method == 'PATCH':
        upd_query = sql.text('EXEC Import.update_organization :json, :id')
        new_value = sql.text('SELECT Import.one_organization_json(:id)')
        try:
            simple_change(db, upd_query, json=json.dumps(request.get_json()), id=organization_id)
            return simple_get_values(db, new_value, id=organization_id)
        except:
            print(sys.exc_info())
            return {}, 400


@app.route('/station', methods=['GET', 'POST'])
def stations():
    if request.method == 'POST':
        struct = request.json
        query = sql.text('EXEC Import.insert_station_json :json')
        if simple_import_values(db, query, json=json.dumps(struct)):
            return {}, 201
    if request.method == 'GET':
        query = sql.text('SELECT Import.station_json()')
        return simple_get_values(db, query)


@app.route('/station/<int:station_id>', methods=['GET', 'PATCH', 'DELETE'])
def one_station(station_id):
    if request.method == 'GET':
        query = sql.text('SELECT Import.one_station_json(:id)')
        result = db.execute(query, id=station_id).fetchone()[0]
        if result is None:
            return jsonify(message='Регион с указанным идентификатором не существует!'), 400
        return jsonify(*json.loads(result)), 200
    elif request.method == 'DELETE':
        del_query = sql.text('EXEC Import.delete_station :id')
        try:
            simple_change(db, del_query, id=station_id)
            return {}, 204
        except:
            print(sys.exc_info())
            return {}, 400
    elif request.method == 'PATCH':
        upd_query = sql.text('EXEC Import.update_station :json, :id')
        new_value = sql.text('SELECT Import.one_station_json(:id)')
        try:
            simple_change(db, upd_query, json=json.dumps(request.get_json()), id=station_id)
            return simple_get_values(db, new_value, id=station_id)
        except:
            print(sys.exc_info())
            return {}, 400


# Регистрация поступающих с метеостанции данных
@app.route('/station/<int:station_id>/registration', methods=['POST', 'GET'])
def registration(station_id):
    if request.method == 'POST':
        struct = request.get_json()
        query = sql.text('EXEC Import.insert_registration_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=station_id):
            return {}, 201
    if request.method == 'GET':
        d_begin = request.args.get('begin')
        d_end = request.args.get('end')
        data_type = request.args.get('type', 'json')
        if d_begin is None or d_end is None:
            if data_type == 'json':
                query = sql.text('SELECT Import.registration_json(:id);')
                return simple_get_values(db, query, id=station_id)
            elif data_type == 'xml':
                query = sql.text('SELECT Import.registration_xml(:id)')
                result = "".join([i[0] for i in db.execute(query, id=station_id).fetchall()])
                return Response(result, mimetype='text/xml')
            else:
                return {}, 400
        else:
            try:
                if datetime.strptime(d_end, '%Y%m%d') <= datetime.strptime(d_begin, '%Y%m%d'):
                    return jsonify(message='Некорректный диапозон дат!'), 400
                if data_type == 'json':
                    query = sql.text('SELECT Import.registration_diapason_json(:id, :begin, :end);')
                    return simple_get_values(db, query, id=station_id, begin=d_begin, end=d_end)
                elif data_type == 'xml':
                    query = sql.text('SELECT Import.registration_diapason_xml(:id, :begin, :end);')
                    result = "".join([i[0] for i in db.execute(query, id=station_id, begin=d_begin, end=d_end).fetchall()])
                    return Response(result, mimetype='text/xml')
                else:
                    return {}, 400
            except ValueError:
                print(sys.exc_info())
                return jsonify(message='Некорректный диапозон дат!'), 400


@app.route('/station/<int:station_id>/agg', methods=['GET'])
def agg_months(station_id):
    diapason = request.args.get('diapason')
    if diapason is None or diapason not in ['months', 'weeks', 'days', 'hours12', 'hours6']:
        return {}, 400
    d_begin = request.args.get('begin')
    d_end = request.args.get('end')
    if d_begin is None or d_end is None:
        query = sql.text(f'SELECT agg.{diapason}_json(:id);')
        return simple_get_values(db, query, id=station_id)
    else:
        try:
            if datetime.strptime(d_end, '%Y%m%d') <= datetime.strptime(d_begin, '%Y%m%d'):
                return jsonify(message='Некорректный диапозон дат!'), 400
            query = sql.text(f'SELECT agg.{diapason}_json_diapason(:id, :begin, :end);')
            return simple_get_values(db, query, id=station_id, begin=d_begin, end=d_end)
        except ValueError:
            print(sys.exc_info())
            return jsonify(message='Некорректный диапозон дат!'), 400


if __name__ == '__main__':
    app.run()
