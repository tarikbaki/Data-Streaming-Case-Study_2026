# Bu dosyada admin API'yi basit şekilde topladım.
# Topic, consumer group vs. işlemlerini buradan yapıyorum.
# Çok detaylandırmadım, işimi gören minimal bir API oldu.

import os
import json
from flask import Flask, request, jsonify
from confluent_kafka.admin import AdminClient, NewTopic, ConfigResource
from confluent_kafka import KafkaException

app = Flask(__name__)

# kafka baglantisi icin env kullan
KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092")

# guvenlik ayarlari icin buraya ekleme yapilabilir (sasl_ssl vs)
kafka_config = {
    "bootstrap.servers": KAFKA_BOOTSTRAP_SERVERS,
    "security.protocol": os.getenv("KAFKA_SECURITY_PROTOCOL", "SASL_SSL"),
    "sasl.mechanisms": os.getenv("KAFKA_SASL_MECHANISMS", "SCRAM-SHA-512"),
    "sasl.username": os.getenv("KAFKA_USERNAME", "broker"),
    "sasl.password": os.getenv("KAFKA_PASSWORD", "brokerpass"),
}

admin = AdminClient(kafka_config)


@app.route("/ping")
def ping():
    return jsonify({"msg": "ok"})


# -------------------
# brokers
# -------------------
@app.route("/brokers", methods=["GET"])
def list_brokers():
    try:
        md = admin.list_topics(timeout=10)
        brokers = []
        for broker_id, broker in md.brokers.items():
            brokers.append(
                {
                    "id": broker_id,
                    "host": broker.host,
                    "port": broker.port,
                }
            )
        return jsonify(brokers)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -------------------
# topics
# -------------------
@app.route("/topics", methods=["GET"])
def list_topics():
    try:
    md = admin.list_topics(timeout=10)
    topics = []
    for name, t in md.topics.items():
        if name.startswith("__"):  # internal konulari gizle
            continue
        partitions = len(t.partitions)
        rf = 0
        if partitions > 0:
            rf = len(next(iter(t.partitions.values())).replicas)
        topics.append(
            {
                "name": name,
                "partitions": partitions,
                "replication_factor": rf,
            }
        )
    return jsonify(topics)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/topics", methods=["POST"])
def create_topic():
    data = request.get_json(force=True, silent=True) or {}

    name = data.get("name")
    num_partitions = data.get("num_partitions", 3)
    replication_factor = data.get("replication_factor", 3)
    configs = data.get("configs", {})

    if not name:
        return jsonify({"error": "name gerekli"}), 400

    try:
        new_topic = NewTopic(
            topic=name,
            num_partitions=int(num_partitions),
            replication_factor=int(replication_factor),
            config=configs if configs else None,
        )

        fs = admin.create_topics([new_topic])
        f = fs[name]
        f.result()  # exception atarsa firlatir

        return jsonify({"status": "created", "topic": name})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/topics/<topic_name>", methods=["GET"])
def describe_topic(topic_name):
    try:
        md = admin.list_topics(topic=topic_name, timeout=10)
        if topic_name not in md.topics:
            return jsonify({"error": "topic yok"}), 404

        t = md.topics[topic_name]

        partitions = []
        for pid, p in t.partitions.items():
            partitions.append(
                {
                    "partition": pid,
                    "leader": p.leader,
                    "replicas": p.replicas,
                    "isrs": p.isrs,
                }
            )

        # configleri cek
        cr = ConfigResource(
            restype=ConfigResource.Type.TOPIC,
            name=topic_name,
        )
        cfgs = admin.describe_configs([cr])
        configs = {}
        for res, f in cfgs.items():
            try:
                cfg = f.result()
                for k, v in cfg.items():
                    configs[k] = v.value
            except Exception:
                pass

        resp = {
            "name": topic_name,
            "partitions": partitions,
            "configs": configs,
        }
        return jsonify(resp)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/topics/<topic_name>", methods=["PUT"])
def alter_topic_config(topic_name):
    data = request.get_json(force=True, silent=True) or {}
    configs = data.get("configs")
    if not configs:
        return jsonify({"error": "configs bos olamaz"}), 400

    try:
        cr = ConfigResource(
            restype=ConfigResource.Type.TOPIC,
            name=topic_name,
        )
        # eski api: alter_configs
        cr.set_config(configs)

        fs = admin.alter_configs([cr])
        f = fs[cr]
        f.result()

        return jsonify({"status": "updated", "topic": topic_name, "configs": configs})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# -------------------
# consumer groups
# -------------------
@app.route("/consumer-groups", methods=["GET"])
def list_consumer_groups():
    try:
        res = admin.list_groups(timeout=10)
        groups = []
        for g in res:
            groups.append(
                {
                    "group_id": g.id,
                    "state": g.state,
                    "protocol_type": g.protocol_type,
                }
            )
        return jsonify(groups)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/consumer-groups/<group_id>", methods=["GET"])
def consumer_group_details(group_id):
    try:
        res = admin.list_groups(timeout=10)
        target = None
        for g in res:
            if g.id == group_id:
                target = g
                break

        if target is None:
            return jsonify({"error": "group yok"}), 404

        members = []
        for m in target.members:
            # member metadata decode
            try:
                assignment = str(m.assignment)
            except Exception:
                assignment = ""

            members.append(
                {
                    "member_id": m.id,
                    "client_id": m.client_id,
                    "host": m.client_host,
                    "assignment": assignment,
                }
            )

        resp = {
            "group_id": target.id,
            "state": target.state,
            "protocol_type": target.protocol_type,
            "members": members,
            # lag detayi icin normalde offset sorgusu gerekir,
            # burada basit tutuyorum.
        }
        return jsonify(resp)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.getenv("PORT", "2020"))
    app.run(host="0.0.0.0", port=port)
