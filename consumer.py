from confluent_kafka import DeserializingConsumer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroDeserializer
from confluent_kafka.serialization import StringDeserializer

schema_registry_config = {
    "url": "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443",  # URL Schema Registry
    "ssl.ca.location": "/usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt",
    "basic.auth.user.info": "admin:pass1231232332_",
}

# client for Schema Registry
schema_registry_client = SchemaRegistryClient(schema_registry_config)

# Desedializer with connection to Schema Registry
avro_deserializer = AvroDeserializer(schema_registry_client)

consumer_conf = {
    "bootstrap.servers": "rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:9091",
    "group.id": "avro-consumer",
    "security.protocol": "SASL_SSL", 
    "ssl.ca.location": "/usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt", 
    "sasl.mechanism": "SCRAM-SHA-512",
    "sasl.username": "admin",
    "sasl.password": "pass1231232332_",
    "auto.offset.reset": "earliest",
    "key.deserializer": StringDeserializer("utf_8"),
    "value.deserializer": avro_deserializer,
}

consumer = DeserializingConsumer(consumer_conf)
consumer.subscribe(["events"])

while True:
    try:
        msg = consumer.poll(10)
        if msg is None:
            continue

        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        print(f"Received message: {msg.value()}")

    except Exception as e:
        print(f"Message deserialization failed: {e}")
        break

consumer.close()
