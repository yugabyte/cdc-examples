import argparse
import os
import random
import psycopg2
from faker import Faker
from user_pb2 import User

_PARSER = argparse.ArgumentParser(description="Utility for creating, updating, deleting users.")

_PARSER.add_argument("--create", action="store_true", default=False, dest="create")
_PARSER.add_argument("--update", action="store_true", default=False, dest="update")
_PARSER.add_argument("--delete", action="store_true", default=False, dest="delete")

POSTGRES_USER = 'yugabyte'
POSTGRES_PASSWORD = 'yugabyte'
POSTGRES_HOST = os.environ['NODE']
POSTGRES_PORT = 5433
POSTGRES_DATABASE = 'yugabyte'

def get_random_user():
    fake = Faker()
    user_dict = fake.simple_profile()
    user = User(name=user_dict['name'], email=user_dict['mail'], address=user_dict['address'], birth_date=str(user_dict['birthdate']), source=random.randint(0, 2))
    return user

def execute_query(query, values = None):
    with psycopg2.connect(user=POSTGRES_USER,
                          password=POSTGRES_PASSWORD,
                          host=POSTGRES_HOST,
                          port=POSTGRES_PORT,
                          database=POSTGRES_DATABASE) as connection:
        with connection.cursor() as cursor:
            if values:
                cursor.execute(query, values)
            else:
                cursor.execute(query)
            connection.commit()

def ensure_non_empty():
    with psycopg2.connect(user=POSTGRES_USER,
                          password=POSTGRES_PASSWORD,
                          host=POSTGRES_HOST,
                          port=POSTGRES_PORT,
                          database=POSTGRES_DATABASE) as connection:
        with connection.cursor() as cursor:
            read_query = "SELECT count(*) FROM users"
            cursor.execute(read_query)
            records = cursor.fetchall()

            if records[0][0] == 0:
                raise Exception("There is no user in the database.")

def create_user():
    insert_query = "INSERT INTO users (data) VALUES (%s)"
    user = get_random_user()
    values = (user.SerializeToString(),)
    execute_query(insert_query, values)

    print("Created user with data:")
    print(user)

def update_user():
    ensure_non_empty()
    update_query = "UPDATE users SET data=%s WHERE id=(SELECT min(id) FROM users)"
    user = get_random_user()
    values = (user.SerializeToString(),)
    execute_query(update_query, values)

    print("Updated user with new data:")
    print(user)

def delete_user():
    ensure_non_empty()
    delete_query = "DELETE FROM users WHERE id=(SELECT min(id) FROM users)"
    execute_query(delete_query)
    print("Deleted a user")

def main(args = None):
    options = _PARSER.parse_args(args=args)

    if options.create:
        create_user()
        return
    elif options.update:
        update_user()
        return
    elif options.delete:
        delete_user()
        return

    print("No/Invalid operation specified")

if __name__ == "__main__":
    main()