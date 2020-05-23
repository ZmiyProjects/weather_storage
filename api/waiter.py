import socket
from time import sleep
import subprocess
from multiprocessing import cpu_count

from sqlalchemy import create_engine, sql
import config
from werkzeug.security import generate_password_hash
import os
import sys
sys.path.append(os.getcwd() + '/api')


if __name__ == '__main__':
    so = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    while True:
        try:
            so.connect(('db', 5432))
            so.close()
            break
        except socket.error:
            sleep(1)
    # subprocess.run(["python3", "api/app.py"])
    db = create_engine(config.Config.DATABASE_URI)

    if db.execute(sql.text('SELECT web.users_json()')).scalar() is None:
        with db.begin() as conn:
            query = sql.text('CALL web.insert_user(:user_login, :password, :role_id)')
            conn.execute(query, user_login='Administrator', password=generate_password_hash('password'), role_id=1)
        # UserData.insert(db, user_login='Administrator', password=generate_password_hash('password'), role_id=1)
    subprocess.run(f"exec gunicorn -b 0.0.0.0:8010 -w {(cpu_count() * 2) + 1} api.app:app", shell=True)
