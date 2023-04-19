import boto3

import logging

REGION_NAME = 'us-west-2'

### Sample data for testing ###
SAMPLE_INSTANCE_DATA = {
    'Instances': [
        {'Cloud': 'aws', 'Region': 'us-east-1', 'Id': 'i-53d13a927070628de', 'Type': 'a1.2xlarge',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-13T19:27:52.000Z', 'State': 'running',
         'StateReason': None, 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Jenkins Master'}]
         },
        {'Cloud': 'aws', 'Region': 'us-east-1', 'Id': 'i-23a13a927070342ee', 'Type': 't2.medium',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-18T21:27:49.000Z', 'State': 'Stopped',
         'StateReason': 'Client.UserInitiatedShutdown: User initiated shutdown', 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Consul Node'}]
         },
        {'Cloud': 'aws', 'Region': 'us-east-1', 'Id': 'i-77z13a9270708asd', 'Type': 't2.xlarge',
         'ImageId': 'ami-03cf127a',
         'LaunchTime': '2020-10-18T21:27:49.000Z', 'State': 'Running',
         'StateReason': None, 'SubnetId': 'subnet-3c940491', 'VpcId': 'vpc-9256ce43',
         'MacAddress': '1b:2b:3c:4d:5e:6f', 'NetworkInterfaceId': 'eni-bf3adbb2',
         'PrivateDnsName': 'ip-172-31-16-58.ec2.internal', 'PrivateIpAddress': '172.31.16.58',
         'PublicDnsName': 'ec2-54-214-201-8.compute-1.amazonaws.com', 'PublicIpAddress': '54.214.201.8',
         'RootDeviceName': '/dev/sda1', 'RootDeviceType': 'ebs',
         'SecurityGroups': [{'GroupName': 'default', 'GroupId': 'sg-9bb1127286248719d'}],
         'Tags': [{'Key': 'Name', 'Value': 'Grafana'}]
         }
    ]
}


def get_state_reason(instance):
    instance_state = instance['State']['Name']
    if instance_state != 'running':
        return instance['StateReason']['Message']


class InstanceData:
    def __init__(self, ec2_client):
        self.ec2_client = ec2_client


    def get_instances(self):
        instances_dict = {}
        instances_data = []
        instance_data_dict_list = []

        log_object = logging.getLogger()

        try:
            log_object.info("SUCCESS ec2 describe_instances:")
            my_instances = self.ec2_client.describe_instances()
        except Exception as e:
            log_object.info("FAILURE Unable to get ec2 describe_instances")
            return {"Instances": []}
        
        for instance in my_instances['Reservations']:
            for data in instance['Instances']:
                instances_data.append(data)
        for instance in instances_data:
            try:
                instance_data_dict = {'Cloud': 'aws', 'Region': self.ec2_client.meta.region_name,
                                        'Id': instance.get('InstanceId', None), 'Type': instance.get('InstanceType', None),
                                        'ImageId': instance.get('ImageId', None), 'LaunchTime': instance.get('LaunchTime', None),
                                        'State': instance['State']['Name'],
                                        'StateReason': get_state_reason(instance),
                                        'SubnetId': instance.get('SubnetId', None), 'VpcId': instance['VpcId'],
                                        'MacAddress': instance['NetworkInterfaces'][0]['MacAddress'],
                                        'NetworkInterfaceId': instance['NetworkInterfaces'][0]['NetworkInterfaceId'],
                                        'PrivateDnsName': instance['PrivateDnsName'],
                                        'PublicDnsName': instance['PublicDnsName'],
                                        'PrivateIpAddress': instance['PrivateIpAddress'],
                                        'PublicDnsName': instance.get('PublicDnsName', None),
                                        'PublicIPAddress': instance.get('PublicIpAddress', None),
                                        'RootDeviceName': instance['RootDeviceName'],
                                        'RootDeviceType': instance['RootDeviceType'],
                                        'SecurityGroups': instance['SecurityGroups'], 'Tags': instance['Tags']}
                
                instance_data_dict_list.append(instance_data_dict)
            except Exception:
                    log_object.info("FAILURE in parsing ec2 data:")
        instances_dict['Instances'] = instance_data_dict_list
        return instances_dict

ec2_client = boto3.client('ec2')
idata = InstanceData(ec2_client)
idata.get_instances()


