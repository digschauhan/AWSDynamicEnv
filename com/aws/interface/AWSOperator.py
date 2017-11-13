import boto3
import sys
from botocore.exceptions import ClientError


class AWSOperation(object):



    def __init__(self):
        '''Constructor'''
        
        
    def launchEC2(self, imageId, minCount, maxCount, keyName, instanceType):
        print("Starting EC2 ....")
        ec2 = boto3.resource('ec2')
        instances = ec2.create_instances(ImageId=imageId, MinCount=minCount, MaxCount=maxCount, KeyName=keyName, InstanceType=instanceType)
        instance = instances[0]
        instance.wait_until_running()
        instance.load()
        print(instance.public_dns_name)
        
    def listEC2Instances(self):
        print("Getting EC2 instances....")
        ec2Instances = boto3.client('ec2')
        for ec2 in ec2Instances:
            print(ec2.public_dns_name)
        
    def startStopInstance(self):
        action = sys.argv[1].upper()
        instance_id = sys.argv[2]
        
        ec2 = boto3.client('ec2')
        
        if action == 'START':
            # Do a dryrun first to verify permissions
            try:
                ec2.start_instances(InstanceIds=[instance_id], DryRun=True)
            except ClientError as e:
                if 'DryRunOperation' not in str(e):
                    raise
        
            # Dry run succeeded, run start_instances without dryrun
            try:
                response = ec2.start_instances(InstanceIds=[instance_id], DryRun=False)
                print(response)
            except ClientError as e:
                print(e)
        elif action == 'STOP':
            # Do a dryrun first to verify permissions
            try:
                ec2.stop_instances(InstanceIds=[instance_id], DryRun=True)
            except ClientError as e:
                if 'DryRunOperation' not in str(e):
                    raise
        
            # Dry run succeeded, call stop_instances witout dryrun
            try:
                response = ec2.stop_instances(InstanceIds=[instance_id], DryRun=False)
                print(response)
            except ClientError as e:
                print(e)

        
        
if __name__ == "__main__":
        awsOperation = AWSOperation()
        '''awsOperation.launchEC2("ami-cfdafaaa", 1, 1, "RH7_KP", "t2.micro")'''
        '''awsOperation.listEC2Instances()'''
        awsOperation.startStopInstance()
        
        
        
