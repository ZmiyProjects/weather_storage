from flask import Flask, request, jsonify
from sqlalchemy import create_engine, sql
import sys
import json


from my_func import *

app = Flask(__name__)
app.config.from_object('config.MSSQLConfig')
db = create_engine(app.config['DATABASE_URI'])


@app.route('/static/wind_direction', methods=['GET'])
def get_wind_direction():
    query = sql.text(
        'SELECT WD.WindDirectionId, WD.Direction, WD.Mark FROM Import.get_all_wind_direction() AS WD FOR JSON PATH')
    result = "".join(i[0] for i in db.execute(query).fetchall())
    return jsonify(json.loads(result)), 200


@app.route('/static/cloudiness', methods=['GET'])
def get_cloudiness():
    query = sql.text(
        'SELECT C.CloudinessId, C.CloudinessLevel, C.Octane FROM Import.get_all_cloudiness() AS C FOR JSON PATH')
    result = "".join([i[0] for i in db.execute(query).fetchall()])
    return jsonify(json.loads(result)), 200


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
        query = sql.text('SELECT * FROM Import.Country FOR JSON PATH;')
        result = "".join([i[0] for i in db.execute(query).fetchall()])
        return jsonify(json.loads(result)), 200


# Получение/обновление/удаление сведений по конкретной стране
@app.route('/country/<int:country_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_country(country_id):
    if request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Country WHERE CountryId = :id FOR JSON PATH')
        return simple_get_values(db, query, id=country_id)


# Загрузка/извлечение данных о регионах в рамках определенной страны
@app.route('/country/<int:country_id>/region', methods=['POST', 'GET'])
def all_regions(country_id):
    if request.method == 'POST':
        struct = request.json
        # if struct is None or not check_json(['RegionName'], struct):
        #    return jsonify(message='JSON!'), 404
        query = sql.text('EXEC Import.insert_region_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=country_id):
            return {}, 201
        return jsonify(message='exception!'), 404
    elif request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Region WHERE CountryId = :id FOR JSON PATH')
        return simple_get_values(db, query, id=country_id)


# Получение/обновление/удаление сведений по конкретному региону
@app.route('/region/<int:region_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_region(region_id):
    if request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Region WHERE RegionId = :id FOR JSON PATH')
        return simple_get_values(db, query, id=region_id)


# Загрузка/извлечение данных о населенных пунктах в рамках определенной страны
@app.route('/region/<int:region_id>/locality', methods=['POST', 'GET'])
def all_locality(region_id):
    if request.method == 'POST':
        struct = request.json
        # if struct is None or not check_json(['LocalityName'], struct):
        #    return jsonify(message='Некорректный JSON!'), 404
        query = sql.text('EXEC Import.insert_locality_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=region_id):
            return {}, 201
        return jsonify(message='exception!'), 404
    elif request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Region WHERE RegionId = :id FOR JSON PATH')
        return simple_get_values(db, query, id=region_id)


# Получение/обновление/удаление сведений по конкретному населённому пункту
@app.route('/locality/<int:locality_id>', methods=['POST', 'PATCH', 'DELETE'])
def get_locality(locality_id):
    pass


# Загрузка/извлечение данных о всех обслуживающих метеостанции организациях
@app.route('/organization', methods=['POST', 'GET'])
def all_organizations():
    if request.method == 'POST':
        struct = request.json
        query = sql.text('EXEC Import.insert_organization_json :json')
        if simple_import_values(db, query, json=json.dumps(struct)):
            return {}, 201


# Получение/обновление/удаление сведений о конкретной организации
@app.route('/organization/<int:organization_id>', methods=['GET', 'PATCH', 'DELETE'])
def get_organization(organization_id):
    if request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Organization WHERE OrganizationId = :id FOR JSON PATH')
        return simple_get_values(db, query, id=organization_id)


@app.route('/station', methods=['GET', 'POST'])
def stations():
    if request.method == 'POST':
        struct = request.json
        query = sql.text('EXEC Import.insert_station_json :json')
        if simple_import_values(db, query, json=json.dumps(struct)):
            return {}, 201
    if request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Station FOR JSON PATH')
        return simple_get_values(db, query)


@app.route('/station/<int:station_id>', methods=['GET', 'PATCH', 'DELETE'])
def one_station(station_id):
    select_query = sql.text("SELECT Import.get_one_station(:id)")
    if request.method == 'GET':
        result = db.execute(select_query, id=station_id).fetchone()
        return jsonify(json.loads(*result)), 200
    if request.method == 'PATCH':
        struct = request.json
        if struct is None or not check_json_in(['StationName', 'Latitude', 'Longitude', 'WMOIndex', 'Height'], struct):
            return jsonify(message="Некорректный JSON формат"), 404
        columns = ",".join([f"{i}='{j}'" for i, j in struct.items()])
        query = sql.text("UPDATE Import.Station SET " + columns + " WHERE StationId = :id")
        with db.begin() as conn:
            conn.execute(query, id=station_id)
        result = db.execute(select_query, id=station_id).fetchone()
        return jsonify(json.loads(*result)), 200
    if request.method == 'DELETE':
        query = sql.text("DELETE FROM Import.Station WHERE StationId = :id")
        with db.begin() as conn:
            conn.execute(query, id=station_id)
        return {}, 204


# Регистрация поступающих с метеостанции данных
@app.route('/station/<int:station_id>/registration', methods=['POST', 'GET'])
def registration(station_id):
    if request.method == 'POST':
        struct = request.get_json()
        query = sql.text('EXEC Import.insert_registration_json :json, :id')
        if simple_import_values(db, query, json=json.dumps(struct), id=station_id):
            return {}, 201
    if request.method == 'GET':
        query = sql.text('SELECT * FROM Import.Registration WHERE StationId = :id FOR JSON PATH;')
        return simple_get_values(db, query, id=station_id)


if __name__ == '__main__':
    app.run()
