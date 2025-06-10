FROM ubuntu:22.04

# Noninteractive agar tidak ada prompt saat install
ENV DEBIAN_FRONTEND=noninteractive

# Install tools & inference
RUN apt-get update && \
    apt-get install -y curl nginx lsof procps git uuid-runtime python3 python3-pip && \
    curl -fsSL https://devnet.inference.net/install.sh | sh

RUN pip install python-dotenv fastapi pydantic httpx supabase uvicorn

# Salin konfigurasi nginx lokal
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Salin script startup
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Salin .env dan main.py ke root
COPY .env /.env
COPY main.py /main.py

# Jalankan script
CMD ["/entrypoint.sh"]