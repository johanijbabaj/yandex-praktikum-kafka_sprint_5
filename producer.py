#!/usr/bin/python3

import time
from datetime import datetime
from random import choice
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer


value_schema_str = """
{
    "namespace": "my.test",
    "name": "value",
    "type": "record",
    "fields": [
        {
            "name": "event_name",
            "type": "string"
        },
        {
            "name": "event_value",
            "type": "string"
        },
        {
            "name": "timestamp",
            "type": "long"
        }
    ]
}
"""


key_schema_str = """
{
    "namespace": "my.test",
    "name": "key",
    "type": "record",
    "fields": [
        {
            "name": "name",
            "type": "string"
        }
    ]
}
"""


value_schema = avro.loads(value_schema_str)
key_schema = avro.loads(key_schema_str)


event_names = ["Login", "Logout", "Purchase", "SignUp", "PasswordChange"]
event_values = ["Success", "Failure", "Pending", "Completed"]


def generate_message():
    event_name = choice(event_names)
    event_value = choice(event_values)
    timestamp = int(time.mktime(datetime.now().timetuple()))

    value = {
        "event_name": event_name,
        "event_value": event_value,
        "timestamp": timestamp
    }
    key = {"name": f"Key-{event_name}-{timestamp}"}

    return key, value

def delivery_report(err, msg):
    """Called once for each message produced to indicate delivery result."""
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

avroProducer = AvroProducer(
    {
        "bootstrap.servers": ','.join([
            "rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:9091"
        ]),
        "security.protocol": 'SASL_SSL',
        "ssl.ca.location": '/usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt',
        "sasl.mechanism": 'SCRAM-SHA-512',
        "sasl.username": 'admin',
        "sasl.password": 'pass1231232332_',
        "on_delivery": delivery_report,
        "schema.registry.basic.auth.credentials.source": 'SASL_INHERIT',
        "schema.registry.url": 'https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443',
        "schema.registry.ssl.ca.location": "/usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt"
    },
    default_key_schema=key_schema,
    default_value_schema=value_schema
)

for _ in range(10):
    key, value = generate_message()
    avroProducer.produce(topic="events", key=key, value=value)

avroProducer.flush()
