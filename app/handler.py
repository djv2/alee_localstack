import json


def handler(event, context):
    return {"statusCode": 200, "body": json.dumps({"message": "processed by localstack_demo", "records": len(event.get("Records", []))})}
