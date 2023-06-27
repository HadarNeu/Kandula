from boto3 import client
import psycopg2
import logging
from dotenv import load_dotenv
import os

class InstanceActions:
    def __init__(self, ec2_client: client):
        self.ec2_client = ec2_client
        self.logger = logging.getLogger()

    def start_instance(self, instance_id):
        try:
            instance_ids = [instance_id]       
            response = self.ec2_client.start_instances(InstanceIds=instance_ids)

            self.logger.info("started instance successfully")
            print(response,'instance started')

        except Exception as ex:
            self.logger.exception(ex)
        pass

    def stop_instance(self, instance_id):
        try:
            instance_ids = [instance_id]       
            response = self.ec2_client.stop_instances(InstanceIds=instance_ids)

            print(response,'instance stopped')
            self.logger.info("stopped instance successfully")

        except psycopg2.Error as error:
            self.logger.error(error)

        except Exception as ex:
            self.logger.exception(ex)
        pass

    def terminate_instance(self, instance_id):
        try:
            logger = logging.getLogger()

            instance_ids = [instance_id]       
            response = self.ec2_client.stop_instances(InstanceIds=instance_ids)

            print(response,'instance terminated')
            logger.info("stopped instance successfully")

        except psycopg2.Error as error:
            logger.error(error)

        except Exception as ex:
            logger.exception(ex)
        pass

    def action_selector(self, instance_action):
        return {
            'start': self.start_instance,
            'stop': self.stop_instance,
            'terminate': self.terminate_instance
        }.get(instance_action, lambda x: self.action_not_found(instance_action))

    @staticmethod
    def action_not_found(instance_action):
        raise RuntimeError("Unknown instance action selected: {}".format(instance_action))

