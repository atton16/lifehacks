#!/bin/bash
certbot certonly \
  --webroot -w /var/www/html \
  -d example.com \
  -d "*.example.com" \
  -d "*.dev.example.com"
