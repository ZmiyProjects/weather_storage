-- Создание БД Weather
USE master
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
-- Возможго, стоит сделать "справочные" таблицы темпоральными

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
    PostalCode CHAR(8) NOT NULL,
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

-- Если уже существуют логин и пользователь БД с совпадающими названиями - они будут удалены
-- Проверка существования логина
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'weather_user_login')
    DROP LOGIN weather_user_login;

-- Проверка существования пользователя
IF DATABASE_PRINCIPAL_ID('weather_user') IS NOT NULL
    DROP USER weather_user;

-- Создание пользователей и ограничение доступа
CREATE LOGIN weather_user_login WITH PASSWORD = 'weatheruser';
CREATE USER weather_user FOR LOGIN weather_user_login;

-- Разрешиле weather_user только чтение в рамках схемы Static, прочие операции недоступны (проверено)
GRANT SELECT ON SCHEMA::Static TO weather_user;

-- Разрешает weather_user чтение, обновление, удаление записей а также вызов функций/процедув в рамках схемы Import
GRANT SELECT, UPDATE, DELETE, EXECUTE ON SCHEMA::Import TO weather_user;

-- НО, теперь нужно запретить weather_user удалять/обновлять записи в таблице Import.Registration

-- Оба варианта НЕ запрещают weather_user удалять/обновлять записи в Import.Registration (Почему?)
-- REVOKE UPDATE, DELETE ON OBJECT::Import.Registration TO weather_user;

-- Работает
DENY UPDATE, DELETE ON OBJECT::Import.Registration TO weather_user;

GO
-- Функции
-- Вернуть все известные направления ветра в соответствии с 16 румбовой системой
CREATE OR ALTER FUNCTION Import.get_all_wind_direction() RETURNS TABLE AS
    RETURN (
      SELECT WD.WindDirectionId, WD.Direction, WD.Mark FROM Static.WindDirection AS WD
    );
GO
-- Вернуть одно из значений направления ветра по идентификатору
CREATE OR ALTER FUNCTION Import.get_wind_direction(@WindDirectionId INT) RETURNS TABLE AS
    RETURN (
      SELECT WD.WindDirectionId, WD.Direction, WD.Mark FROM Static.WindDirection AS WD
           WHERE WD.WindDirectionId = @WindDirectionId
    );
GO
-- Вернуть все извстные состояния облачного покрова
CREATE OR ALTER FUNCTION Import.get_all_cloudiness() RETURNS TABLE AS
    RETURN (
      SELECT C.CloudinessId, C.CloudinessLevel, C.Octane FROM Static.Cloudiness AS C
    );
GO
-- Вернуть одно из значений облачности по идентификатору
CREATE OR ALTER FUNCTION Import.get_cloudiness(@CloudinessId INT) RETURNS TABLE AS
    RETURN (
      SELECT C.CloudinessId, C.CloudinessLevel, C.Octane FROM Static.Cloudiness AS C
           WHERE C.CloudinessId = @CloudinessId
    );

-- Хранимые процедуры
-- Вставка в БД сведений о одной стране из JSON (TotalArea вычисляется во время вставки)
GO
CREATE OR ALTER PROCEDURE Import.insert_country_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Country(CountryName, LandArea, WaterArea, TotalArea)
        SELECT
            J.CountryName,
            J.LandArea,
            J.WaterArea,
            J.WaterArea + J.LandArea AS TotalArea
        FROM OPENJSON(@json) WITH (
            CountryName VARCHAR(100),
            LandArea INT,
            WaterArea INT
        ) AS J;
    END;
GO

-- Вставка в БД сведений об одном регионе из JSON
CREATE OR ALTER PROCEDURE Import.insert_region_json(@json NVARCHAR(MAX), @CountryId INT) AS
    BEGIN
       INSERT INTO Import.Region(RegionName, CountryId)
       SELECT
           J.RegionName,
           @CountryId
       FROM OPENJSON(@json) WITH (
           RegionName VARCHAR(100)
       ) AS J
    END;
GO

-- Вставка в БД сведений об одном населённом пункте из JSON
CREATE OR ALTER PROCEDURE Import.insert_locality_json(@json NVARCHAR(MAX), @RegionId INT) AS
    BEGIN
        INSERT INTO Import.Locality(LocalityName, RegionId)
        SELECT
            J.LocalityName,
            @RegionId
        FROM OPENJSON(@json) WITH (
            LocalityName VARCHAR(100)
        ) AS J;
    END;
GO

-- Вставить сведения о одной организации
-- Добавить проверку наличия родительской организации и бросить исключение приее отсутствии!
CREATE OR ALTER PROCEDURE Import.insert_organization_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Organization(OrganizationName, Address, PostalCode, WebSite, LocalityId, ParentOrganizationId)
        SELECT
            J.OrganizationName, J.Address, J.PostalCode, J.WebSite, J.LocalityId, J.ParentOrganizationId
        FROM OPENJSON(@json) WITH (
            OrganizationName VARCHAR(255),
            Address VARCHAR(255),
            PostalCode CHAR(8),
            WebSite VARCHAR(255),
            LocalityId INT,
            ParentOrganizationId INT
        ) AS J;
    END;
GO

-- Вставить сведения об одной станциии
CREATE OR ALTER PROCEDURE Import.insert_station_json(@json NVARCHAR(MAX)) AS
    BEGIN
        INSERT INTO Import.Station(StationName, Latitude, Longitude, Height, RegionId, OrganizationId)
        SELECT
            J.StationName, J.Latitude, J.Longitude, J.Height, J.RegionId, J.OrganizationId
        FROM OPENJSON(@json) WITH (
            StationName VARCHAR(255),
            Latitude NUMERIC(5, 2),
            Longitude NUMERIC(5, 2),
            Height SMALLINT,
            RegionId INT,
            OrganizationId INT
        ) AS J;
    END;
GO

-- Регистрация набора метеорологических показателей
CREATE OR ALTER PROCEDURE Import.insert_registration_json(@json NVARCHAR(MAX), @StationId INT) AS
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
    END;
GO

-- Удаление страны с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Import.delete_country(@CountryId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Country WHERE CountryId = @CountryId)
            THROW 51002, N'Страна с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Country WHERE CountryId = @CountryId;
    END

	GO
-- Удаление региона с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Import.delete_region(@RegionId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Region WHERE RegionId = @RegionId)
            THROW 51003, N'Регион с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Region WHERE RegionId = @RegionId;
    END

GO
-- Удаление населённого пункта с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Import.delete_locality(@LocalityId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Locality WHERE LocalityId = @LocalityId)
            THROW 51004, N'Населённый пункт с заданным идентификатором отсутствует!', 11;
        ELSE
            DELETE FROM Import.Locality WHERE LocalityId = @LocalityId;
    END

GO
-- Удаление организации с проверкой наличия в БД, если страна отсутствует будет вызвано исключение
CREATE PROCEDURE Import.delete_organization(@OrganizationId INT) AS
    BEGIN
        IF NOT EXISTS(SELECT * FROM Import.Organization WHERE OrganizationId = @OrganizationId)
            THROW 51005, N'Организация с заданным идентификатором отсутствует!', 12;
        ELSE
            DELETE FROM Import.Organization WHERE OrganizationId = @OrganizationId;
    END

--Обновляет сведения о стране
GO
CREATE OR ALTER PROCEDURE Import.update_country(@json NVARCHAR(MAX), @CointryId INT) AS
BEGIN
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
	WHERE CountryId = @CointryId
END

-- Триггер для автомитическогог вычисления суммарной площади страны
GO
CREATE TRIGGER Import.calculate_total ON Import.Country AFTER UPDATE, INSERT AS
    BEGIN
	    SET NOCOUNT ON;
        UPDATE Import.Country SET
            TotalArea = I.LandArea + I.WaterArea
        FROM inserted AS I WHERE I.CountryId = Country.CountryId;
    END
GO


-- Заполнение статических таблиц
-- Направление ветра
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с западо-юго-запада', 'ЗЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с запада', 'З');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с юго-юго-запада', 'ЮЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с северо-запада', 'СЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с северо-северо-запада', 'ССЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с юго-запада', 'ЮЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с юга', 'Ю');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с юго-юго-востока', 'ЮЮВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с юго-востока', 'ЮВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Штиль, безветрие', 'Штиль');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с северо-северо-востока', 'ССВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с севера', 'С');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с северо-востока', 'СВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с востоко-северо-востока', 'ВСВ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с востока', 'В');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с западо-северо-запада', 'ЗСЗ');
INSERT INTO Static.WindDirection(Direction, Mark) VALUES ('Ветер, дующий с востоко-юго-востока', 'ВЮВ');

-- Облачность
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('Облаков нет.', '0');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('90  или более, но не 100%', 'Не более 8 и не менее 7 октант');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('70 – 80%.', '6 октантов');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('100%.', '8 октант');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('20–30%.', '2 октанта');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('60%.', '5 октантов');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('Небо не видно из-за тумана и/или других метеорологических явлений.', 'Из-за атмосферных явлений небо не видно');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('50%.', '4 октанта');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('10%  или менее, но не 0', 'Не более 1 октанта, но больше 0');
INSERT INTO Static.Cloudiness(CloudinessLevel, Octane) VALUES ('40%.', '3 октанта');
