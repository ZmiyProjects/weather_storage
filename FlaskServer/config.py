from urllib.parse import quote_plus


class Config:
    JSON_AS_ASCII = False
    JSON_SORT_KEYS = False
    DEBUG = True


class MSSQLConfig(Config):
    DATABASE_URI = "mssql+pyodbc:///?odbc_connect={}".format(quote_plus(
            'DRIVER={ODBC DRIVER 17 for SQL SERVER};SERVER=;DATABASE=Weather;UID=weather_user_login;PWD=WeatherUser1'))


class MSSQLConfigTest(Config):
    DATABASE_URI = "mssql+pyodbc:///?odbc_connect={}".format(quote_plus(
        'DRIVER={SQL Server};SERVER=DESKTOP-SC3F9ME\\NOLA2019;DATABASE=Shop;UID=sa;PWD=f2bd62f4'))
