import flask
from flask import request
import os
from bot import ObjectDetectionBot
import boto3
from botocore.exceptions import ClientError
import json

app = flask.Flask(__name__)

aws_region = os.getenv('AWS_REGION')
dynamodb_table = os.getenv('DYNAMODB_TABLE')
record_name = os.getenv('RECORD_NAME')

def get_secret():

    secret_name = "telegram-token"
    region_name = aws_region

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name ='secretsmanager',
        region_name = region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response['SecretString']
    print(secret)
    secret = json.loads(secret)
    return secret["telegram-token"]
# TODO load TELEGRAM_TOKEN value from Secret Manager

TELEGRAM_TOKEN = get_secret()
TELEGRAM_APP_URL =  f'https://{record_name}:8443'


@app.route('/', methods=['GET'])
def index():
    return 'Ok'


@app.route(f'/{TELEGRAM_TOKEN}/', methods=['POST'])
def webhook():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


@app.route(f'/results', methods=['POST'])
def results():
    prediction_id = request.args.get('prediction_id')
    # TODO use the prediction id to retrieve results from DynamoDB and send to the end-user
    dynamodb = boto3.resource('dynamodb', region_name=aws_region)
    table = dynamodb.Table(dynamodb_table)
    response = table.get_item(Key={'prediction_id': prediction_id})
    chat_id = int(response['Item']['chat_id'])
    objects = response['Item']['labels']
    
    dictrespone = {}
    for x in range(len(objects)):
        try:
            dictrespone.update({objects[x]['class']: dictrespone[objects[x]['class']] + 1})
        except:
            dictrespone[objects[x]['class']] = 1

    text_results = ""
    for keys, values in dictrespone.items():
        text_results = f"{text_results}{keys}: {values}\n"
    
    # text_results = response['Item']['labels'][0]['class']
    bot.send_text(chat_id, text_results)
    return 'Ok'

 

@app.route(f'/loadTest/', methods=['POST'])
def load_test():
    req = request.get_json()
    bot.handle_message(req['message'])
    return 'Ok'


if __name__ == "__main__":
    bot = ObjectDetectionBot(TELEGRAM_TOKEN, TELEGRAM_APP_URL)

    app.run(host='0.0.0.0', port=8443)
