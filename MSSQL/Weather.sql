-- Создание БД Weather
USE master
GO
IF DB_ID('Weather') IS NOT NULL
    DROP DATABASE Weather
GO

CREATE DATABASE Weather
GO
USE Weather
GO

-- Создание схем
CREATE SCHEMA Import
GO
CREATE SCHEMA Static
GO
CREATE SCHEMA Agg
GO
CREATE SCHEMA Auth
GO

-- схема Web предназначена в качестве пространства имен для функций/процедур вызываемых со стороны веб-сервиса
CREATE SCHEMA Web;
GO

CREATE TABLE Auth.RoleData(
    RoleId INT PRIMARY KEY IDENTITY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Auth.UserData(
    UserId INT PRIMARY KEY IDENTITY,
    UserLogin VARCHAR(30) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RegistrationDate DATETIME NOT NULL DEFAULT GETDATE(),
    RoleId INT NOT NULL REFERENCES Auth.RoleData(RoleId)
);

-- Создание таблиц "только для чтения" в схеме Static
CREATE TABLE Static.WindDirection(
    WindDirectionId INT PRIMARY KEY IDENTITY,
    Direction VARCHAR(100) UNIQUE NOT NULL,
    Mark VARCHAR(5) UNIQUE NOT NULL
);

CREATE TABLE Static.Cloudiness(
    CloudinessId INT PRIMARY KEY IDENTITY,
    CloudinessLevel VARCHAR(100) NOT NULL UNIQUE,
    Octane VARCHAR(50) NOT NULL UNIQUE
);

-- Создание таблиц в схеме Import
-- Возможо, стоит сделать "справочные" таблицы темпоральными

-- TotalArea - сумма LandArea и WaterArea
CREATE TABLE Import.Country(
    CountryId INT PRIMARY KEY IDENTITY,
    CountryName VARCHAR(100) UNIQUE NOT NULL,
    LandArea INT NOT NULL,
    WaterArea INT NOT NULL,
    TotalArea INT NULL
);

CREATE TABLE Import.Region(
    RegionId INT PRIMARY KEY IDENTITY,
    RegionName VARCHAR(100) UNIQUE NOT NULL,
    CountryId INT NOT NULL REFERENCES Import.Country(CountryId)
);

CREATE TABLE Import.Locality(
    LocalityId INT PRIMARY KEY IDENTITY,
    LocalityName VARCHAR(100) UNIQUE NOT NULL,
    RegionId INT NOT NULL REFERENCES Import.Region(RegionId)
);

CREATE TABLE Import.Organization(
    OrganizationId INT PRIMARY KEY IDENTITY,
    OrganizationName VARCHAR(255) UNIQUE NOT NULL,
    Address VARCHAR(255) NOT NULL,
    WebSite VARCHAR(255) NULL,
    LocalityId INT NOT NULL REFERENCES Import.Locality(LocalityId),
    ParentOrganizationId INT REFERENCES Import.Organization(OrganizationId)
);

CREATE TABLE Import.Station(
    StationId INT PRIMARY KEY IDENTITY,
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
    RegistrationDate DATETIME NOT NULL,
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
    RegistrationDate SMALLDATETIME,
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
    RegistrationDate SMALLDATETIME,
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

-- Если уже существуют логин и пользователь БД с совпадающими названиями - они будут удалены
-- Проверка существования логина
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'weather_user_login')
    DROP LOGIN weather_user_login;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'weather_moderator')
    DROP LOGIN weather_moderator;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'weather_customer')
    DROP LOGIN weather_customer;

-- Создание пользователей и ролей уровля базы данных
CREATE ROLE WeatherModerator;
CREATE ROLE WeatherCustomer;

-- Роль для работы от имени веб-сервиса
CREATE ROLE WebUser;

-- Создание пользователей и ограничение доступа
CREATE LOGIN weather_user_login WITH PASSWORD = 'WeatherUser1', DEFAULT_DATABASE = Weather;
CREATE LOGIN weather_moderator WITH PASSWORD = 'WeatherUser1', DEFAULT_DATABASE = Weather;
CREATE LOGIN weather_customer WITH PASSWORD = 'WeatherUser1', DEFAULT_DATABASE = Weather;

CREATE USER weather_user FOR LOGIN weather_user_login;
CREATE USER weather_moderator FOR LOGIN weather_moderator;
CREATE USER weather_customer FOR LOGIN weather_customer;

ALTER ROLE WebUser ADD MEMBER weather_user;
ALTER ROLE WeatherModerator ADD MEMBER weather_moderator;
ALTER ROLE WeatherCustomer ADD MEMBER weather_customer;

GRANT EXECUTE ON SCHEMA::Web TO WebUser;

-- Разрешиле weather_user только чтение в рамках схемы Static, прочие операции недоступны
GRANT SELECT ON SCHEMA::Static TO WeatherModerator;

-- Разрешает WeatherModerator чтение, обновление, удаление записей а также вызов функций/процедув в рамках схемы Import
GRANT SELECT, UPDATE, DELETE, EXECUTE ON SCHEMA::Import TO WeatherModerator;
-- Работает
DENY UPDATE, DELETE ON OBJECT::Import.Registration TO WeatherModerator;

-- Разрешает weather_user запись, чтение и запуск хранимых процедур в схеме Agg
GRANT INSERT, SELECT, EXECUTE ON SCHEMA::Agg TO WeatherModerator;

GRANT SELECT ON SCHEMA::Static TO WeatherCustomer;
GRANT SELECT ON SCHEMA::Import TO WeatherCustomer;
GRANT SELECT ON SCHEMA::Agg TO WeatherCustomer;

-- Хранимые процедуры

GO
CREATE OR ALTER FUNCTION Web.users_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT U.UserId, U.UserLogin, U.RegistrationDate, R.RoleId, R.RoleName FROM Auth.UserData AS U
            JOIN Auth.RoleData R on U.RoleId = R.RoleId
        FOR JSON PATH
        );
END
GO
CREATE OR ALTER FUNCTION Web.one_user_json(@UserId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT U.UserId, U.UserLogin, U.RegistrationDate, R.RoleId, R.RoleName FROM Auth.UserData AS U
            JOIN Auth.RoleData AS R on U.UserId = @UserId AND U.RoleId = R.RoleId
        FOR JSON PATH
        );
END
GO
CREATE OR ALTER PROCEDURE Web.insert_user(@UserLogin VARCHAR(30), @Password VARCHAR(50), @RoleId INT) AS
    BEGIN
        INSERT INTO Auth.UserData(UserLogin, PasswordHash, RoleId) VALUES (@UserLogin, HASHBYTES('SHA2_256', @Password), @RoleId);
    END
GO
CREATE OR ALTER FUNCTION Web.roles_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT R.RoleId, R.RoleName, COUNT(U.UserId) AS RoleCount FROM Auth.RoleData AS R
            LEFT JOIN Auth.UserData AS U on R.RoleId = U.RoleId
        GROUP BY R.RoleId, R.RoleName
        FOR JSON PATH
        );
END
GO

CREATE OR ALTER PROCEDURE Web.delete_user(@UserId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId)
            THROW 51009, N'Пользователь не существует!', 11;
        DELETE FROM Auth.UserData WHERE UserId = @UserId;
    END
GO
CREATE OR ALTER FUNCTION Web.init_user(@UserName VARCHAR(50)) RETURNS VARCHAR(50) AS
    BEGIN
        RETURN (
            SELECT R.RoleName FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.RoleId = R.RoleId AND U.UserLogin = @UserName
            );
    END
GO
CREATE OR ALTER PROCEDURE Web.update_user_json(@json NVARCHAR(MAX), @UserId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId)
        THROW 51002, N'Пользователь с заданным идентификатором отсутствует!', 11;
    UPDATE Auth.UserData SET
	    UserLogin = COALESCE(T.JUserLogin, UserLogin),
		PasswordHash = COALESCE(HASHBYTES('SHA2_256', T.JPassword), PasswordHash),
		RoleId = COALESCE(T.JRoleId, RoleId)
	FROM (
	    SELECT J.UserLogin AS JUserLogin, J.Password AS JPassword, J.RoleId As JRoleId
		FROM OPENJSON(@json) WITH (
		    UserLogin VARCHAR(50),
			Password VARCHAR(30),
			RoleId INT
		) AS J
	) AS T
	WHERE UserId = @UserId;
END
GO

CREATE OR ALTER PROCEDURE Web.update_user
    @UserId INT = NULL,
    @NewLogin VARCHAR(30) = NULL,
    @NewPassword VARCHAR(50) = NULL,
    @RoleId INT = NULL
AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Auth.UserData WHERE UserId = @UserId)
            THROW 51009, N'Пользователь не существует!', 11;
        ELSE
            UPDATE Auth.UserData SET
                UserLogin = COALESCE(@NewLogin, UserLogin),
                PasswordHash = COALESCE(HASHBYTES('SHA2_256', @NewPassword), PasswordHash),
                RoleId = COALESCE(@RoleId, RoleId)
            WHERE UserId = @UserId;
    END
GO

CREATE OR ALTER FUNCTION Web.select_user(@UserId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
            SELECT U.UserLogin, R.RoleName FROM Auth.UserData AS U
                JOIN Auth.RoleData AS R ON U.RoleId = R.RoleId AND U.UserId = @UserId
            FOR JSON PATH
            );
    END
GO

CREATE OR ALTER FUNCTION Web.check_password(@UserName VARCHAR(30), @Password VARCHAR(50)) RETURNS BIT AS
BEGIN
    IF EXISTS(SELECT * FROM Auth.UserData WHERE UserLogin = @UserName)
        IF HASHBYTES('SHA2_256', @Password) = (SELECT PasswordHash FROM Auth.UserData WHERE UserLogin = @UserName)
		    RETURN 1;
		ELSE
		  RETURN 0;
    RETURN 0;
END
GO

-- Вставка в БД сведений о одной стране из JSON (TotalArea вычисляется во время вставки)
GO
CREATE OR ALTER PROCEDURE Web.insert_country_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Country(CountryName, LandArea, WaterArea, TotalArea)
        SELECT
            J.CountryName,
            J.LandArea,
            J.WaterArea,
            J.WaterArea + J.LandArea AS TotalArea
        FROM OPENJSON(@json) WITH (
            CountryName VARCHAR(100) '$.CountryName',
            LandArea INT '$.LandArea',
            WaterArea INT '$.WaterArea'
        ) AS J;
    END;
GO

-- Вставка в БД сведений об одном регионе из JSON
CREATE OR ALTER PROCEDURE Web.insert_region_json(@json NVARCHAR(MAX), @CountryId INT) AS
    BEGIN
       INSERT INTO Import.Region(RegionName, CountryId)
       SELECT
           J.RegionName,
           @CountryId
       FROM OPENJSON(@json) WITH (
           RegionName VARCHAR(100) '$.RegionName'
       ) AS J
    END;
GO

-- Вставка в БД сведений об одном населённом пункте из JSON
CREATE OR ALTER PROCEDURE Web.insert_locality_json(@json NVARCHAR(MAX), @RegionId INT) AS
    BEGIN
        INSERT INTO Import.Locality(LocalityName, RegionId)
        SELECT
            J.LocalityName,
            @RegionId
        FROM OPENJSON(@json) WITH (
            LocalityName VARCHAR(100) '$.LocalityName'
        ) AS J;
    END;
GO

-- Вставить сведения о одной организации
-- Добавить проверку наличия родительской организации и бросить исключение приее отсутствии!
CREATE OR ALTER PROCEDURE Web.insert_organization_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Organization(OrganizationName, Address, WebSite, LocalityId, ParentOrganizationId)
        SELECT
            J.OrganizationName, J.Address, J.WebSite, J.LocalityId, J.ParentOrganizationId
        FROM OPENJSON(@json) WITH (
            OrganizationName VARCHAR(255) '$.OrganizationName',
            Address VARCHAR(255) '$.Address',
            WebSite VARCHAR(255) '$.WebSite',
            LocalityId INT '$.LocalityId',
            ParentOrganizationId INT '$.ParentOrganizationId'
        ) AS J;
    END;
GO

-- Вставить сведения об одной станциии
CREATE OR ALTER PROCEDURE Web.insert_station_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Station(StationName, Latitude, Longitude, Height, RegionId, OrganizationId)
        SELECT
            J.StationName, J.Latitude, J.Longitude, J.Height, J.RegionId, J.OrganizationId
        FROM OPENJSON(@json) WITH (
            StationName VARCHAR(255) '$.StationName',
            Latitude NUMERIC(5, 2) '$.Latitude',
            Longitude NUMERIC(5, 2) '$.Longitude',
            Height SMALLINT '$.Height',
            RegionId INT '$.RegionId',
            OrganizationId INT '$.OrganizationId'
        ) AS J;
    END;
GO

-- агрегация зарегистрированных данных
CREATE PROCEDURE Web.agg_values_json(@json NVARCHAR(MAX), @StationId INT) AS
    BEGIN
        -- Месяцы
        INSERT INTO Agg.Months(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            @StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS [Date],
	        AVG(R.Temperature) AS [TAvg], MAX(R.Temperature) AS [TMax], MIN(R.Temperature) AS [TMin],
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM OPENJSON(@json) WITH (
             StationId INT '$.StationId',
             RegistrationDate DATE '$.RegistrationDate',
             Temperature NUMERIC(5, 2) '$.Temperature',
             DewPoint NUMERIC(5, 2) '$.DewPoint',
             Pressure NUMERIC(6, 2) '$.Pressure',
             PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
             Humidity NUMERIC(5, 2) '$.Humidity',
             VisibleRange NUMERIC(6, 2) '$.VisibleRange',
             WindSpeed NUMERIC(5, 2) '$.WindSpeed'
        ) AS R
        GROUP BY R.StationId, YEAR(R.RegistrationDate), MONTH(R.RegistrationDate);

        -- Недели
        INSERT INTO Agg.Weeks(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            @StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS [Date],
	        AVG(R.Temperature) AS [TAvg], MAX(R.Temperature) AS [TMax], MIN(R.Temperature) AS [TMin],
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM OPENJSON(@json) WITH (
             RegistrationDate DATE '$.RegistrationDate',
             Temperature NUMERIC(5, 2) '$.Temperature',
             DewPoint NUMERIC(5, 2) '$.DewPoint',
             Pressure NUMERIC(6, 2) '$.Pressure',
             PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
             Humidity NUMERIC(5, 2) '$.Humidity',
             VisibleRange NUMERIC(6, 2) '$.VisibleRange',
             WindSpeed NUMERIC(5, 2) '$.WindSpeed'
        ) AS R
        GROUP BY YEAR(R.RegistrationDate), DATEPART(Week, (R.RegistrationDate));
        -- Дни
        INSERT INTO Agg.Days(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            @StationId, MAX(CAST(R.RegistrationDate AS DATE)) AS [Date],
	        AVG(R.Temperature) AS [TAvg], MAX(R.Temperature) AS [TMax], MIN(R.Temperature) AS [TMin],
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM OPENJSON(@json) WITH (
             RegistrationDate DATE '$.RegistrationDate',
             Temperature NUMERIC(5, 2) '$.Temperature',
             DewPoint NUMERIC(5, 2) '$.DewPoint',
             Pressure NUMERIC(6, 2) '$.Pressure',
             PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
             Humidity NUMERIC(5, 2) '$.Humidity',
             VisibleRange NUMERIC(6, 2) '$.VisibleRange',
             WindSpeed NUMERIC(5, 2) '$.WindSpeed'
        ) AS R
        GROUP BY YEAR(R.RegistrationDate), MONTH(R.RegistrationDate),  DAY(R.RegistrationDate);
        -- 12 часов
        INSERT INTO Agg.Hours12(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            @StationId, MAX(SMALLDATETIMEFROMPARTS(YEAR(R.RegistrationDate), MONTH(R.RegistrationDate),
            DAY(R.RegistrationDate), Import.hours_12(R.RegistrationDate),0)) AS [Date],
	        AVG(R.Temperature) AS [TAvg], MAX(R.Temperature) AS [TMax], MIN(R.Temperature) AS [TMin],
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM OPENJSON(@json) WITH (
             RegistrationDate DATE '$.RegistrationDate',
             Temperature NUMERIC(5, 2) '$.Temperature',
             DewPoint NUMERIC(5, 2) '$.DewPoint',
             Pressure NUMERIC(6, 2) '$.Pressure',
             PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
             Humidity NUMERIC(5, 2) '$.Humidity',
             VisibleRange NUMERIC(6, 2) '$.VisibleRange',
             WindSpeed NUMERIC(5, 2) '$.WindSpeed'
        ) AS R
        GROUP BY YEAR(R.RegistrationDate), MONTH(R.RegistrationDate),  DAY(R.RegistrationDate), Import.hours_12(R.RegistrationDate);
        -- 6 часов
        INSERT INTO Agg.Hours6(
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN,
            DewPointAVG, DewPointMAX, DewPointMIN, PressureAVG, PressureMAX, PressureMIN,
            PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN, HumidityAVG, HumidityMAX, HumidityMIN,
            VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN)
        SELECT
            @StationId, MAX(SMALLDATETIMEFROMPARTS(YEAR(R.RegistrationDate), MONTH(R.RegistrationDate),
            DAY(R.RegistrationDate), Import.hours_6(R.RegistrationDate),0)) AS [Date],
	        AVG(R.Temperature) AS [TAvg], MAX(R.Temperature) AS [TMax], MIN(R.Temperature) AS [TMin],
	        AVG(R.DewPoint), MAX(R.DewPoint), MIN(R.DewPoint),
	        AVG(R.Pressure), MAX(R.Pressure), MIN(R.Pressure),
	        AVG(R.PressureStationLevel), MAX(R.PressureStationLevel), MIN(R.PressureStationLevel),
	        AVG(R.Humidity), MAX(R.Humidity), MIN(R.Humidity),
	        AVG(R.VisibleRange), MAX(R.VisibleRange), MIN(R.VisibleRange),
	        AVG(R.WindSpeed), MAX(R.WindSpeed), MIN(R.WindSpeed)
        FROM OPENJSON(@json) WITH (
             RegistrationDate DATE '$.RegistrationDate',
             Temperature NUMERIC(5, 2) '$.Temperature',
             DewPoint NUMERIC(5, 2) '$.DewPoint',
             Pressure NUMERIC(6, 2) '$.Pressure',
             PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
             Humidity NUMERIC(5, 2) '$.Humidity',
             VisibleRange NUMERIC(6, 2) '$.VisibleRange',
             WindSpeed NUMERIC(5, 2) '$.WindSpeed'
        ) AS R
        GROUP BY YEAR(R.RegistrationDate), MONTH(R.RegistrationDate),  DAY(R.RegistrationDate), Import.hours_6(R.RegistrationDate);
    END
GO

-- Регистрация набора метеорологических показателей
CREATE OR ALTER PROCEDURE Web.insert_registration_json(@json NVARCHAR(MAX), @StationId INT) AS
    BEGIN
        INSERT INTO Import.Registration(StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
                                        Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId)
        SELECT
            @StationId,
            J.RegistrationDate, J.Temperature, J.DewPoint, J.Pressure, J.PressureStationLevel, J.Humidity, J.VisibleRange,
            J.WindSpeed, J.Weather, J.WindDirectionId, J.CloudinessId
        FROM OPENJSON(@json) WITH (
            RegistrationDate DATETIME '$.RegistrationDate',
            Temperature NUMERIC(5, 2) '$.Temperature',
            DewPoint NUMERIC(5, 2) '$.DewPoint',
            Pressure NUMERIC(6, 2) '$.Pressure',
            PressureStationLevel NUMERIC(6, 2) '$.PressureStationLevel',
            Humidity NUMERIC(5, 2) '$.Humidity',
            VisibleRange NUMERIC(6, 2) '$.VisibleRange',
            WindSpeed NUMERIC(5, 2) '$.WindSpeed',
            Weather VARCHAR(255) '$.Weather',
            WindDirectionId INT '$.WindDirectionId',
            CloudinessId INT  '$.CloudinessId'
        ) AS J;

        EXEC Web.agg_values_json @json = @json, @StationId = @StationId;
    END;
GO

-- Удаление страны с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_country(@CountryId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = @CountryId)
            THROW 51002, N'Страна с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Country WHERE CountryId = @CountryId;
    END

	GO
-- Удаление региона с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_region(@RegionId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId)
            THROW 51003, N'Регион с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Region WHERE RegionId = @RegionId;
    END

GO
-- Удаление населённого пункта с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_locality(@LocalityId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId)
            THROW 51004, N'Населённый пункт с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Locality WHERE LocalityId = @LocalityId;
    END

GO
-- Удаление организации с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_organization(@OrganizationId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Organization WHERE OrganizationId = @OrganizationId)
            THROW 51005, N'Организация с заданным идентификатором отсутствует!', 12;
        ELSE
            DELETE FROM Import.Organization WHERE OrganizationId = @OrganizationId;
    END
GO

-- Удаление метеостанции с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Web.delete_station(@StationId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = @StationId)
            THROW 51006, N'Организация с заданным идентификатором отсутствует!', 12;
        ELSE
            DELETE FROM Import.Station WHERE StationId = @StationId;
    END

--Обновляет сведения о стране
GO
CREATE OR ALTER PROCEDURE Web.update_country(@json NVARCHAR(MAX), @CountryId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = @CountryId)
        THROW 51002, N'Страна с заданным идентификатором отсутствует!', 11;
    UPDATE Import.Country SET
	    CountryName = COALESCE(T.JCountyName, CountryName),
		LandArea = COALESCE(T.JLandArea, LandArea),
		WaterArea = COALESCE(T.JWaterArea, WaterArea)
	FROM (
	    SELECT J.CountryName AS JCountyName, J.LandArea AS JLandArea, J.WaterArea As JWaterArea
		FROM OPENJSON(@json) WITH (
		    CountryName VARCHAR(100),
			LandArea INT,
			WaterArea INT
		) AS J
	) AS T
	WHERE CountryId = @CountryId
END

GO
-- Обновляет сведения о регионе
CREATE OR ALTER PROCEDURE Web.update_region(@json NVARCHAR(MAX), @RegionId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId)
        THROW 51003, N'Регион с заданным идентификатором отсутствует!', 11;
    UPDATE Import.Region SET
	    RegionName = COALESCE(T.JRegionName, RegionName),
		CountryId = COALESCE(T.JCountryId, CountryId)
	FROM (
	    SELECT J.RegionName AS JRegionName, J.CountryId AS JCountryId
		FROM OPENJSON(@json) WITH (
		    RegionName VARCHAR(100),
			CountryId INT
		) AS J
	) AS T
	WHERE RegionId = @RegionId
END

GO
-- Обновляет сведения о населенном пункте
CREATE OR ALTER PROCEDURE Web.update_locality(@json NVARCHAR(MAX), @LocalityId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId)
        THROW 51004, N'Населённый пункт с заданным идентификатором отсутствует!', 11;
    UPDATE Import.Locality SET
	    LocalityName = COALESCE(T.JLocalityName, LocalityName),
	    RegionId = COALESCE(T.JRegionId, RegionId)
	FROM (
	    SELECT J.LocalityName AS JLocalityName, J.RegionId AS JRegionId
		FROM OPENJSON(@json) WITH (
		    LocalityName VARCHAR(100),
			RegionId INT
		) AS J
	) AS T
	WHERE LocalityId = @LocalityId
END

GO
-- Обновление сведений о организации
CREATE OR ALTER PROCEDURE Web.update_organization(@json NVARCHAR(MAX), @OrganizationId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Organization WHERE OrganizationId = @OrganizationId)
        THROW 51005, N'Организация с заданным идентификатором отсутствует!', 12;
    UPDATE Import.Organization SET
	    OrganizationName = COALESCE(T.JOrganizationName, OrganizationName),
	    Address = COALESCE(T.JAddress, Address),
        WebSite = COALESCE(T.JWebSite, WebSite),
        LocalityId = COALESCE(T.JLocalityId, LocalityId),
        ParentOrganizationId = COALESCE(T.JParentOrganizationId, ParentOrganizationId)
	FROM (
	    SELECT J.OrganizationName AS JOrganizationName, J.Address AS JAddress,
	           J.WebSite AS JWebSite, J.LocalityId AS JLocalityId, J.ParentOrganizationId AS JParentOrganizationId
		FROM OPENJSON(@json) WITH (
		    OrganizationName VARCHAR(255),
			Address VARCHAR(255),
		    WebSite VARCHAR(255),
		    LocalityId INT,
		    ParentOrganizationId INT
		) AS J
	) AS T
	WHERE OrganizationId = @OrganizationId
END

GO
-- Обновление сведений о станции
CREATE OR ALTER PROCEDURE Web.update_station(@json NVARCHAR(MAX), @StationId INT) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = @StationId)
        THROW 51006, N'Организация с заданным идентификатором отсутствует!', 12;
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
		FROM OPENJSON(@json) WITH (
		    StationName VARCHAR(255),
			Latitude NUMERIC(5, 2),
		    Longitude NUMERIC(5, 2),
		    Height SMALLINT,
		    RegionId INT,
		    OrganizationId INT
		) AS J
	) AS T
	WHERE StationId = @StationId
END
GO

-- Триггер для автомитического вычисления суммарной площади страны
CREATE TRIGGER Import.calculate_total ON Import.Country AFTER UPDATE, INSERT AS
    BEGIN
	    SET NOCOUNT ON;
        UPDATE Import.Country SET
            TotalArea = I.LandArea + I.WaterArea
        FROM inserted AS I WHERE I.CountryId = Country.CountryId;
    END
GO

-- Функции возвращающие содержимое таблиц в формаье JSON

-- Получить все страны
CREATE FUNCTION Web.country_json() RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
            SELECT C.CountryId, C.CountryName, C.LandArea, C.WaterArea, C.TotalArea FROM Import.Country AS C
            FOR JSON PATH
            );
    END
GO

-- Вернуть сведение о стране по идентификатору
CREATE FUNCTION Web.one_country_json(@CountryId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = @CountryId)
        RETURN NULL;
    RETURN (
        SELECT C.CountryId, C.CountryName, C.LandArea, C.WaterArea, C.TotalArea FROM Import.Country AS C
        WHERE CountryId = @CountryId
        FOR JSON PATH
        );
END

GO
-- получить все регионы
CREATE FUNCTION Web.region_json() RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT RegionId, RegionName, CountryId FROM Import.Region
        FOR JSON PATH
        );
   END

GO
-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_region_json(@RegionId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId)
        RETURN NULL;
    RETURN (
        SELECT RegionId, RegionName, CountryId FROM Import.Region
        WHERE RegionId = @RegionId
        FOR JSON PATH
        );
END

GO
-- получить все населенные пункты
CREATE FUNCTION Web.locality_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT LocalityId, LocalityName, RegionId FROM Import.Locality
        FOR JSON PATH
        );
END
GO

-- Получить сведения о регионе по идентификатору
CREATE FUNCTION Web.one_locality_json(@LocalityId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId)
        RETURN NULL;
    RETURN (
        SELECT LocalityId, LocalityName, RegionId FROM Import.Locality
        WHERE LocalityId = @LocalityId
        FOR JSON PATH
        );
END
GO

-- получить все станции
CREATE FUNCTION Web.station_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT StationId, StationName, Latitude, Longitude, Height, RegionId, OrganizationId FROM Import.Station
        FOR JSON PATH
        );
END
GO

-- Получить сведения о станции по идентификатору
CREATE FUNCTION Web.one_station_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Import.Station WHERE StationId = @StationId)
        RETURN NULL;
    RETURN (
        SELECT StationId, StationName, Latitude, Longitude, Height, RegionId, OrganizationId FROM Import.Station
        WHERE StationId = @StationId
        FOR JSON PATH
        );
END
GO

-- Получить все организации
CREATE FUNCTION Web.organization_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT OrganizationId, OrganizationName, Address, WebSite, LocalityId, ParentOrganizationId FROM Import.Organization
        FOR JSON PATH
        );
END
GO

-- Получить сведения о организации по идентификатору
CREATE FUNCTION Web.one_organization_json(@OrganizationId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT OrganizationId, OrganizationName, Address, WebSite, LocalityId, ParentOrganizationId FROM Import.Organization
        WHERE OrganizationId = @OrganizationId
        FOR JSON PATH
        );
END
GO

-- Получить зарегистрированные на метеостанции данные в формате JSON
CREATE FUNCTION Web.registration_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT
           StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
           Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId
        FROM Import.Registration
        WHERE StationId = @StationId
        FOR JSON PATH
        );
END
GO

-- Получить зарегистрированные на метеостанции данные в заданном диапозоне в формате JSON
CREATE FUNCTION Web.registration_diapason_json(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
BEGIN
     RETURN (
        SELECT
           StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
           Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId
        FROM Import.Registration
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end
        FOR JSON PATH
         );
END
GO

-- Получить метеоданные, агрегированные за месяц
CREATE FUNCTION Web.months_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Months
        WHERE StationId = @StationId FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за месяц в заданном диапозоне
CREATE FUNCTION Web.months_json_diapason(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Months
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за неделю
CREATE FUNCTION Web.weeks_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Weeks
        WHERE StationId = @StationId FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за неделю в заданном диапозоне
CREATE FUNCTION Web.weeks_json_diapason(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Weeks
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за день
CREATE FUNCTION Web.days_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Days
        WHERE StationId = @StationId FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за день в заданном диапозоне
CREATE FUNCTION Agg.days_json_diapason(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Days
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за 12 часов
CREATE FUNCTION Web.hours12_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Hours12
        WHERE StationId = @StationId FOR JSON PATH);
    END
GO
-- Получить метеооданные, агрегированные за 12 часов в заданном диапозоне
CREATE FUNCTION Web.hours12_json_diapason(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Hours12
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end FOR JSON PATH);
    END
GO
-- Получить метеоданные, агрегированные за 6 часов
CREATE FUNCTION Web.hours6_json(@StationId INT) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Hours6
        WHERE StationId = @StationId FOR JSON PATH);
    END
GO
-- Получить метеооданные, агрегированные за 6 часов в заданном диапозоне
CREATE FUNCTION Web.hours6_json_diapason(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
    BEGIN
        RETURN (
        SELECT
            StationId, RegistrationDate, TemperatureAVG, TemperatureMAX, TemperatureMIN, DewPointAVG, DewPointMAX, DewPointMIN,
            PressureAVG, PressureMAX, PressureMIN, PressureStationLevelAVG, PressureStationLevelMAX, PressureStationLevelMIN,
            HumidityAVG, HumidityMAX, HumidityMIN, VisibleRangeAVG, VisibleRangeMAX, VisibleRangeMIN, WindSpeedAVG, WindSpeedMAX, WindSpeedMIN
        FROM Agg.Hours6
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end FOR JSON PATH);
    END
GO

-- Получить зарегистрированные на метеостанции данные в формате XML
CREATE OR ALTER FUNCTION Web.registration_xml(@StationId INT) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT
           StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
           Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId
        FROM Import.Registration
        WHERE StationId = @StationId
        FOR XML PATH, root('Registration')
        );
END

GO
-- Получить зарегистрированные на метеостанции данные в заданном диапозоне в формате XML
CREATE OR ALTER FUNCTION Web.registration_diapason_xml(@StationId INT, @d_begin DATETIME, @d_end DATETIME) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT
           StationId, RegistrationDate, Temperature, DewPoint, Pressure, PressureStationLevel,
           Humidity, VisibleRange, WindSpeed, Weather, WindDirectionId, CloudinessId
        FROM Import.Registration
        WHERE StationId = @StationId AND RegistrationDate BETWEEN @d_begin AND @d_end
        FOR XML PATH, root('Registration')
        );
END
GO

-- Получить содержание справочника облачности
CREATE FUNCTION Web.get_cloudiness_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT CloudinessId, CloudinessLevel, Octane FROM Static.Cloudiness
        FOR JSON PATH
        );
END

GO

-- Получить содержание справочника направлений ветра
CREATE FUNCTION Web.get_wind_direction_json() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
        SELECT WindDirectionId, Direction, Mark FROM Static.WindDirection
        FOR JSON PATH
        );
END
GO

GO
CREATE FUNCTION Web.hours_12(@RegDate DATETIME) RETURNS INT AS
BEGIN
    RETURN CASE  WHEN DATEPART(HOUR, @RegDate) BETWEEN 1 AND 12 THEN 12 ELSE 0 END
END
GO
CREATE FUNCTION Web.hours_6(@RegDate DATETIME) RETURNS INT AS
BEGIN
    RETURN
	  CASE
	    WHEN DATEPART(HOUR, @RegDate) BETWEEN 1 AND 6 THEN 6
		WHEN DATEPART(HOUR, @RegDate) BETWEEN 7 AND 12 THEN 12
		WHEN DATEPART(HOUR, @RegDate) BETWEEN 13 AND 18 THEN 18
	    ELSE 0
	  END
END
GO
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

EXEC web.insert_user 'Administrator', 'password', 1;
