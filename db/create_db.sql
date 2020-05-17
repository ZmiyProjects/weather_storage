/*
CREATE DATABASE test_1;
\connect test_1;
*/

-- Создание схем
CREATE SCHEMA Import;

CREATE SCHEMA Static;

CREATE SCHEMA Agg;

CREATE SCHEMA Auth;

-- схема Web предназначена в качестве пространства имен для функций/процедур вызываемых со стороны веб-сервиса
CREATE SCHEMA Web;

CREATE TABLE Auth.RoleData(
    RoleId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Auth.UserData(
    UserId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    UserLogin VARCHAR(30) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RegistrationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    RoleId INT NOT NULL REFERENCES Auth.RoleData(RoleId)
);

-- Создание таблиц "только для чтения" в схеме Static
CREATE TABLE Static.WindDirection(
    WindDirectionId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Direction VARCHAR(100) UNIQUE NOT NULL,
    Mark VARCHAR(5) UNIQUE NOT NULL
);

CREATE TABLE Static.Cloudiness(
    CloudinessId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    CloudinessLevel VARCHAR(100) NOT NULL UNIQUE,
    Octane VARCHAR(50) NOT NULL UNIQUE
);

-- Создание таблиц в схеме Import
-- Возможо, стоит сделать "справочные" таблицы темпоральными

-- TotalArea - сумма LandArea и WaterArea
CREATE TABLE Import.Country(
    CountryId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    CountryName VARCHAR(100) UNIQUE NOT NULL,
    LandArea INT NOT NULL,
    WaterArea INT NOT NULL,
    TotalArea INT NULL
);

CREATE TABLE Import.Region(
    RegionId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    RegionName VARCHAR(100) UNIQUE NOT NULL,
    CountryId INT NOT NULL REFERENCES Import.Country(CountryId)
);

CREATE TABLE Import.Locality(
    LocalityId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    LocalityName VARCHAR(100) UNIQUE NOT NULL,
    RegionId INT NOT NULL REFERENCES Import.Region(RegionId)
);

CREATE TABLE Import.Organization(
    OrganizationId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    OrganizationName VARCHAR(255) UNIQUE NOT NULL,
    Address VARCHAR(255) NOT NULL,
    WebSite VARCHAR(255) NULL,
    LocalityId INT NOT NULL REFERENCES Import.Locality(LocalityId),
    ParentOrganizationId INT REFERENCES Import.Organization(OrganizationId)
);

CREATE TABLE Import.Station(
    StationId INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    StationName VARCHAR(255) UNIQUE NOT NULL,
    Latitude NUMERIC(5, 2) NOT NULL,
    Longitude NUMERIC(5, 2) NOT NULL,
    Height SMALLINT NOT NULL,
    RegionId INT NOT NULL REFERENCES Import.Region(RegionId),
    OrganizationId INT NOT NULL REFERENCES Import.Organization(OrganizationId),
    CONSTRAINT CK_Latitude CHECK (Latitude BETWEEN -90 AND 90),
    CONSTRAINT CK_Longitude CHECK (Longitude BETWEEN -180 AND 180)
);

CREATE TABLE Import.Registration(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate TIMESTAMP NOT NULL,
    Temperature NUMERIC(5, 2) NOT NULL,
    DewPoint NUMERIC(5, 2) NOT NULL,
    Pressure NUMERIC(6, 2) NOT NULL,
    PressureStationLevel NUMERIC(6, 2) NOT NULL,
    Humidity NUMERIC(5, 2) NOT NULL,
    VisibleRange NUMERIC(6, 2) NOT NULL,
    WindSpeed NUMERIC(5, 2) NOT NULL,
    Weather VARCHAR(255) NOT NULL,
    WindDirectionId INT REFERENCES Static.WindDirection(WindDirectionId),
    CloudinessId INT REFERENCES Static.Cloudiness(CloudinessId),
    CONSTRAINT PK_Registration PRIMARY KEY(StationId, RegistrationDate),
    CONSTRAINT CK_Temperature CHECK (Temperature BETWEEN -60 AND 60),
    CONSTRAINT CK_DewPoint CHECK (DewPoint BETWEEN -60 AND 60),
    CONSTRAINT CK_Pressure CHECK (Pressure BETWEEN 0 AND 1000),
    CONSTRAINT CK_PressureStationLevel CHECK (PressureStationLevel BETWEEN 0 AND 1000),
    CONSTRAINT CK_Humidity CHECK (Humidity BETWEEN 0 AND 100),
    CONSTRAINT CK_VisibleRange CHECK (VisibleRange BETWEEN 0 AND 100),
    CONSTRAINT CK_WindSpeed CHECK (WindSpeed BETWEEN 0 AND 50)
);

CREATE TABLE Agg.Hours6(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate TIMESTAMP,
    TemperatureAVG NUMERIC(5, 2) NOT NULL,
    TemperatureMAX NUMERIC(5, 2) NOT NULL,
    TemperatureMIN NUMERIC(5, 2) NOT NULL,
    DewPointAVG NUMERIC(5, 2) NOT NULL,
    DewPointMAX NUMERIC(5, 2) NOT NULL,
    DewPointMIN NUMERIC(5, 2) NOT NULL,
    PressureAVG NUMERIC(6, 2) NOT NULL,
    PressureMAX NUMERIC(6, 2) NOT NULL,
    PressureMIN NUMERIC(6, 2) NOT NULL,
    PressureStationLevelAVG NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMAX NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMIN NUMERIC(6, 2) NOT NULL,
    HumidityAVG NUMERIC(5, 2) NOT NULL,
    HumidityMAX NUMERIC(5, 2) NOT NULL,
    HumidityMIN NUMERIC(5, 2) NOT NULL,
    VisibleRangeAVG NUMERIC(6, 2) NOT NULL,
    VisibleRangeMAX NUMERIC(6, 2) NOT NULL,
    VisibleRangeMIN NUMERIC(6, 2) NOT NULL,
    WindSpeedAVG NUMERIC(5, 2) NOT NULL,
    WindSpeedMAX NUMERIC(5, 2) NOT NULL,
    WindSpeedMIN NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Hours6 PRIMARY KEY (StationId, RegistrationDate)
);

CREATE TABLE Agg.Hours12(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate TIMESTAMP,
    TemperatureAVG NUMERIC(5, 2) NOT NULL,
    TemperatureMAX NUMERIC(5, 2) NOT NULL,
    TemperatureMIN NUMERIC(5, 2) NOT NULL,
    DewPointAVG NUMERIC(5, 2) NOT NULL,
    DewPointMAX NUMERIC(5, 2) NOT NULL,
    DewPointMIN NUMERIC(5, 2) NOT NULL,
    PressureAVG NUMERIC(6, 2) NOT NULL,
    PressureMAX NUMERIC(6, 2) NOT NULL,
    PressureMIN NUMERIC(6, 2) NOT NULL,
    PressureStationLevelAVG NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMAX NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMIN NUMERIC(6, 2) NOT NULL,
    HumidityAVG NUMERIC(5, 2) NOT NULL,
    HumidityMAX NUMERIC(5, 2) NOT NULL,
    HumidityMIN NUMERIC(5, 2) NOT NULL,
    VisibleRangeAVG NUMERIC(6, 2) NOT NULL,
    VisibleRangeMAX NUMERIC(6, 2) NOT NULL,
    VisibleRangeMIN NUMERIC(6, 2) NOT NULL,
    WindSpeedAVG NUMERIC(5, 2) NOT NULL,
    WindSpeedMAX NUMERIC(5, 2) NOT NULL,
    WindSpeedMIN NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Hours12 PRIMARY KEY (StationId, RegistrationDate)
);

CREATE TABLE Agg.Days(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate DATE,
    TemperatureAVG NUMERIC(5, 2) NOT NULL,
    TemperatureMAX NUMERIC(5, 2) NOT NULL,
    TemperatureMIN NUMERIC(5, 2) NOT NULL,
    DewPointAVG NUMERIC(5, 2) NOT NULL,
    DewPointMAX NUMERIC(5, 2) NOT NULL,
    DewPointMIN NUMERIC(5, 2) NOT NULL,
    PressureAVG NUMERIC(6, 2) NOT NULL,
    PressureMAX NUMERIC(6, 2) NOT NULL,
    PressureMIN NUMERIC(6, 2) NOT NULL,
    PressureStationLevelAVG NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMAX NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMIN NUMERIC(6, 2) NOT NULL,
    HumidityAVG NUMERIC(5, 2) NOT NULL,
    HumidityMAX NUMERIC(5, 2) NOT NULL,
    HumidityMIN NUMERIC(5, 2) NOT NULL,
    VisibleRangeAVG NUMERIC(6, 2) NOT NULL,
    VisibleRangeMAX NUMERIC(6, 2) NOT NULL,
    VisibleRangeMIN NUMERIC(6, 2) NOT NULL,
    WindSpeedAVG NUMERIC(5, 2) NOT NULL,
    WindSpeedMAX NUMERIC(5, 2) NOT NULL,
    WindSpeedMIN NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Days PRIMARY KEY (StationId, RegistrationDate)
);

CREATE TABLE Agg.Weeks(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate DATE,
    TemperatureAVG NUMERIC(5, 2) NOT NULL,
    TemperatureMAX NUMERIC(5, 2) NOT NULL,
    TemperatureMIN NUMERIC(5, 2) NOT NULL,
    DewPointAVG NUMERIC(5, 2) NOT NULL,
    DewPointMAX NUMERIC(5, 2) NOT NULL,
    DewPointMIN NUMERIC(5, 2) NOT NULL,
    PressureAVG NUMERIC(6, 2) NOT NULL,
    PressureMAX NUMERIC(6, 2) NOT NULL,
    PressureMIN NUMERIC(6, 2) NOT NULL,
    PressureStationLevelAVG NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMAX NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMIN NUMERIC(6, 2) NOT NULL,
    HumidityAVG NUMERIC(5, 2) NOT NULL,
    HumidityMAX NUMERIC(5, 2) NOT NULL,
    HumidityMIN NUMERIC(5, 2) NOT NULL,
    VisibleRangeAVG NUMERIC(6, 2) NOT NULL,
    VisibleRangeMAX NUMERIC(6, 2) NOT NULL,
    VisibleRangeMIN NUMERIC(6, 2) NOT NULL,
    WindSpeedAVG NUMERIC(5, 2) NOT NULL,
    WindSpeedMAX NUMERIC(5, 2) NOT NULL,
    WindSpeedMIN NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Weeks PRIMARY KEY (StationId, RegistrationDate)
);

CREATE TABLE Agg.Months(
    StationId INT REFERENCES Import.Station(StationId),
    RegistrationDate DATE,
    TemperatureAVG NUMERIC(5, 2) NOT NULL,
    TemperatureMAX NUMERIC(5, 2) NOT NULL,
    TemperatureMIN NUMERIC(5, 2) NOT NULL,
    DewPointAVG NUMERIC(5, 2) NOT NULL,
    DewPointMAX NUMERIC(5, 2) NOT NULL,
    DewPointMIN NUMERIC(5, 2) NOT NULL,
    PressureAVG NUMERIC(6, 2) NOT NULL,
    PressureMAX NUMERIC(6, 2) NOT NULL,
    PressureMIN NUMERIC(6, 2) NOT NULL,
    PressureStationLevelAVG NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMAX NUMERIC(6, 2) NOT NULL,
    PressureStationLevelMIN NUMERIC(6, 2) NOT NULL,
    HumidityAVG NUMERIC(5, 2) NOT NULL,
    HumidityMAX NUMERIC(5, 2) NOT NULL,
    HumidityMIN NUMERIC(5, 2) NOT NULL,
    VisibleRangeAVG NUMERIC(6, 2) NOT NULL,
    VisibleRangeMAX NUMERIC(6, 2) NOT NULL,
    VisibleRangeMIN NUMERIC(6, 2) NOT NULL,
    WindSpeedAVG NUMERIC(5, 2) NOT NULL,
    WindSpeedMAX NUMERIC(5, 2) NOT NULL,
    WindSpeedMIN NUMERIC(5, 2) NOT NULL,
    CONSTRAINT PK_Months PRIMARY KEY (StationId, RegistrationDate)
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

CREATE OR REPLACE FUNCTION Web.users_json() RETURNS json AS
    $$
    BEGIN
      RETURN (
        SELECT json_build_object(
            'UserId', U.UserId,
            'UserLogin', U.UserLogin,
            'RegistrationDate', U.RegistrationDate,
            'RoleId', R.RoleId,
            'RoleName', R.RoleName)
        FROM Auth.UserData AS U
            JOIN Auth.RoleData R on U.RoleId = R.RoleId
        );
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.one_user_json(_UserId INT) RETURNS json AS
    $$
    BEGIN
    RETURN (
        SELECT json_build_object(
            'UserId', U.UserId,
            'UserLogin', U.UserLogin,
            'RegistrationDate', U.RegistrationDate,
            'RoleId', R.RoleId,
            'RoleName', R.RoleName)
        FROM Auth.UserData AS U
            JOIN Auth.RoleData AS R on U.UserId = _UserId AND U.RoleId = R.RoleId
        );
    END
    $$ LANGUAGE PLpgSQL;

-- Хеширование паролей будет осуществлять python
CREATE OR REPLACE PROCEDURE Web.insert_user(_UserLogin VARCHAR(30), _Password VARCHAR(50), _RoleId INT) AS
    $$
    BEGIN
        INSERT INTO Auth.UserData(UserLogin, PasswordHash, RoleId) VALUES (_UserLogin, _Password, _RoleId);
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.roles_json() RETURNS json AS
    $$
    BEGIN
      RETURN (
        SELECT json_build_object(
               'RoleId', R.RoleId,
               'RoleName', R.RoleName,
               'RoleCount', COUNT(U.UserId))
        FROM Auth.RoleData AS R
            LEFT JOIN Auth.UserData AS U on R.RoleId = U.RoleId
        GROUP BY R.RoleId, R.RoleName
        );
    END
    $$ LANGUAGE PLpgSQL;

CREATE OR REPLACE PROCEDURE Web.delete_user(_UserId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId) THEN
            RAISE EXCEPTION 'Пользователь не существует!' USING ERRCODE = 51009;
        ELSE
            DELETE FROM Auth.UserData WHERE UserId = _UserId;
        END IF;
    END
   $$ LANGUAGE PLpgSQL;

CREATE OR REPLACE FUNCTION Web.init_user(_UserName VARCHAR(50)) RETURNS VARCHAR(50) AS
    $$
    BEGIN
        RETURN (
            SELECT R.RoleName FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.RoleId = R.RoleId AND U.UserLogin = _UserName
            );
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE PROCEDURE Web.update_user_json(_values json, _UserId INT) AS
    $$
    BEGIN
    IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId) THEN
        RAISE EXCEPTION 'Пользователь с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
    ELSE
      UPDATE Auth.UserData SET
	    UserLogin = COALESCE(T.JUserLogin, UserLogin),
		PasswordHash = COALESCE(T.JPassword, PasswordHash),
		RoleId = COALESCE(T.JRoleId, RoleId)
	  FROM (
	    SELECT J.UserLogin AS JUserLogin, J.PasswordHash AS JPassword, J.RoleId As JRoleId
		FROM json_populate_recordset(NULL::Auth.UserData, _values) AS J
	  ) AS T
	  WHERE UserId = _UserId;
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
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId) THEN
            RAISE 'Пользователь не существует!' USING ERRCODE = 51009;
        ELSE
            UPDATE Auth.UserData SET
                UserLogin = COALESCE(_NewLogin, UserLogin),
                PasswordHash = COALESCE(_NewPassword, PasswordHash),
                RoleId = COALESCE(_RoleId, RoleId)
            WHERE UserId = _UserId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;


CREATE OR REPLACE FUNCTION Web.select_user(_UserId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
            SELECT json_build_object(
                   U.UserLogin,
                   R.RoleName)
            FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.RoleId = R.RoleId AND U.UserId = _UserId
            );
    END
    $$ LANGUAGE PLpgSQL;

-- На python

CREATE OR REPLACE FUNCTION Web.check_password(_UserName VARCHAR(30)) RETURNS VARCHAR(255) AS
    $$
    BEGIN
        RETURN ( SELECT PasswordHash FROM Auth.UserData WHERE UserLogin = _UserName);
    END
    $$ LANGUAGE PLpgSQL;

-- Вставка в БД сведений о одной стране из JSON (TotalArea вычисляется во время вставки)
CREATE OR REPLACE PROCEDURE Web.insert_country_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Country(CountryName, LandArea, WaterArea, TotalArea)
        SELECT
            J.CountryName,
            J.LandArea,
            J.WaterArea,
            J.WaterArea + J.LandArea AS TotalArea
        FROM json_populate_recordset(NULL::Import.Country, _values) AS J;
    END;
    $$ LANGUAGE PLpgSQL;

-- Вставка в БД сведений об одном регионе из JSON
CREATE OR REPLACE PROCEDURE Web.insert_region_json(_values json, _CountryId INT) AS
    $$
    BEGIN
       INSERT INTO Import.Region(RegionName, CountryId)
       SELECT
           J.RegionName,
           _CountryId
       FROM json_populate_recordset(NULL::Import.Region, _values) AS J;
    END;
    $$ LANGUAGE PLpgSQL;

-- Вставка в БД сведений об одном населённом пункте из JSON
CREATE OR REPLACE PROCEDURE Web.insert_locality_json(_values json, _RegionId INT) AS
    $$
    BEGIN
        INSERT INTO Import.Locality(LocalityName, RegionId)
        SELECT
            J.LocalityName,
            _RegionId
        FROM json_populate_recordset(NULL::Import.Locality, _values) AS J;
    END;
    $$ LANGUAGE PLpgSQL;

-- Вставить сведения о одной организации
-- Добавить проверку наличия родительской организации и бросить исключение приее отсутствии!
CREATE OR REPLACE PROCEDURE Web.insert_organization_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Organization(OrganizationName, Address, WebSite, LocalityId, ParentOrganizationId)
        SELECT
            J.OrganizationName, J.Address, J.WebSite, J.LocalityId, J.ParentOrganizationId
        FROM json_populate_recordset(NULL::Import.Organization, _values) AS J;
    END;
    $$ LANGUAGE PLpgSQL;

-- Вставить сведения об одной станциии
CREATE OR REPLACE PROCEDURE Web.insert_station_json(_values json) AS
    $$
    BEGIN
        INSERT INTO Import.Station(StationName, Latitude, Longitude, Height, RegionId, OrganizationId)
        SELECT
            J.StationName, J.Latitude, J.Longitude, J.Height, J.RegionId, J.OrganizationId
        FROM json_populate_recordset(NULL::Import.Station, _values) AS J;
    END;
    $$ LANGUAGE PLpgSQL;

-- агрегация зарегистрированных данных
CREATE PROCEDURE Web.agg_values_json(_values json, _StationId INT) AS
    $$
        BEGIN
        -- Месяцы
        INSERT INTO Agg.Months(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            _StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY R.StationId, EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate);

        -- Недели
        INSERT INTO Agg.Weeks(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            _StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(WEEK FROM R.RegistrationDate);
        -- Дни
        INSERT INTO Agg.Days(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            _StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate),  EXTRACT(DAY FROM R.RegistrationDate);
        -- 12 часов
        INSERT INTO Agg.Hours12(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            _StationId,
               MAX(make_timestamp(EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate),
                EXTRACT(DAY FROM R.RegistrationDate), Web.hours_12(R.RegistrationDate), 0, 0.0)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate),
                 EXTRACT(DAY FROM R.RegistrationDate), Web.hours_12(R.RegistrationDate);
        -- 6 часов
        INSERT INTO Agg.Hours6(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            _StationId, MAX(make_timestamp(EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate),
            EXTRACT(DAY FROM R.RegistrationDate), Web.hours_6(R.RegistrationDate),0, 0.0)) AS Date,
	        AVG(R.Temperature) AS TAvg, MAX(R.Temperature) AS TMax, MIN(R.Temperature) AS TMin,
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS R
        GROUP BY EXTRACT(YEAR FROM R.RegistrationDate), EXTRACT(MONTH FROM R.RegistrationDate),
                 EXTRACT(DAY FROM R.RegistrationDate), Web.hours_6(R.RegistrationDate);
    END
    $$ LANGUAGE PLpgSQL;

-- Регистрация набора метеорологических показателей
CREATE OR REPLACE PROCEDURE Web.insert_registration_json(_values json, _StationId INT) AS
    $$
    BEGIN
        INSERT INTO Import.Registration(StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
                                        Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId)
        SELECT
            _StationId,
            J.RegistrationDate, J.Temperature, J.DewPoint, J.Pressure, J.PressureStationLevel, J.Humidity, J.VisibleRange,
            J.WindSpeed, J.Weather, J.WindDirectionId, J.CloudinessId
        FROM json_populate_recordset(NULL::Import.Registration, _values) AS J;

        CALL Web.agg_values_json(_values, _StationId);
    END;
    $$ LANGUAGE PLpgSQL;

-- Удаление страны с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_country(_CountryId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = _CountryId) THEN
            RAISE EXCEPTION 'Страна с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
        ELSE
            DELETE FROM Import.Country WHERE CountryId = _CountryId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;

-- Удаление региона с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_region(_RegionId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = _RegionId) THEN
            RAISE EXCEPTION 'Регион с заданным идентификатором отсутствует!' USING ERRCODE = 51003;
        ELSE
            DELETE FROM Import.Region WHERE RegionId = _RegionId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;

-- Удаление населённого пункта с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_locality(_LocalityId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId) THEN
            RAISE EXCEPTION 'Населённый пункт с заданным идентификатором отсутствует!' USING ERRCODE = 51004;
        ELSE
            DELETE FROM Import.Locality WHERE LocalityId = _LocalityId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;

-- Удаление организации с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_organization(_OrganizationId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Organization WHERE OrganizationId = @OrganizationId) THEN
            RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51005;
        ELSE
            DELETE FROM Import.Organization WHERE OrganizationId = _OrganizationId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;

-- Удаление метеостанции с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_station(_StationId INT) AS
    $$
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = @StationId) THEN
            RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51006;
        ELSE
            DELETE FROM Import.Station WHERE StationId = _StationId;
        END IF;
    END
    $$ LANGUAGE PLpgSQL;

--Обновляет сведения о стране
CREATE OR REPLACE PROCEDURE Web.update_country(_values json, _CountryId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = @CountryId) THEN
        RAISE EXCEPTION 'Страна с заданным идентификатором отсутствует!' USING ERRCODE = 51002;
    ELSE
      UPDATE Import.Country SET
	    CountryName = COALESCE(T.JCountyName, CountryName),
		LandArea = COALESCE(T.JLandArea, LandArea),
		WaterArea = COALESCE(T.JWaterArea, WaterArea)
	  FROM (
	    SELECT J.CountryName AS JCountyName, J.LandArea AS JLandArea, J.WaterArea As JWaterArea
		FROM json_populate_record(NULL::Import.Country, _values) AS J
	  ) AS T
	  WHERE CountryId = _CountryId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Обновляет сведения о регионе
CREATE OR REPLACE PROCEDURE Web.update_region(_values json, _RegionId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId) THEN
        RAISE EXCEPTION 'Регион с заданным идентификатором отсутствует!' USING ERRCODE = 51003;
    ELSE
      UPDATE Import.Region SET
	    RegionName = COALESCE(T.JRegionName, RegionName),
		CountryId = COALESCE(T.JCountryId, CountryId)
	  FROM (
	    SELECT J.RegionName AS JRegionName, J.CountryId AS JCountryId
		FROM json_populate_recordset(NULL::Import.Region, _values) AS J
	  ) AS T
	  WHERE RegionId = _RegionId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Обновляет сведения о населенном пункте
CREATE OR REPLACE PROCEDURE Web.update_locality(_values json, _LocalityId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId) THEN
        RAISE EXCEPTION 'Населённый пункт с заданным идентификатором отсутствует!' USING ERRCODE = 51004;
    ELSE
      UPDATE Import.Locality SET
	    LocalityName = COALESCE(T.JLocalityName, LocalityName),
	    RegionId = COALESCE(T.JRegionId, RegionId)
	  FROM (
	    SELECT J.LocalityName AS JLocalityName, J.RegionId AS JRegionId
		FROM json_populate_recordset(NULL::Import.Locality, _values) AS J
	  ) AS T
	  WHERE LocalityId = _LocalityId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Обновление сведений о организации
CREATE OR REPLACE PROCEDURE Web.update_organization(_values json, _OrganizationId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Organization WHERE OrganizationId = @OrganizationId) THEN
        RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51005;
    ELSE
      UPDATE Import.Organization SET
	    OrganizationName = COALESCE(T.JOrganizationName, OrganizationName),
	    Address = COALESCE(T.JAddress, Address),
        WebSite = COALESCE(T.JWebSite, WebSite),
        LocalityId = COALESCE(T.JLocalityId, LocalityId),
        ParentOrganizationId = COALESCE(T.JParentOrganizationId, ParentOrganizationId)
	  FROM (
	    SELECT J.OrganizationName AS JOrganizationName, J.Address AS JAddress,
	           J.WebSite AS JWebSite, J.LocalityId AS JLocalityId, J.ParentOrganizationId AS JParentOrganizationId
		FROM json_populate_recordset(NULL::Import.Organization, _values) AS J
	  ) AS T
	  WHERE OrganizationId = _OrganizationId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Обновление сведений о станции
CREATE OR REPLACE PROCEDURE Web.update_station(_values json, _StationId INT) AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = @StationId) THEN
        RAISE EXCEPTION 'Организация с заданным идентификатором отсутствует!' USING ERRCODE = 51006;
    ELSE
      UPDATE Import.Station SET
        StationName = COALESCE(T.JStationName, StationName),
        Latitude = COALESCE(T.JLatitude, Latitude),
        Longitude = COALESCE(T.JLongitude, Longitude),
        Height = COALESCE(T.JHeight, Height),
        RegionId = COALESCE(T.JRegionId, RegionId),
        OrganizationId = COALESCE(T.JOrganizationId, OrganizationId)
	  FROM (
	    SELECT J.StationName AS JStationName, J.Latitude AS JLatitude, J.Longitude AS JLongitude,
	           J.Height AS JHeight, RegionId AS JRegionId, OrganizationId AS JOrganizationId
		FROM json_populate_recordset(NULL::Import.Station, _values) AS J
	  ) AS T
	  WHERE StationId = _StationId;
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Триггер для автоматического вычисления суммарной площади страны
CREATE FUNCTION Import.func_calculate_total() RETURNS TRIGGER AS
    $$
    BEGIN
        IF pg_trigger_depth() <> 1 THEN
            RETURN NEW;
         END IF;
        UPDATE Import.Country SET
            TotalArea = NEW.LandArea + NEW.WaterArea
        WHERE NEW.CountryId = Country.CountryId;
        RETURN NEW;
    END;
    $$ LANGUAGE PLpgSQL;

CREATE TRIGGER calculate_total_insert AFTER INSERT OR UPDATE ON Import.Country
    FOR EACH ROW EXECUTE FUNCTION Import.func_calculate_total();


-- Функции возвращающие содержимое таблиц в формаье JSON
-- Получить все страны
CREATE FUNCTION Web.country_json() RETURNS json AS
    $$
    BEGIN
        RETURN (
            SELECT json_build_object(
                'CountryId', C.CountryId,
                'CountryName', C.CountryName,
                'LandArea', C.LandArea,
                'WaterArea', C.WaterArea,
                'TotalArea', C.TotalArea)
            FROM Import.Country AS C
        );
    END
    $$ LANGUAGE PLpgSQL;

-- Вернуть сведение о стране по идентификатору
CREATE FUNCTION Web.one_country_json(_CountryId INT) RETURNS json AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = _CountryId) THEN
        RETURN NULL;
    ELSE
      RETURN (
        SELECT json_build_object(
            'CountryId', C.CountryId,
            'CountryName', C.CountryName,
            'LandArea', C.LandArea,
            'WaterArea', C.WaterArea,
            'TotalArea', C.TotalArea)
        FROM Import.Country AS C
        WHERE CountryId = _CountryId
      );
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- получить все регионы
CREATE FUNCTION Web.region_json() RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'RegionId', R.RegionId,
            'RegionName', R.RegionName,
            'CountryId', R.CountryId)
        FROM Import.Region AS R
        );
   END
    $$ LANGUAGE PLpgSQL;

-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_region_json(_RegionId INT) RETURNS json AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId) THEN
        RETURN NULL;
    ELSE
      RETURN (
        SELECT json_build_object(
            'RegionId', RegionId,
            'RegionName', RegionName,
            'CountryId', CountryId)
        FROM Import.Region
        WHERE RegionId = _RegionId
        );
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- получить все населенные пункты
CREATE FUNCTION Web.locality_json() RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'LocalityId', LocalityId,
            'LocalityName', LocalityName,
            'RegionId', RegionId)
        FROM Import.Locality
        );
END
    $$ LANGUAGE PLpgSQL;


-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_locality_json(_LocalityId INT) RETURNS json AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = _LocalityId) THEN
        RETURN NULL;
    ELSE
      RETURN (
        SELECT json_build_object(
            'LocalityId', LocalityId,
            'LocalityName', LocalityName,
            'RegionId', RegionId)
        FROM Import.Locality
        WHERE LocalityId = _LocalityId
      );
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- получить все станции
CREATE FUNCTION Web.station_json() RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'StationName', StationName,
            'Latitude', Latitude,
            'Longitude', Longitude,
            'Height', Height,
            'RegionId', RegionId,
            'OrganizationId', OrganizationId)
        FROM Import.Station
        );
END
    $$ LANGUAGE PLpgSQL;


-- Получить сведения о станции по идентификатору
CREATE FUNCTION Web.one_station_json(_StationId INT) RETURNS json AS
    $$
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = _StationId) THEN
        RETURN NULL;
    ELSE
      RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'StationName', StationName,
            'Latitude', Latitude,
            'Longitude', Longitude,
            'Height', Height,
            'RegionId', RegionId,
            'OrganizationId', OrganizationId)
        FROM Import.Station
        WHERE StationId = _StationId
        );
    END IF;
END
    $$ LANGUAGE PLpgSQL;

-- Получить все организации
CREATE FUNCTION Web.organization_json() RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'OrganizationId', OrganizationId,
            'OrganizationName', OrganizationName,
            'Address', Address,
            'WebSite', WebSite,
            'LocalityId', LocalityId,
            'ParentOrganizationId', ParentOrganizationId)
        FROM Import.Organization
        );
END
    $$ LANGUAGE PLpgSQL;

-- Получить сведения о организации по идентификатору
CREATE FUNCTION Web.one_organization_json(_OrganizationId INT) RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'OrganizationId', OrganizationId,
            'OrganizationName', OrganizationName,
            'Address', Address,
            'WebSite', WebSite,
            'LocalityId', LocalityId,
            'ParentOrganizationId', ParentOrganizationId)
        FROM Import.Organization
        WHERE OrganizationId = _OrganizationId
        );
END
    $$ LANGUAGE PLpgSQL;

-- Получить зарегистрированные на метеостанции данные в формате JSON
CREATE FUNCTION Web.registration_json(_StationId INT) RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
           'StationId', StationId,
           'RegistrationDate', RegistrationDate,
           'Temperature', Temperature,
           'DewPoint', DewPoint,
           'Pressure', Pressure,
           'PressureStationLevel', PressureStationLevel,
           'Humidity', Humidity,
           'VisibleRange', VisibleRange,
           'WindSpeed', WindSpeed,
           'Weather', Weather,
           'WindDirectionId', WindDirectionId,
           'CloudinessId', CloudinessId)
        FROM Import.Registration
        WHERE StationId = _StationId
        );
END
    $$ LANGUAGE PLpgSQL;

-- Получить зарегистрированные на метеостанции данные в заданном диапозоне в формате JSON
CREATE FUNCTION Web.registration_diapason_json(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
BEGIN
     RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'Temperature', Temperature,
            'DewPoint', DewPoint,
            'Pressure', Pressure,
            'PressureStationLevel', PressureStationLevel,
            'Humidity', Humidity,
            'VisibleRange', VisibleRange,
            'WindSpeed', WindSpeed,
            'Weather', Weather,
            'WindDirectionId', WindDirectionId,
            'CloudinessId', CloudinessId)
        FROM Import.Registration
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end
         );
END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за месяц
CREATE FUNCTION Web.months_json(_StationId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Months
        WHERE StationId = _StationId);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за месяц в заданном диапозоне
CREATE FUNCTION Web.months_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Months
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за неделю
CREATE FUNCTION Web.weeks_json(_StationId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Weeks
        WHERE StationId = _StationId);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за неделю в заданном диапозоне
CREATE FUNCTION Web.weeks_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Weeks
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за день
CREATE FUNCTION Web.days_json(_StationId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Days
        WHERE StationId = _StationId);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за день в заданном диапозоне
CREATE FUNCTION Agg.days_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Days
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за 12 часов
CREATE FUNCTION Web.hours12_json(_StationId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Hours12
        WHERE StationId = _StationId);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеооданные, агрегированные за 12 часов в заданном диапозоне
CREATE FUNCTION Web.hours12_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Hours12
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеоданные, агрегированные за 6 часов
CREATE FUNCTION Web.hours6_json(_StationId INT) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Hours6
        WHERE StationId = _StationId);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить метеооданные, агрегированные за 6 часов в заданном диапозоне
CREATE FUNCTION Web.hours6_json_diapason(_StationId INT, _d_begin TIMESTAMP, _d_end TIMESTAMP) RETURNS json AS
    $$
    BEGIN
        RETURN (
        SELECT json_build_object(
            'StationId', StationId,
            'RegistrationDate', RegistrationDate,
            'TemperatureAVG', TemperatureAVG,
            'TemperatureMAX', TemperatureMAX,
            'TemperatureMIN', TemperatureMIN,
            'DewPointAVG', DewPointAVG,
            'DewPointMAX', DewPointMAX,
            'DewPointMIN', DewPointMIN,
            'PressureAVG', PressureAVG,
            'PressureMAX', PressureMAX,
            'PressureMIN', PressureMIN,
            'PressureStationLevelAVG', PressureStationLevelAVG,
            'PressureStationLevelMAX', PressureStationLevelMAX,
            'PressureStationLevelMIN', PressureStationLevelMIN,
            'HumidityAVG', HumidityAVG,
            'HumidityMAX', HumidityMAX,
            'HumidityMIN', HumidityMIN,
            'VisibleRangeAVG', VisibleRangeAVG,
            'VisibleRangeMAX', VisibleRangeMAX,
            'VisibleRangeMIN', VisibleRangeMIN,
            'WindSpeedAVG', WindSpeedAVG,
            'WindSpeedMAX', WindSpeedMAX,
            'WindSpeedMIN', WindSpeedMIN)
        FROM Agg.Hours6
        WHERE StationId = _StationId AND RegistrationDate BETWEEN _d_begin AND _d_end);
    END
    $$ LANGUAGE PLpgSQL;

-- Получить содержание справочника облачности
CREATE FUNCTION Web.get_cloudiness_json() RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'CloudinessId', CloudinessId,
            'CloudinessLevel', CloudinessLevel,
            'Octane', Octane)
        FROM Static.Cloudiness
        );
END
    $$ LANGUAGE PLpgSQL;


-- Получить содержание справочника направлений ветра
CREATE FUNCTION Web.get_wind_direction_json() RETURNS json AS
    $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'WindDirectionId', WindDirectionId,
            'Direction', Direction,
            'Mark', Mark)
        FROM Static.WindDirection
        );
END
    $$ LANGUAGE PLpgSQL;

CREATE FUNCTION Web.hours_12(_RegDate TIMESTAMP) RETURNS INT AS
    $$
    BEGIN
        RETURN CASE WHEN EXTRACT(HOUR FROM _RegDate) BETWEEN 1 AND 12 THEN 12 ELSE 0 END;
    END
    $$ LANGUAGE PLpgSQL;

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
    $$ LANGUAGE PLpgSQL;

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
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'Облаков нет.', '0');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'90  или более, но не 100%', N'Не более 8 и не менее 7 октант');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'70 – 80%.', N'6 октантов');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'100%.', N'8 октант');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'20–30%.', N'2 октанта');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'60%.', N'5 октантов');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'Небо не видно из-за тумана и/или других метеорологических явлений.', N'Из-за атмосферных явлений небо не видно');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'50%.', N'4 октанта');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'10%  или менее, но не 0', N'Не более 1 октанта, но больше 0');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES (N'40%.', N'3 октанта');

-- Пользователди уровня приложения
INSERT INTO auth.RoleData(RoleName) VALUES ('Admin');
INSERT INTO auth.RoleData(RoleName) VALUES ('Moderator');
INSERT INTO auth.RoleData(RoleName) VALUES ('Customer');
INSERT INTO auth.RoleData(RoleName) VALUES ('Station');

CALL web.insert_user('Administrator', 'password', 1);
