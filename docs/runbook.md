# Trendyol Data Streaming Case - Runbook

Buraya case boyunca yaptığım adımları yazıyorum. karışmasın diye basit şekilde gidiyorum.

## 1) Terraform ile altyapı

- vpc kurdum
- public iki subnet açtım (1a, 1b)
- internet gateway + route table bağladım
- security group açtım (şimdilik her şeye izin, sonra kısıtlama bakarım)
- compute modülünde broker, controller, connect, observability ec2’leri oluşturdum
- outputlara public ip’leri ekledim

komutlar:
terraform init
terraform apply


çıktıdan ip’leri aldım. inventory scriptine ekleyip ansible için hazırladım.

## 2) Ansible ile Kafka kurulumu (cp-ansible)

- inventory dosyasını terraform output ile doldurmak için script yazdım
- cp-ansible requirements ekledim
- kafka broker ve controller rollerini playbook’a koydum
- ayarları group_vars/all.yml içine yazdım


ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/kafka.yml

## 3) Observability

- prometheus için skeleton dosyası bıraktım
- alertmanager iskeleti koydum
- grafana klasörü açtım, dashboardları sonra ekleyeceğim
- hepsi observability ec2 üstünde çalışacak

## 4) Admin API

- flask ile api klasörü açtım
- dockerfile yazdım
- requirementları ekledim
- ping endpoint ile başladım, sonra adminclient fonksiyonlarını koyacağım

## 5) Kafka Connect

- docker-compose ile connect nodeunu hazırladım
- http source plugin için plugins klasörünü oluşturdum
- bootstrap ip’yi sonra terraform output’tan alıp compose içinde güncelleyeceğim

## 6) Admin API (Flask + AdminClient)

- api klasorunu actim
- requirements.txt icine confluent-kafka ve flask ekledim
- dockerfile yazdim
- app.py icine brokers/topics/consumer-groups icin endpointleri koydum
- uygulama 2020 portunda calisiyor
- kafka baglantisini env ile yapiyorum:
  KAFKA_BOOTSTRAP_SERVERS="1.2.3.4:9092"

calistirmak icin:

docker build -t admin-api .
docker run -p 2020:2020 -e KAFKA_BOOTSTRAP_SERVERS="IP:9092" admin-api

