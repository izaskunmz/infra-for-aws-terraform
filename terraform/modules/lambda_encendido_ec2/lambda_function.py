import boto3
import os

# Cliente de EC2 en la región especificada
ec2 = boto3.client('ec2', region_name='us-east-1')

def lambda_handler(event, context):
    instance_id = os.getenv('EC2_INSTANCE_ID')
    
    if not instance_id:
        return {"statusCode": 400, "body": "EC2_INSTANCE_ID no definido en variables de entorno"}

    try:
        ec2.start_instances(InstanceIds=[instance_id])
        return {"statusCode": 200, "body": f"EC2 {instance_id} encendida correctamente"}
    except Exception as e:
        return {"statusCode": 500, "body": str(e)}