import pandas as pd
import sqlite3

# читаем csv
df = pd.read_csv("fraud_dataset.csv")

# подключаемся к базе
conn = sqlite3.connect("fraud.db")

# записываем в таблицу
df.to_sql("transactions", conn, if_exists="replace", index=False)

conn.close()
