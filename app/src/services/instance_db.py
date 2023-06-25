import random
from boto3 import client
import logging
from dotenv import load_dotenv
import os
import psycopg2

def get_ec2_instance_ids():
    # Create a Boto3 EC2 client
    ec2_client = client('ec2')

    # Retrieve all EC2 instances
    response = ec2_client.describe_instances()

    instance_ids = []
    instances_data = []

    for instance in response['Reservations']:
        for data in instance['Instances']:
            instances_data.append(data)
    for instance in instances_data:
        instance_ids.append(instance.get('InstanceId', None))


    return instance_ids

def create_instance_schedule(instance_ids):
    instance_schedule = {
        "Instances": []
    }

    for instance_id in instance_ids:
        shutdown_hour = (f"{random.randint(0, 23):02d}")
        instance_schedule["Instances"].append({"Id": instance_id, "DailyShutdownHour": shutdown_hour })

    return instance_schedule


def get_scheduling():
    # TODO: Implement a DB select query that gets all instance ids and their scheduled hours
    #       The returned data would be a in JSON format as show in the sample output below
    # return instance_schedule
    # Load environment variables from .env file
    logger = logging.getLogger()
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
    try:
        # params = get_db_config()
        query = "SELECT instance_id, shutdown_time FROM kandula.instances_scheduler"

        # with psycopg2.connect(**params) as connection:
        with psycopg2.connect(host=db_host, port=db_port, database=db_name, user=db_user, password=db_password) as connection:
            with connection.cursor() as cursor:
                cursor.execute(query)
                rows = cursor.fetchall()

                instances = []
                for row in rows:
                    instance = {"Id": row[0], "DailyShutdownHour": int(row[1][0:2])}
                    instances.append(instance)
        logger.info("create_scheduling was executed successfully")

    except psycopg2.Error as error:
        logger.error(error)

    except Exception as ex:
        logger.exception(ex)

    # return instance_schedule
    logger.debug(f"instances:{instances}")
    print({"Instances": instances})
    return {"Instances": instances}


def create_scheduling(instance_id, shutdown_hour):
    # TODO: Implement a DB insert that creates the instance ID and the chosen hour in DB
    #creating the values for insert:


    logger = logging.getLogger()
    logger.debug(f"inserting sql create_scheduling with instance_id {instance_id} and shutdown_hour {shutdown_hour}")

    # if instance_id == None or instance_id == "None":
    if instance_id == None:
        logger.error(f"instance_id is None")
        return
    logger.debug("connecting to the DB")
        
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

    try:
        query = """INSERT INTO kandula.instances_scheduler(instance_id, shutdown_time) VALUES(%s, %s) RETURNING *;"""

        with psycopg2.connect(host=db_host, port=db_port, database=db_name, user=db_user, password=db_password) as connection:
            with connection.cursor() as cursor:
                cursor.execute(query, (instance_id, shutdown_hour))
                row = cursor.fetchone()

        logger.info("insert query create_scheduling was executed successfully")

    except psycopg2.Error as error:
        logger.error(f"insert query create_scheduling was NOT executed successfully")

    except Exception as ex:
        logger.exception(ex)

    try:  # update
        index = [i['Id'] for i in instance_schedule["Instances"]].index(instance_id)
        instance_schedule["Instances"][index] = {"Id": instance_id, "DailyShutdownHour": int(shutdown_hour[0:2])}
        print("Instance {} will be shutdown was updated to the hour {}".format(instance_id, shutdown_hour))
    except Exception:  # insert
        instance_schedule["Instances"].append({"Id": instance_id, "DailyShutdownHour": int(shutdown_hour[0:2])})
        print("Instance {} will be shutdown every day when the hour is {}".format(instance_id, shutdown_hour))


def delete_scheduling(instance_id):
    # TODO: Implement a delete query to remove the instance ID from scheduling
    logger = logging.getLogger()
    logger.debug(f"deleting sql query with instance_id {instance_id}")

    # if instance_id == None or instance_id == "None":
    if instance_id == None:
        logger.error(f"instance_id is None")
        return
    logger.debug("connecting to the DB")
        
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

    try:
        query = """DELETE FROM kandula.instances_scheduler WHERE instance_id = (%s);"""
        # query = """INSERT INTO kandula.instances_scheduler(instance_id, shutdown_time) VALUES(%s, %s) RETURNING *;"""
        print('query', query)
        with psycopg2.connect(host=db_host, port=db_port, database=db_name, user=db_user, password=db_password) as connection:
            with connection.cursor() as cursor:
                cursor.execute(query, (instance_id, ))

        logger.info("delete row query was executed successfully")
        print("Instance {} was removed from scheduling".format(instance_id))

    except psycopg2.Error as error:
        logger.error(f"delete row query was NOT executed successfully")
        print("Instance {} was NOT removed from scheduling".format(instance_id))

    except Exception as ex:
        logger.exception(ex)
        print("Instance {} was NOT removed from scheduling".format(instance_id))
    try:
        index = [k['Id'] for k in instance_schedule["Instances"]].index(instance_id)
        instance_schedule["Instances"].pop(index)
        print("Instance {} was removed from scheduling".format(instance_id))
    except Exception:
        print("Instance {} was not there to begin with".format(instance_id))



instance_ids = get_ec2_instance_ids()
instance_schedule= create_instance_schedule(instance_ids)

# # insert the values 
# for key, value in  enumerate(instance_schedule["Instances"]):
#     instace_id = instance_schedule["Instances"][key]['Id']
#     shutdown_time = instance_schedule["Instances"][key]['DailyShutdownHour']
#     create_scheduling(instace_id, shutdown_time)
get_scheduling()
delete_scheduling("""i-0afca42830cd44363""")