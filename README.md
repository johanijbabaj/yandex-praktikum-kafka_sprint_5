# yandex-praktikum-kafka_sprint_5

## Assignment 1: Kafka Producer and Consumer Setup


This document outlines the steps taken to complete Assignment 1, which includes setting up the Kafka producer and consumer, configuring the Kafka cluster, and testing the system's functionality.

## Steps Taken

1. **Terraform Setup**

   - A Terraform configuration file (`maint.tf`) was created to automate the setup of the required infrastructure.
   - The `terraform.tfvars` file was edited to include necessary variables (e.g., cluster size, resources, etc.).
   - We ran `terraform apply` to apply the configuration and provision the infrastructure.

2. **Hardware Resources**

   The setup includes the following hardware resources:
   - **Kafka Cluster Nodes**: The number of nodes required for the Kafka setup, including their specifications (CPU, RAM, Disk, etc.).
   - **Zookeeper Cluster Nodes**: A sufficient number of nodes for handling Zookeeper coordination.
   - **Broker Resources**: Configured based on the expected workload (message throughput, number of partitions, replication factors).

3. **Configuration Scripts**

   The configuration scripts used for setting up the infrastructure and software are located in the following files:
   - **main.tf**: [Link to `main.tf`](main.tf)

4. **Cluster Parameters Description**

   The Kafka cluster is configured with the following parameters:
   - **Kafka Version**: 3.4
   - **Replication Factor**: 3
   - **Number of Partitions**: 3
   - **Retention Policy**: 7 days
   - **Security Protocol**: SASL_SSL
   - **SASL Mechanism**: SCRAM-SHA-512
   - **Ports**: 9091 (Kafka Broker), 2181 (Zookeeper)

5. **API Endpoints Validation**

   To ensure the Kafka cluster is set up correctly, we used the following `curl` commands to query the Kafka Schema Registry and validate schema versions:

   - **Schemas Endpoint**:
     ```bash
     curl -X GET \
        -H "Authorization: Basic YWRtaW46cGFzczEyMzEyMzIzMzJf" \
        --cacert /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt \
        "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443/subjects/events_new-value/versions/latest"
     ```
       [link to screenshot](/img/img_schema.jpg)
   - **Schema Versions Endpoint**:
     ```bash
     curl -X GET \
        -H "Authorization: Basic YWRtaW46cGFzczEyMzEyMzIzMzJf" \
        --cacert /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt \
        "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443/subjects/events_new-value/versions"
     ```
     [link to screenshot](/img/img_schema_2.jpg)

   These commands return the list of subjects and schema versions in the Schema Registry.

6. **Kafka Producer/Consumer code**

   The Kafka producer and consumer code is located in the following Python files:

   Producer Code: [producer.py](producer.py)

   Consumer Code: [consumer.py](consumer.py)

7. ** Producer/Consumer logs**

   [Producer logs](img/img_producer.jpg)

   [Consumer logs](img/img_consumer.jpg)


## Assignment 2: Kafka Integration with External Systems (Apache NiFi)

Overview
In this task, we integrated the Kafka cluster with Apache NiFi for data processing and transfer. NiFi was configured to get data from local file and sent results to Kafka.

 1. Apache NiFi Deployment

Installed and configured NiFi.
Configured NiFi to consume messages from Kafka.
Set up a processing flow in NiFi.

2. Service Verification

Verified running services using system commands.
Captured logs of successful data flow.

[Nifi screenshot](img/img_nifi.jpg)