terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
}

resource "yandex_mdb_kafka_cluster" "kafka_cluster" {
  name        = "prod-kafka-cluster"
  network_id  = var.network_id
  environment = "PRODUCTION"

  config {
    version = "3.4"
    brokers_count    = 1
    assign_public_ip = true  # Убедись, что публичный IP задан
    schema_registry  = true
    zones   = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]

    kafka {
      resources {
        resource_preset_id = "s2.medium"
        disk_type_id       = "network-ssd"
        disk_size          = 10
      }
    }
  }
}

resource "yandex_mdb_kafka_topic" "events" {
  cluster_id         = yandex_mdb_kafka_cluster.kafka_cluster.id
  name               = "events"
  partitions         = 3
  replication_factor = 3

  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_DELETE"
    compression_type      = "COMPRESSION_TYPE_LZ4"
    delete_retention_ms   = 86400000
    file_delete_delay_ms  = 60000
    flush_messages        = 128
    flush_ms              = 1000
    min_compaction_lag_ms = 0
    retention_bytes       = 10737418240
    retention_ms          = 604800000
    max_message_bytes     = 1048588
    min_insync_replicas   = 2
    segment_bytes         = 268435456
    preallocate           = false
  }
}

resource "yandex_mdb_kafka_user" "user_events" {
  cluster_id = yandex_mdb_kafka_cluster.kafka_cluster.id
  name       = var.kafka_user
  password   = var.kafka_user_password

  permission {
    topic_name  = "events"
    role        = "ACCESS_ROLE_CONSUMER"
  }

  permission {
    topic_name = "events"
    role       = "ACCESS_ROLE_PRODUCER"
  }
}

resource "yandex_mdb_kafka_user" "admin_events" {
  cluster_id = yandex_mdb_kafka_cluster.kafka_cluster.id
  name       = var.kafka_admin
  password   = var.kafka_admin_password

  permission {
    topic_name  = "*"
    role        = "ACCESS_ROLE_ADMIN"
  }

}

resource "yandex_storage_bucket" "s3_bucket" {
  folder_id  = var.yc_folder_id
  bucket = "nifi-data-bucket"
  acl    = "private"

  lifecycle_rule {
    id      = "delete_old_files"
    enabled = true

    expiration {
      days = 7  # Автоматическое удаление файлов старше 7 дней
    }
  }
 
}

resource "yandex_vpc_security_group" "nifi_security_group" {
  name        = "nifi-security-group"
  network_id  = var.network_id
  description = "Security Group for NiFi server"

  # Разрешаем входящий трафик
  ingress {
    protocol       = "TCP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["${var.local_ip}/32"]
    description    = "Allow access from local machine"
  }

  # Разрешаем весь исходящий трафик
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Allow all outgoing traffic"
  }
}

resource "yandex_compute_instance" "nifi_instance" {
  name        = "nifi-server"
  platform_id = "standard-v2"
  folder_id  = var.yc_folder_id
  zone        = "ru-central1-a"

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"  # Ubuntu 22.04 LTS
      size     = 20
    }
  }

  network_interface {
    subnet_id  = var.subnet_id_a
    nat        = true  # Доступ в интернет
    security_group_ids = [yandex_vpc_security_group.nifi_security_group.id]
  }

  metadata = {
    ssh-keys    = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data   = <<EOF
    #!/bin/bash
    sudo apt update -y && sudo apt upgrade -y

    sudo apt install -y openjdk-11-jdk

    cd /opt
    sudo wget https://dlcdn.apache.org/nifi/1.24.0/nifi-1.24.0-bin.tar.gz
    sudo tar -xvzf nifi-1.24.0-bin.tar.gz
    sudo mv nifi-1.24.0 nifi
    sudo chown -R ubuntu:ubuntu /opt/nifi

    sudo /opt/nifi/bin/nifi.sh install
    sudo systemctl enable nifi
    sudo systemctl start nifi

    sudo ufw allow 8080/tcp
    EOF
    }

    labels = {
        app = "nifi"
    }
}
