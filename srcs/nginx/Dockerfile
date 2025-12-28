FROM debian:12.11

RUN apt update && apt install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/certs

# Gerar certificados TLS
RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
    -nodes \
    -keyout /etc/nginx/certs/nginx.key \
    -out /etc/nginx/certs/nginx.crt \
    -subj "/CN=thfranco.42.fr" \
    -addext "subjectAltName=DNS:thfranco.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]