import random
import boto3
import logging

def get_ec2_instance_ids():
    # Create a Boto3 EC2 client
    ec2_client = boto3.client('ec2')

    # Retrieve all EC2 instances
    response = ec2_client.describe_instances()

    # Extract the instance IDs from the response
    instance_ids = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance)
        for valu in instance:
            instance_ids.append({'Id': valu.get('InstanceId', None)}) 


    return instance_ids

def create_instance_schedule(instance_ids):
    instance_schedule = {
        "Instances": []
    }

    for instance_id in instance_ids:
        shutdown_hour = (f"{random.randint(0, 23):02d}:{random.randint(0, 59):02d}")
        instance_schedule["Instances"].append({"Id": instance_id, "DailyShutdownHour": shutdown_hour })

    return instance_schedule



# instance_schedule = {
#     "Instances": [
#         {"Id": "i-1234567890abcdef0", "DailyShutdownHour": 23},
#         {"Id": "i-0ea8205a7a93969a5", "DailyShutdownHour": 20},
#         {"Id": "i-05d648b954c1254d6", "DailyShutdownHour": 18}
#     ]
# }


def get_scheduling():
    # TODO: Implement a DB select query that gets all instance ids and their scheduled hours
    #       The returned data would be a in JSON format as show in the sample output below
    return instance_schedule


def create_scheduling(instance_id, shutdown_hour):
    # TODO: Implement a DB insert that creates the instance ID and the chosen hour in DB
    try:  # update
        index = [i['Id'] for i in instance_schedule["Instances"]].index(instance_id)
        instance_schedule["Instances"][index] = {"Id": instance_id, "DailyShutdownHour": int(shutdown_hour[0:2])}
        print("Instance {} will be shutdown was updated to the hour {}".format(instance_id, shutdown_hour))
    except Exception:  # insert
        instance_schedule["Instances"].append({"Id": instance_id, "DailyShutdownHour": int(shutdown_hour[0:2])})
        print("Instance {} will be shutdown every day when the hour is {}".format(instance_id, shutdown_hour))


def delete_scheduling(instance_id):
    # TODO: Implement a delete query to remove the instance ID from scheduling
    try:
        index = [k['Id'] for k in instance_schedule["Instances"]].index(instance_id)
        instance_schedule["Instances"].pop(index)
        print("Instance {} was removed from scheduling".format(instance_id))
    except Exception:
        print("Instance {} was not there to begin with".format(instance_id))


instance_ids = get_ec2_instance_ids()
rslt= create_instance_schedule(instance_ids)
print(instance_ids)
print(rslt)