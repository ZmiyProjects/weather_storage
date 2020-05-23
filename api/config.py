class Config:
    JSON_AS_ASCII = False
    JSON_SORT_KEYS = False
    DEBUG = True
    POSTGRES_USER = 'weather_user'
    POSTGRES_PASSWORD = 'WeatherUser1'
    POSTGRES_DB = 'weather_db'
    DATABASE_URI = f"postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}@db:5432/{POSTGRES_DB}"
