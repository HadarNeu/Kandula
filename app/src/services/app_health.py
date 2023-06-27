from boto3 import client
import psycopg2
import logging
from dotenv import load_dotenv
import os
 
def check_aws_connection():
    ec2 = client('ec2')
    try:
        response = ec2.describe_instances()
        return True
    except Exception as e:
        print(f"Error describing instances: {e}")
        return False


def check_db_connection():
    # TODO: implement real select query to db. If successful, return true. otherwise return False
    conn = None
    try:
        # Get the connection configuration
        # Load environment variables from .env file
        load_dotenv(r'app/src/services/config.env') 

        # Access the environment variables
        db_host = os.environ.get('DB_HOST')
        db_port = os.environ.get('DB_PORT')
        db_name = os.environ.get('DB_NAME')
        db_user = os.environ.get('DB_USER')
        db_password = os.environ.get('DB_PASSWORD')

        # Use the configuration values
        print(f"DB Host: {db_host}")
        print(f"DB Port: {db_port}")
        print(f"DB Name: {db_name}")
        print(f"DB User: {db_user}")
        print(f"DB Password: {db_password}")

        logger = logging.getLogger()
        logger.debug("connecting to the PostgreSQL DB")
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )

        with psycopg2.connect(host=db_host, port=db_port, database=db_name, user=db_user, password=db_password) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT version()")
                db_version = cursor.fetchone()
            logger.info("PostgreSQL database version: %s", db_version)

        # Return True if the query is successful
        return True

    except (Exception, psycopg2.DatabaseError) as error:
        print("Error while connecting to PostgreSQL:", error)

        # Return False if there's an error
        return False

    finally:
        # Close the database connection
        if conn is not None:
            conn.close()


def is_app_healthy(healthchecks):
    return all([check["Value"] for check in healthchecks])


def get_app_health():
    health_checks = [
        {"Name": "aws-connection", "Value": check_aws_connection()},
        {"Name": "db-connection", "Value": check_db_connection()},
    ]

    return health_checks, is_app_healthy(health_checks)


# Call the connect function and store the result
# query_successful = connect()
rslt= check_db_connection()
# Print the result
print(rslt)
