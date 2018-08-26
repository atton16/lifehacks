#!/bin/bash
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials cloudflare.ini \
  --server https://acme-v02.api.letsencrypt.org/directory \
  -d example.com \
  -d "*.example.com" \
  -d "*.dev.example.com"