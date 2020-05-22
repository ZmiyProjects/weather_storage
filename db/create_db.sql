
CREATE DATABASE test_1;
\connect test_1;


-- Создание схем
CREATE SCHEMA Import;

CREATE SCHEMA Static;

CREATE SCHEMA Agg;

CREATE SCHEMA Auth;

-- схема Web предназначена в качестве пространства имен для функций/процедур вызываемых со стороны веб-сервиса
CREATE SCHEMA Web;

CREATE TABLE Auth.RoleData(
    role_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Auth.UserData(
    user_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_login VARCHAR(30) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role_id INT NOT NULL REFERENCES Auth.RoleData(role_id)
);

-- Создание таблиц "только для чтения" в схеме Static
CREATE TABLE Static.WindDirection(
    wind_direction_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    direction VARCHAR(100) UNIQUE NOT NULL,
    mark VARCHAR(5) UNIQUE NOT NULL
);

CREATE TABLE Static.Cloudiness(
    cloudiness_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    cloudiness_level VARCHAR(100) NOT NULL UNIQUE,
    octane VARCHAR(50) NOT NULL UNIQUE
);

-- Создание таблиц в схеме Import
-- Возможо, стоит сделать "справочные" таблицы темпоральными

-- TotalArea - сумма LandArea и WaterArea
CREATE TABLE Import.Country(
    country_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    country_name VARCHAR(100) UNIQUE NOT NULL,
    land_area INT NOT NULL,
    water_area INT NOT NULL,
    total_area INT NULL
);

CREATE TABLE Import.Region(
    region_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    region_name VARCHAR(100) UNIQUE NOT NULL,
    country_id INT NOT NULL REFERENCES Import.Country(country_id)
);

CREATE TABLE Import.Locality(
    locality_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    locality_name VARCHAR(100) UNIQUE NOT NULL,
    region_id INT NOT NULL REFERENCES Import.Region(region_id)
);

CREATE TABLE Import.Organization(
    organization_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    organization_name VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL,
    web_site VARCHAR(255) NULL,
    locality_id INT NOT NULL REFERENCES Import.Locality(locality_id),
    parent_organization_id INT REFERENCES Import.Organization(organization_id)
);

CREATE TABLE Import.Station(
    station_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    station_name VARCHAR(255) UNIQUE NOT NULL,
    latitude NUMERIC(5, 2) NOT NULL,
    longitude NUMERIC(5, 2) NOT NULL,
    height SMALLINT NOT NULL,
    region_id INT NOT NULL REFERENCES Import.Region(region_id),
    organization_id INT NOT NULL REFERENCES Import.Organization(organization_id),
    CONSTRAINT CK_Latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT CK_Longitude CHECK (longitude BETWEEN -180 AND 180)
);

CREATE TABLE Import.Registration(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date TIMESTAMP NOT NULL,
    temperature NUMERIC(5, 2) NOT NULL,
    dew_point NUMERIC(5, 2) NOT NULL,
    pressure NUMERIC(6, 2) NOT NULL,
    pressure_station_level NUMERIC(6, 2) NOT NULL,
    humidity NUMERIC(5, 2) NOT NULL,
    visible_range NUMERIC(6, 2) NOT NULL,
    wind_speed NUMERIC(5, 2) NOT NULL,
    weather VARCHAR(255) NOT NULL,
    wind_direction_id INT REFERENCES Static.WindDirection(wind_direction_id),
    cloudiness_id INT REFERENCES Static.Cloudiness(cloudiness_id),
    CONSTRAINT PK_Registration PRIMARY KEY(station_id, registration_date),
    CONSTRAINT CK_Temperature CHECK (temperature BETWEEN -60 AND 60),
    CONSTRAINT CK_DewPoint CHECK (dew_point BETWEEN -60 AND 60),
    CONSTRAINT CK_Pressure CHECK (pressure BETWEEN 0 AND 1000),
    CONSTRAINT CK_PressureStationLevel CHECK (pressure_station_level BETWEEN 0 AND 1000),
    CONSTRAINT CK_Humidity CHECK (humidity BETWEEN 0 AND 100),
    CONSTRAINT CK_VisibleRange CHECK (visible_range BETWEEN 0 AND 100),
    CONSTRAINT CK_WindSpeed CHECK (wind_speed BETWEEN 0 AND 50)
);

CREATE TABLE Agg.Hours6(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date TIMESTAMP,
    temperature_avg NUMERIC(5, 2) NOT NULL,
    temperature_max NUMERIC(5, 2) NOT NULL,
    temperature_min NUMERIC(5, 2) NOT NULL,
    dew_point_avg NUMERIC(5, 2) NOT NULL,
    dew_point_max NUMERIC(5, 2) NOT NULL,
    dew_point_min NUMERIC(5, 2) NOT NULL,
    pressure_avg NUMERIC(6, 2) NOT NULL,
    pressure_max NUMERIC(6, 2) NOT NULL,
    pressure_min NUMERIC(6, 2) NOT NULL,
    pressure_station_level_avg NUMERIC(6, 2) NOT NULL,
    pressure_station_level_max NUMERIC(6, 2) NOT NULL,
    pressure_station_level_min NUMERIC(6, 2) NOT NULL,
    humidity_avg NUMERIC(5, 2) NOT NULL,
    humidity_max NUMERIC(5, 2) NOT NULL,
    humidity_min NUMERIC(5, 2) NOT NULL,
    visible_range_avg NUMERIC(6, 2) NOT NULL,
    visible_range_max NUMERIC(6, 2) NOT NULL,
    visible_range_min NUMERIC(6, 2) NOT NULL,
    wind_speed_avg NUMERIC(5, 2) NOT NULL,
    wind_speed_max NUMERIC(5, 2) NOT NULL,
    wind_speed_min NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Hours6 PRIMARY KEY (station_id, registration_date)
);

CREATE TABLE Agg.Hours12(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date TIMESTAMP,
    temperature_avg NUMERIC(5, 2) NOT NULL,
    temperature_max NUMERIC(5, 2) NOT NULL,
    temperature_min NUMERIC(5, 2) NOT NULL,
    dew_point_avg NUMERIC(5, 2) NOT NULL,
    dew_point_max NUMERIC(5, 2) NOT NULL,
    dew_point_min NUMERIC(5, 2) NOT NULL,
    pressure_avg NUMERIC(6, 2) NOT NULL,
    pressure_max NUMERIC(6, 2) NOT NULL,
    pressure_min NUMERIC(6, 2) NOT NULL,
    pressure_station_level_avg NUMERIC(6, 2) NOT NULL,
    pressure_station_level_max NUMERIC(6, 2) NOT NULL,
    pressure_station_level_min NUMERIC(6, 2) NOT NULL,
    humidity_avg NUMERIC(5, 2) NOT NULL,
    humidity_max NUMERIC(5, 2) NOT NULL,
    humidity_min NUMERIC(5, 2) NOT NULL,
    visible_range_avg NUMERIC(6, 2) NOT NULL,
    visible_range_max NUMERIC(6, 2) NOT NULL,
    visible_range_min NUMERIC(6, 2) NOT NULL,
    wind_speed_avg NUMERIC(5, 2) NOT NULL,
    wind_speed_max NUMERIC(5, 2) NOT NULL,
    wind_speed_min NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Hours12 PRIMARY KEY (station_id, registration_date)
);

CREATE TABLE Agg.Days(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date DATE,
    temperature_avg NUMERIC(5, 2) NOT NULL,
    temperature_max NUMERIC(5, 2) NOT NULL,
    temperature_min NUMERIC(5, 2) NOT NULL,
    dew_point_avg NUMERIC(5, 2) NOT NULL,
    dew_point_max NUMERIC(5, 2) NOT NULL,
    dew_point_min NUMERIC(5, 2) NOT NULL,
    pressure_avg NUMERIC(6, 2) NOT NULL,
    pressure_max NUMERIC(6, 2) NOT NULL,
    pressure_min NUMERIC(6, 2) NOT NULL,
    pressure_station_level_avg NUMERIC(6, 2) NOT NULL,
    pressure_station_level_max NUMERIC(6, 2) NOT NULL,
    pressure_station_level_min NUMERIC(6, 2) NOT NULL,
    humidity_avg NUMERIC(5, 2) NOT NULL,
    humidity_max NUMERIC(5, 2) NOT NULL,
    humidity_min NUMERIC(5, 2) NOT NULL,
    visible_range_avg NUMERIC(6, 2) NOT NULL,
    visible_range_max NUMERIC(6, 2) NOT NULL,
    visible_range_min NUMERIC(6, 2) NOT NULL,
    wind_speed_avg NUMERIC(5, 2) NOT NULL,
    wind_speed_max NUMERIC(5, 2) NOT NULL,
    wind_speed_min NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Days PRIMARY KEY (station_id, registration_date)
);

CREATE TABLE Agg.Weeks(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date DATE,
    temperature_avg NUMERIC(5, 2) NOT NULL,
    temperature_max NUMERIC(5, 2) NOT NULL,
    temperature_min NUMERIC(5, 2) NOT NULL,
    dew_point_avg NUMERIC(5, 2) NOT NULL,
    dew_point_max NUMERIC(5, 2) NOT NULL,
    dew_point_min NUMERIC(5, 2) NOT NULL,
    pressure_avg NUMERIC(6, 2) NOT NULL,
    pressure_max NUMERIC(6, 2) NOT NULL,
    pressure_min NUMERIC(6, 2) NOT NULL,
    pressure_station_level_avg NUMERIC(6, 2) NOT NULL,
    pressure_station_level_max NUMERIC(6, 2) NOT NULL,
    pressure_station_level_min NUMERIC(6, 2) NOT NULL,
    humidity_avg NUMERIC(5, 2) NOT NULL,
    humidity_max NUMERIC(5, 2) NOT NULL,
    humidity_min NUMERIC(5, 2) NOT NULL,
    visible_range_avg NUMERIC(6, 2) NOT NULL,
    visible_range_max NUMERIC(6, 2) NOT NULL,
    visible_range_min NUMERIC(6, 2) NOT NULL,
    wind_speed_avg NUMERIC(5, 2) NOT NULL,
    wind_speed_max NUMERIC(5, 2) NOT NULL,
    wind_speed_min NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Weeks PRIMARY KEY (station_id, registration_date)
);

CREATE TABLE Agg.Months(
    station_id INT REFERENCES Import.Station(station_id),
    registration_date DATE,
    temperature_avg NUMERIC(5, 2) NOT NULL,
    temperature_max NUMERIC(5, 2) NOT NULL,
    temperature_min NUMERIC(5, 2) NOT NULL,
    dew_point_avg NUMERIC(5, 2) NOT NULL,
    dew_point_max NUMERIC(5, 2) NOT NULL,
    dew_point_min NUMERIC(5, 2) NOT NULL,
    pressure_avg NUMERIC(6, 2) NOT NULL,
    pressure_max NUMERIC(6, 2) NOT NULL,
    pressure_min NUMERIC(6, 2) NOT NULL,
    pressure_station_level_avg NUMERIC(6, 2) NOT NULL,
    pressure_station_level_max NUMERIC(6, 2) NOT NULL,
    pressure_station_level_min NUMERIC(6, 2) NOT NULL,
    humidity_avg NUMERIC(5, 2) NOT NULL,
    humidity_max NUMERIC(5, 2) NOT NULL,
    humidity_min NUMERIC(5, 2) NOT NULL,
    visible_range_avg NUMERIC(6, 2) NOT NULL,
    visible_range_max NUMERIC(6, 2) NOT NULL,
    visible_range_min NUMERIC(6, 2) NOT NULL,
    wind_speed_avg NUMERIC(5, 2) NOT NULL,
    wind_speed_max NUMERIC(5, 2) NOT NULL,
    wind_speed_min NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Months PRIMARY KEY (station_id, registration_date)
);

-- Создание пользователей и ролей уровля базы данных
CREATE ROLE WeatherModerator;
CREATE ROLE WeatherCustomer;

-- Роль для работы от имени веб-сервиса
CREATE ROLE WebUser;

-- Создание пользователей и ограничение доступа
CREATE USER weather_user WITH PASSWORD 'WeatherUser1';
CREATE USER weather_moderator WITH PASSWORD 'WeatherUser1';
CREATE USER weather_customer WITH PASSWORD 'WeatherUser1';

GRANT WebUser TO weather_user;
GRANT WeatherModerator TO weather_moderator;
GRANT WeatherCustomer TO weather_customer;

GRANT USAGE ON SCHEMA Web TO WebUser;
GRANT USAGE ON SCHEMA Static TO WeatherCustomer;
GRANT USAGE ON SCHEMA Import TO WeatherCustomer;
GRANT USAGE ON SCHEMA Agg TO WeatherCustomer;
GRANT USAGE ON SCHEMA Static TO WeatherModerator;
GRANT USAGE ON SCHEMA Import TO WeatherModerator;
GRANT USAGE ON SCHEMA Agg TO WeatherModerator;
GRANT USAGE ON SCHEMA Auth TO WeatherModerator;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA Web TO WebUser;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA Web TO WebUser;

-- Разрешиле weather_user только чтение в рамках схемы Static, прочие операции недоступны
GRANT SELECT ON ALL TABLES IN SCHEMA Static TO WeatherModerator;

-- Разрешает WeatherModerator чтение, обновление, удаление записей а также вызов функций/процедув в рамках схемы Import
GRANT INSERT, SELECT, UPDATE, DELETE ON ALL TABLES IN SCHEMA Import TO WeatherModerator;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA Import TO WeatherModerator;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA Import TO WeatherModerator;

-- Работает
REVOKE UPDATE, DELETE ON Import.Registration FROM WeatherModerator;

-- Разрешает weather_user запись, чтение и запуск хранимых процедур в схеме Agg
GRANT INSERT, SELECT ON ALL TABLES IN SCHEMA Agg TO WeatherModerator;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA Agg TO WeatherModerator;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA Agg TO WeatherModerator;

GRANT SELECT ON ALL TABLES IN SCHEMA Static TO WeatherCustomer;
GRANT SELECT ON ALL TABLES IN SCHEMA Import TO WeatherCustomer;
GRANT SELECT ON ALL TABLES IN SCHEMA Agg TO WeatherCustomer;

CREATE OR REPLACE FUNCTION Web.users_json() RETURNS TABLE(json_values json) SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
      RETURN QUERY (
        SELECT json_build_object(
            'user_id', U.user_id,
            'user_login', U.user_login,
            'registration_date', U.registration_date,
            'role_id', R.role_id,
            'role_name', R.role_name)
        FROM Auth.UserData AS U
            JOIN Auth.RoleData R on U.Role_Id = R.Role_Id
        );
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.one_user_json(_UserId INT) RETURNS TABLE(json_values json)  SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'user_id', U.User_Id,
            'user_login', U.User_Login,
            'registration_date', U.Registration_Date,
            'role_id', R.Role_Id,
            'role_name', R.Role_Name)
        FROM Auth.UserData AS U
            JOIN Auth.RoleData AS R on U.User_Id = _UserId AND U.Role_Id = R.Role_Id
        );
    END
    $$ LANGUAGE PLpgSQL;

-- Хеширование паролей будет осуществлять python
CREATE OR REPLACE PROCEDURE Web.insert_user(_UserLogin VARCHAR(30), _Password VARCHAR(50), _RoleId INT) SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
        INSERT INTO Auth.UserData(User_Login, Password_Hash, Role_Id) VALUES (_UserLogin, _Password, _RoleId);
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.roles_json() RETURNS TABLE(json_values json)  SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
      RETURN QUERY (
        SELECT json_build_object(
               'role_id', R.Role_Id,
               'role_name', R.Role_Name,
               'role_count', COUNT(U.User_Id))
        FROM Auth.RoleData AS R
            LEFT JOIN Auth.UserData AS U on R.Role_Id = U.Role_Id
        GROUP BY R.Role_Id, R.Role_Name
        );
    END
    $$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE Web.delete_user(_UserId INT) SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE User_Id = @User_Id) THEN
            RAISE EXCEPTION 'Пользователь не существует!' USING ERRCODE = 51009;
        ELSE
            DELETE FROM Auth.UserData WHERE User_Id = _UserId;
        END IF;
    END
   $$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION Web.init_user(_UserName VARCHAR(50)) RETURNS VARCHAR(50) SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
        RETURN (
            SELECT R.Role_Name FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.Role_Id = R.Role_Id AND U.User_Login = _UserName
            );
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE PROCEDURE Web.update_user_json(_values json, _UserId INT) SECURITY DEFINER SET SEARCH_PATH = public AS
    $$
    BEGIN
    IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE User_Id = _UserId) THEN
        RAISE EXCEPTION 'Пользователь с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
    ELSE
      UPDATE Auth.UserData SET
	    User_Login = COALESCE(T.JUserLogin, user_login),
		password_hash = COALESCE(T.JPassword, password_hash),
		role_id = COALESCE(T.JRoleId, role_id)
	  FROM (
	    SELECT J.User_Login AS JUserLogin, J.Password_Hash AS JPassword, J.Role_Id As JRoleId
		FROM json_populate_recordset(NULL::Auth.UserData, _values) AS J
	  ) AS T
	  WHERE User_Id = _UserId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE Web.update_user(
    _UserId INT DEFAULT NULL,
    _NewLogin VARCHAR(30) DEFAULT NULL,
    _NewPassword VARCHAR(50) DEFAULT NULL,
    _RoleId INT DEFAULT NULL)
AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE User_Id = _UserId) THEN
            RAISE 'Пользователь не существует!' USING ERRCODE = 51009;
        ELSE
            UPDATE Auth.UserData SET
                User_Login = COALESCE(_NewLogin, User_Login),
                Password_Hash = COALESCE(_NewPassword, Password_Hash),
                Role_Id = COALESCE(_RoleId, Role_Id)
            WHERE User_Id = _UserId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.select_user(_UserId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
            SELECT json_build_object(
                   U.User_Login,
                   R.Role_Name)
            FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.Role_Id = R.Role_Id AND U.User_Id = _UserId
            );
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- На python

CREATE OR REPLACE FUNCTION Web.check_password(_UserName VARCHAR(30)) RETURNS VARCHAR(255) AS
    $$
    BEGIN
        RETURN ( SELECT Password_Hash FROM Auth.UserData WHERE User_Login = _UserName);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вставка в БД сведений о одной стране из JSON (TotalArea вычисляется во время вставки)
CREATE OR REPLACE PROCEDURE Web.insert_country_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Country(Country_Name, Land_Area, Water_Area, Total_Area)
        SELECT
            J.Country_Name,
            J.Land_Area,
            J.Water_Area,
            J.Water_Area + J.Land_Area AS TotalArea
        FROM json_populate_recordset(NULL::Import.Country, _values) AS J;
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вставка в БД сведений об одном регионе из JSON
CREATE OR REPLACE PROCEDURE Web.insert_region_json(_values json, _CountryId INT) AS
    $$
    BEGIN
       INSERT INTO Import.Region(Region_Name, Country_Id)
       SELECT
           J.Region_Name,
           _CountryId
       FROM json_populate_recordset(NULL::Import.Region, _values) AS J;
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вставка в БД сведений об одном населённом пункте из JSON
CREATE OR REPLACE PROCEDURE Web.insert_locality_json(_values json, _RegionId INT) AS
    $$
    BEGIN
        INSERT INTO Import.Locality(Locality_Name, Region_Id)
        SELECT
            J.Locality_Name,
            _RegionId
        FROM json_populate_recordset(NULL::Import.Locality, _values) AS J;
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вставить сведения о одной организации
-- Добавить проверку наличия родительской организации и бросить исключение приее отсутствии!
CREATE OR REPLACE PROCEDURE Web.insert_organization_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Organization(Organization_Name, Address, Web_Site, Locality_Id, Parent_Organization_Id)
        SELECT
            J.Organization_Name, J.Address, J.Web_Site, J.Locality_Id, J.Parent_Organization_Id
        FROM json_populate_recordset(NULL::Import.Organization, _values) AS J;
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вставить сведения об одной станциии
CREATE OR REPLACE PROCEDURE Web.insert_station_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Station(Station_Name, Latitude, Longitude, Height, Region_Id, Organization_Id)
        SELECT
            J.Station_Name, J.Latitude, J.Longitude, J.Height, J.Region_Id, J.Organization_Id
        FROM json_populate_recordset(NULL::Import.Station, _values) AS J;
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- агрегация зарегистрированных данных
CREATE PROCEDURE Web.agg_values_json(_values json, _StationId INT) AS
    $$
        BEGIN
        -- Месяцы
        INSERT INTO Agg.Months(
            Station_Id, Registration_Date, Temperature_AVG, Temperature_MAX, Temperature_MIN,
            Dew_Point_AVG, Dew_Point_MAX, Dew_Point_MIN, Pressure_AVG, Pressure_MAX, Pressure_MIN,
            Pressure_Station_Level_AVG, Pressure_Station_Level_MAX, Pressure_Station_Level_MIN, Humidity_AVG, Humidity_MAX, Humidity_MIN,
            Visible_Range_AVG, Visible_Range_MAX, Visible_Range_MIN, Wind_Speed_AVG, Wind_Speed_MAX, Wind_Speed_MIN)
        SELECT
            _StationId, MAX(CAST(R.Registration_Date AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.Dew_Point), MAX(R.Dew_Point), MIN(R.Dew_Point),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.Pressure_Station_Level), MAX(R.Pressure_Station_Level), MIN(R.Pressure_Station_Level),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.Visible_Range), MAX(R.Visible_Range), MIN(R.Visible_Range),
	        AVG(R.Wind_Speed), MAX(R.Wind_Speed), MIN(R.Wind_Speed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY R.Station_Id, EXTRACT(YEAR FROM R.Registration_Date), EXTRACT(MONTH FROM R.Registration_Date);

        -- Недели
        INSERT INTO Agg.Weeks(
            Station_Id, Registration_Date, Temperature_AVG, Temperature_MAX, Temperature_MIN,
            Dew_Point_AVG, Dew_Point_MAX, Dew_Point_MIN, Pressure_AVG, Pressure_MAX, Pressure_MIN,
            Pressure_Station_Level_AVG, Pressure_Station_Level_MAX, Pressure_Station_Level_MIN, Humidity_AVG, Humidity_MAX, Humidity_MIN,
            Visible_Range_AVG, Visible_Range_MAX, Visible_Range_MIN, Wind_Speed_AVG, Wind_Speed_MAX, Wind_Speed_MIN)
        SELECT
            _StationId, MAX(CAST(R.Registration_Date AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.Dew_Point), MAX(R.Dew_Point), MIN(R.Dew_Point),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.Pressure_Station_Level), MAX(R.Pressure_Station_Level), MIN(R.Pressure_Station_Level),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.Visible_Range), MAX(R.Visible_Range), MIN(R.Visible_Range),
	        AVG(R.Wind_Speed), MAX(R.Wind_Speed), MIN(R.Wind_Speed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.Registration_Date), EXTRACT(WEEK FROM R.Registration_Date);
        -- Дни
        INSERT INTO Agg.Days(
            Station_Id, Registration_Date, Temperature_AVG, Temperature_MAX, Temperature_MIN,
            Dew_Point_AVG, Dew_Point_MAX, Dew_Point_MIN, Pressure_AVG, Pressure_MAX, Pressure_MIN,
            Pressure_Station_Level_AVG, Pressure_Station_Level_MAX, Pressure_Station_Level_MIN, Humidity_AVG, Humidity_MAX, Humidity_MIN,
            Visible_Range_AVG, Visible_Range_MAX, Visible_Range_MIN, Wind_Speed_AVG, Wind_Speed_MAX, Wind_Speed_MIN)
        SELECT
            _StationId, MAX(CAST(R.Registration_Date AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.Dew_Point), MAX(R.Dew_Point), MIN(R.Dew_Point),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.Pressure_Station_Level), MAX(R.Pressure_Station_Level), MIN(R.Pressure_Station_Level),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.Visible_Range), MAX(R.Visible_Range), MIN(R.Visible_Range),
	        AVG(R.Wind_Speed), MAX(R.Wind_Speed), MIN(R.Wind_Speed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.Registration_Date), EXTRACT(MONTH FROM R.Registration_Date),  EXTRACT(DAY FROM R.Registration_Date);
        -- 12 часов
        INSERT INTO Agg.Hours12(
            Station_Id, Registration_Date, Temperature_AVG, Temperature_MAX, Temperature_MIN,
            Dew_Point_AVG, Dew_Point_MAX, Dew_Point_MIN, Pressure_AVG, Pressure_MAX, Pressure_MIN,
            Pressure_Station_Level_AVG, Pressure_Station_Level_MAX, Pressure_Station_Level_MIN, Humidity_AVG, Humidity_MAX, Humidity_MIN,
            Visible_Range_AVG, Visible_Range_MAX, Visible_Range_MIN, Wind_Speed_AVG, Wind_Speed_MAX, Wind_Speed_MIN)
        SELECT
            _StationId,
               MAX(make_timestamp(CAST(EXTRACT(YEAR FROM R.Registration_Date) AS INT), CAST(EXTRACT(MONTH FROM R.Registration_Date) AS INT),
                CAST(EXTRACT(DAY FROM R.Registration_Date) AS INT), Web.hours_12(R.Registration_Date), 0, 0)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.Dew_Point), MAX(R.Dew_Point), MIN(R.Dew_Point),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.Pressure_Station_Level), MAX(R.Pressure_Station_Level), MIN(R.Pressure_Station_Level),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.Visible_Range), MAX(R.Visible_Range), MIN(R.Visible_Range),
	        AVG(R.Wind_Speed), MAX(R.Wind_Speed), MIN(R.Wind_Speed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.Registration_Date), EXTRACT(MONTH FROM R.Registration_Date),
                 EXTRACT(DAY FROM R.Registration_Date), Web.hours_12(R.Registration_Date);
        -- 6 часов
        INSERT INTO Agg.Hours6(
            Station_Id, Registration_Date, Temperature_AVG, Temperature_MAX, Temperature_MIN,
            Dew_Point_AVG, Dew_Point_MAX, Dew_Point_MIN, Pressure_AVG, Pressure_MAX, Pressure_MIN,
            Pressure_Station_Level_AVG, Pressure_Station_Level_MAX, Pressure_Station_Level_MIN, Humidity_AVG, Humidity_MAX, Humidity_MIN,
            Visible_Range_AVG, Visible_Range_MAX, Visible_Range_MIN, Wind_Speed_AVG, Wind_Speed_MAX, Wind_Speed_MIN)
        SELECT
            _StationId, MAX(make_timestamp(CAST(EXTRACT(YEAR FROM R.Registration_Date) AS INT), CAST(EXTRACT(MONTH FROM R.Registration_Date) AS INT),
            CAST(EXTRACT(DAY FROM R.Registration_Date) AS INT), Web.hours_6(R.Registration_Date),0, 0.0)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.Dew_Point), MAX(R.Dew_Point), MIN(R.Dew_Point),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.Pressure_Station_Level), MAX(R.Pressure_Station_Level), MIN(R.Pressure_Station_Level),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.Visible_Range), MAX(R.Visible_Range), MIN(R.Visible_Range),
	        AVG(R.Wind_Speed), MAX(R.Wind_Speed), MIN(R.Wind_Speed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.Registration_Date), EXTRACT(MONTH FROM R.Registration_Date),
                 EXTRACT(DAY FROM R.Registration_Date), Web.hours_6(R.Registration_Date);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Регистрация набора метеорологических показателей
CREATE OR REPLACE PROCEDURE Web.insert_registration_json(_values json, _StationId INT) AS
    $$
    BEGIN
        INSERT INTO Import.Registration(Station_Id, Registration_Date, Temperature, Dew_Point, Pressure, Pressure_Station_Level,
                                        Humidity, Visible_Range, Wind_Speed, Weather, Wind_Direction_Id, Cloudiness_Id)
        SELECT
            _StationId,
            J.Registration_Date, J.Temperature, J.Dew_Point, J.Pressure, J.Pressure_Station_Level, J.Humidity, J.Visible_Range,
            J.Wind_Speed, J.Weather, J.Wind_Direction_Id, J.Cloudiness_Id
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS J;

        CALL Web.agg_values_json(_values, _StationId);
    END;
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Удаление страны с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_country(_CountryId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Country WHERE Country_Id = _CountryId) THEN
            RAISE EXCEPTION 'Страна с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
        ELSE
            DELETE FROM Import.Country WHERE Country_Id = _CountryId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Удаление региона с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_region(_RegionId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Region WHERE Region_Id = _RegionId) THEN
            RAISE EXCEPTION 'Регион с заданным идентификатором отсутствует!' USING ERRCODE = 51003;
        ELSE
            DELETE FROM Import.Region WHERE Region_Id = _RegionId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Удаление населённого пункта с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_locality(_LocalityId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Locality WHERE Locality_Id = _LocalityId) THEN
            RAISE EXCEPTION 'Населённый пункт с заданным идентификатором отсутствует!' USING ERRCODE = 51004;
        ELSE
            DELETE FROM Import.Locality WHERE Locality_Id = _LocalityId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Удаление организации с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_organization(_OrganizationId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Organization WHERE Organization_Id = _OrganizationId) THEN
            RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51005;
        ELSE
            DELETE FROM Import.Organization WHERE Organization_Id = _OrganizationId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Удаление метеостанции с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_station(_StationId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Station WHERE Station_Id = _StationId) THEN
            RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51006;
        ELSE
            DELETE FROM Import.Station WHERE Station_Id = _StationId;
        END IF;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

--Обновляет сведения о стране
CREATE OR REPLACE PROCEDURE Web.update_country(_values json, _CountryId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Country WHERE Country_Id = _CountryId) THEN
        RAISE EXCEPTION 'Страна с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
    ELSE
      UPDATE Import.Country SET
	    Country_Name = COALESCE(T.JCountyName, Country_Name),
		Land_Area = COALESCE(T.JLandArea, Land_Area),
		Water_Area = COALESCE(T.JWaterArea, Water_Area)
	  FROM (
	    SELECT J.Country_Name AS JCountyName, J.Land_Area AS JLandArea, J.Water_Area As JWaterArea
		FROM json_populate_record(NULL::Import.Country, _values) AS J
	  ) AS T
	  WHERE Country_Id = _CountryId;
    END IF;
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Обновляет сведения о регионе
CREATE OR REPLACE PROCEDURE Web.update_region(_values json, _RegionId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Region WHERE Region_Id = _RegionId) THEN
        RAISE EXCEPTION 'Регион с заданным идентификатором отсутствует!' USING ERRCODE = 51003;
    ELSE
      UPDATE Import.Region SET
	    Region_Name = COALESCE(T.JRegionName, Region_Name),
		Country_Id = COALESCE(T.JCountryId, Country_Id)
	  FROM (
	    SELECT J.Region_Name AS JRegionName, J.Country_Id AS JCountryId
		FROM json_populate_recordset(NULL::Import.Region, _values) AS J
	  ) AS T
	  WHERE Region_Id = _RegionId;
    END IF;
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Обновляет сведения о населенном пункте
CREATE OR REPLACE PROCEDURE Web.update_locality(_values json, _LocalityId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Locality WHERE Locality_Id = _LocalityId) THEN
        RAISE EXCEPTION 'Населённый пункт с заданным идентификатором отсутствует!' USING ERRCODE = 51004;
    ELSE
      UPDATE Import.Locality SET
	    Locality_Name = COALESCE(T.JLocalityName, Locality_Name),
	    Region_Id = COALESCE(T.JRegionId, Region_Id)
	  FROM (
	    SELECT J.Locality_Name AS JLocalityName, J.Region_Id AS JRegionId
		FROM json_populate_recordset(NULL::Import.Locality, _values) AS J
	  ) AS T
	  WHERE Locality_Id = _LocalityId;
    END IF;
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Обновление сведений о организации
CREATE OR REPLACE PROCEDURE Web.update_organization(_values json, _OrganizationId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Organization WHERE Organization_Id = _OrganizationId) THEN
        RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51005;
    ELSE
      UPDATE Import.Organization SET
	    Organization_Name = COALESCE(T.JOrganizationName, Organization_Name),
	    Address = COALESCE(T.JAddress, Address),
        Web_Site = COALESCE(T.JWebSite, Web_Site),
        Locality_Id = COALESCE(T.JLocalityId, Locality_Id),
        Parent_Organization_Id = COALESCE(T.JParentOrganizationId, Parent_Organization_Id)
	  FROM (
	    SELECT J.Organization_Name AS JOrganizationName, J.Address AS JAddress,
	           J.Web_Site AS JWebSite, J.Locality_Id AS JLocalityId, J.Parent_Organization_Id AS JParentOrganizationId
		FROM json_populate_recordset(NULL::Import.Organization, _values) AS J
	  ) AS T
	  WHERE Organization_Id = _OrganizationId;
    END IF;
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Обновление сведений о станции
CREATE OR REPLACE PROCEDURE Web.update_station(_values json, _StationId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Station WHERE Station_Id = _StationId) THEN
        RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51006;
    ELSE
      UPDATE Import.Station SET
        Station_Name = COALESCE(T.JStationName, Station_Name),
        Latitude = COALESCE(T.JLatitude, Latitude),
        Longitude = COALESCE(T.JLongitude, Longitude),
        Height = COALESCE(T.JHeight, Height),
        Region_Id = COALESCE(T.JRegionId, Region_Id),
        Organization_Id = COALESCE(T.JOrganizationId, Organization_Id)
	  FROM (
	    SELECT J.Station_Name AS JStationName, J.Latitude AS JLatitude, J.Longitude AS JLongitude,
	           J.Height AS JHeight, Region_Id AS JRegionId, Organization_Id AS JOrganizationId
		FROM json_populate_recordset(NULL::Import.Station, _values) AS J
	  ) AS T
	  WHERE Station_Id = _StationId;
    END IF;
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Триггер для автоматического вычисления суммарной площади страны
CREATE FUNCTION Import.func_calculate_total() RETURNS TRIGGER AS
    $$
    BEGIN
        IF pg_trigger_depth() <> 1 THEN
            RETURN NEW;
         END IF;
        UPDATE Import.Country SET
            Total_Area = NEW.Land_Area + NEW.Water_Area
        WHERE NEW.Country_Id = Country.Country_Id;
        RETURN NEW;
    END;
    $$ LANGUAGE PLpgSQL;

CREATE TRIGGER calculate_total_insert AFTER INSERT OR UPDATE ON Import.Country
    FOR EACH ROW EXECUTE FUNCTION Import.func_calculate_total();


-- Функции возвращающие содержимое таблиц в формаье JSON
-- Получить все страны
CREATE FUNCTION Web.country_json() RETURNS TABLE(json_values json)  AS
    $$
    BEGIN
        RETURN QUERY (
            SELECT json_build_object(
                'country_id', C.Country_Id,
                'country_name', C.Country_Name,
                'land_area', C.Land_Area,
                'water_area', C.Water_Area,
                'total_area', C.Total_Area)
            FROM Import.Country AS C
        );
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Вернуть сведение о стране по идентификатору
CREATE FUNCTION Web.one_country_json(_CountryId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
      RETURN QUERY (
        SELECT json_build_object(
            'country_id', C.Country_Id,
            'country_name', C.Country_Name,
            'land_area', C.Land_Area,
            'water_area', C.Water_Area,
            'total_area', C.Total_Area)
        FROM Import.Country AS C
        WHERE Country_Id = _CountryId
      );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- получить все регионы
CREATE FUNCTION Web.region_json() RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'region_id', R.Region_Id,
            'region_name', R.Region_Name,
            'country_id', R.Country_Id)
        FROM Import.Region AS R
        );
   END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_region_json(_RegionId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
      RETURN QUERY (
        SELECT json_build_object(
            'region_id', region_Id,
            'region_name', region_Name,
            'country_id', country_id)
        FROM Import.Region
        WHERE Region_Id = _RegionId
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- получить все населенные пункты
CREATE FUNCTION Web.locality_json() RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'locality_id', Locality_Id,
            'locality_name', Locality_Name,
            'region_id', Region_Id)
        FROM Import.Locality
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;


-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_locality_json(_LocalityId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
      RETURN QUERY (
        SELECT json_build_object(
            'locality_id', Locality_Id,
            'locality_name', Locality_Name,
            'region_id', Region_Id)
        FROM Import.Locality
        WHERE Locality_Id = _LocalityId
      );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- получить все станции
CREATE FUNCTION Web.station_json() RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'station_name', Station_Name,
            'latitude', Latitude,
            'longitude', Longitude,
            'height', Height,
            'region_id', Region_Id,
            'organization_id', Organization_Id)
        FROM Import.Station
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить сведения о станции по идентификатору
CREATE FUNCTION Web.one_station_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
      RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'station_name', Station_Name,
            'latitude', Latitude,
            'longitude', Longitude,
            'height', Height,
            'region_id', Region_Id,
            'organization_id', Organization_Id)
        FROM Import.Station
        WHERE Station_Id = _StationId
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить все организации
CREATE FUNCTION Web.organization_json() RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'organization_id', Organization_Id,
            'organization_name', Organization_Name,
            'address', Address,
            'web_site', Web_Site,
            'locality_id', Locality_Id,
            'parent_organization_id', Parent_Organization_Id)
        FROM Import.Organization
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить сведения о организации по идентификатору
CREATE FUNCTION Web.one_organization_json(_OrganizationId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'organization_id', Organization_Id,
            'organization_name', Organization_Name,
            'address', Address,
            'web_site', Web_Site,
            'locality_id', Locality_Id,
            'parent_organization_id', Parent_Organization_Id)
        FROM Import.Organization
        WHERE Organization_Id = _OrganizationId
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить зарегистрированные на метеостанции данные в формате JSON
CREATE FUNCTION Web.registration_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
           'station_id', station_id,
           'registration_date', Registration_Date,
           'temperature', Temperature,
           'dew_point', Dew_Point,
           'pressure', Pressure,
           'pressure_station_level', Pressure_Station_Level,
           'humidity', Humidity,
           'visible_range', Visible_Range,
           'wind_speed', Wind_Speed,
           'weather', Weather,
           'wind_direction_id', Wind_Direction_Id,
           'cloudiness_id', Cloudiness_Id)
        FROM Import.Registration
        WHERE Station_Id = _StationId
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить зарегистрированные на метеостанции данные в заданном диапозоне в формате JSON
CREATE FUNCTION Web.registration_diapason_json(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
BEGIN
     RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature', Temperature,
            'dew_point', Dew_Point,
            'pressure', Pressure,
            'pressure_station_level', Pressure_Station_Level,
            'humidity', Humidity,
            'visible_range', Visible_Range,
            'wind_speed', Wind_Speed,
            'weather', Weather,
            'wind_direction_id', Wind_Direction_Id,
            'cloudiness_id', Cloudiness_Id)
        FROM Import.Registration
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end
         );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за месяц
CREATE FUNCTION Web.months_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Months
        WHERE Station_Id = _StationId);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за месяц в заданном диапозоне
CREATE FUNCTION Web.months_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Months
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за неделю
CREATE FUNCTION Web.weeks_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Weeks
        WHERE Station_Id = _StationId);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за неделю в заданном диапозоне
CREATE FUNCTION Web.weeks_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Weeks
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за день
CREATE FUNCTION Web.days_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Days
        WHERE Station_Id = _StationId);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за день в заданном диапозоне
CREATE FUNCTION Web.days_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Days
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за 12 часов
CREATE FUNCTION Web.hours12_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Hours12
        WHERE Station_Id = _StationId);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеооданные, агрегированные за 12 часов в заданном диапозоне
CREATE FUNCTION Web.hours12_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Hours12
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за 6 часов
CREATE FUNCTION Web.hours6_json(_StationId INT) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Hours6
        WHERE Station_Id = _StationId);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить метеооданные, агрегированные за 6 часов в заданном диапозоне
CREATE FUNCTION Web.hours6_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS TABLE(json_values json) AS
    $$
    BEGIN
        RETURN QUERY (
        SELECT json_build_object(
            'station_id', Station_Id,
            'registration_date', Registration_Date,
            'temperature_avg', Temperature_AVG,
            'temperature_max', Temperature_MAX,
            'temperature_min', Temperature_MIN,
            'dew_point_avg', Dew_Point_AVG,
            'dew_point_max', Dew_Point_MAX,
            'dew_point_min', Dew_Point_MIN,
            'pressure_avg', Pressure_AVG,
            'pressure_max', Pressure_MAX,
            'pressure_min', Pressure_MIN,
            'pressure_station_level_avg', Pressure_Station_Level_AVG,
            'pressure_station_level_max', Pressure_Station_Level_MAX,
            'pressure_station_level_min', Pressure_Station_Level_MIN,
            'humidity_avg', Humidity_AVG,
            'humidity_max', Humidity_MAX,
            'humidity_min', Humidity_MIN,
            'visible_range_avg', Visible_Range_AVG,
            'visible_range_max', Visible_Range_MAX,
            'visible_range_min', Visible_Range_MIN,
            'wind_speed_avg', Wind_Speed_AVG,
            'wind_speed_max', Wind_Speed_MAX,
            'wind_speed_min', Wind_Speed_MIN)
        FROM Agg.Hours6
        WHERE Station_Id = _StationId AND Registration_Date BETWEEN _d_begin AND _d_end);
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Получить содержание справочника облачности
CREATE FUNCTION Web.get_cloudiness_json() RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'cloudiness_id', Cloudiness_Id,
            'cloudiness_level', Cloudiness_Level,
            'octane', octane)
        FROM Static.Cloudiness
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;


-- Получить содержание справочника направлений ветра
CREATE FUNCTION Web.get_wind_direction_json() RETURNS TABLE(json_values json) AS
    $$
BEGIN
    RETURN QUERY (
        SELECT json_build_object(
            'wind_direction_id', Wind_Direction_Id,
            'direction', direction,
            'mark', mark)
        FROM Static.WindDirection
        );
END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

CREATE FUNCTION Web.hours_12(_RegDate TIMESTAMP) RETURNS INT AS
    $$
    BEGIN
        RETURN CASE WHEN EXTRACT(HOUR FROM _RegDate) BETWEEN 1 AND 12 THEN 12 ELSE 0 END;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

CREATE FUNCTION Web.hours_6(_RegDate TIMESTAMP) RETURNS INT AS
    $$
    BEGIN
    RETURN
	  CASE
	    WHEN EXTRACT(HOUR FROM _RegDate) BETWEEN 1 AND 6 THEN 6
		WHEN EXTRACT(HOUR FROM _RegDate) BETWEEN 7 AND 12 THEN 12
		WHEN EXTRACT(HOUR FROM _RegDate) BETWEEN 13 AND 18 THEN 18
	    ELSE 0
	  END;
    END
    $$ SECURITY DEFINER SET SEARCH_PATH = public LANGUAGE PLpgSQL;

-- Заполнение статических таблиц
-- Направление ветра
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с западо-юго-запада', N'ЗЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с запада', N'З');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с юго-юго-запада', N'ЮЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с северо-запада', N'СЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с северо-северо-запада', N'ССЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с юго-запада', N'ЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с юга', N'Ю');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с юго-юго-востока', N'ЮЮВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с юго-востока', N'ЮВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Штиль, безветрие', N'Штиль');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с северо-северо-востока', N'ССВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с севера', N'С');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с северо-востока', N'СВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с востоко-северо-востока', N'ВСВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с востока', N'В');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с западо-северо-запада', N'ЗСЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES (N'Ветер, дующий с востоко-юго-востока', N'ВЮВ');

-- Облачность
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'Облаков нет.', '0');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'90  или более, но не 100%', N'Не более 8 и не менее 7 октант');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'70 – 80%.', N'6 октантов');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'100%.', N'8 октант');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'20–30%.', N'2 октанта');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'60%.', N'5 октантов');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'Небо не видно из-за тумана и/или других метеорологических явлений.', N'Из-за атмосферных явлений небо не видно');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'50%.', N'4 октанта');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'10%  или менее, но не 0', N'Не более 1 октанта, но больше 0');
INSERT INTO Static.Cloudiness(Cloudiness_Level, Octane) VALUES (N'40%.', N'3 октанта');

-- Пользователди уровня приложения
INSERT INTO auth.RoleData(Role_Name) VALUES ('Admin');
INSERT INTO auth.RoleData(Role_Name) VALUES ('Moderator');
INSERT INTO auth.RoleData(Role_Name) VALUES ('Customer');
INSERT INTO auth.RoleData(Role_Name) VALUES ('Station');

-- CALL web.insert_user('Administrator', 'password', 1);
