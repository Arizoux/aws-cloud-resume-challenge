import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloudResumeChallengevisitorCount')

def lambda_handler(event, context):
    response = table.get_item(Key={
        'id':'1'
    })
    views = response['Item']['visitors']
    views = views + 1
    response = table.put_item(Item={
        'id':'1',
        'visitors': views
    })

    return views