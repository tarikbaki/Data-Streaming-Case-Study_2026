# Bu Dockerfile, Kafka yönetim API'sini barındıran Flask uygulamasını çalıştırmak için hazırlanmıştır.
# Minimal Python imajı, non-root user ve sade yapı kullanarak üretim ortamına daha uygun hale getiriyorum.

FROM python:3.10-slim

# Çalışma dizini
WORKDIR /app

# Gereksinimleri kopyala ve yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama dosyasını kopyala
COPY app.py .

# Non-root user oluştur (daha güvenli bir imaj için)
RUN useradd -ms /bin/bash appuser
USER appuser

# Flask API 2020 portunda dinliyor
EXPOSE 2020

# Uygulama giriş noktası
CMD ["python", "app.py"]
