import boto3
 
def check_aws_connection():
    # TODO: implement real call to aws describe instances. If successful, return true. otherwise return False
    ec2 = boto3.client('ec2')
    try:
        response = ec2.describe_instances()
        return True
    except Exception as e:
        print(f"Error describing instances: {e}")
        return False


def check_db_connection():
    # TODO: implement real select query to db. If successful, return true. otherwise return False
    return True


def is_app_healthy(healthchecks):
    return all([check["Value"] for check in healthchecks])


def get_app_health():
    health_checks = [
        {"Name": "aws-connection", "Value": check_aws_connection()},
        {"Name": "db-connection", "Value": check_db_connection()},
    ]

    return health_checks, is_app_healthy(health_checks)
