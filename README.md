# Multi-Connector

> HTTP server to handle Platform of Trust Broker API requests.

## Getting Started

These instructions will get you a copy of the connector up and running.

### Prerequisites

Using environment variables is optional.

Connector generates RSA keys automatically, but keys can be also applied from the environment.
```
PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMII...
PUBLIC_KEY=-----BEGIN PUBLIC KEY-----\nMII...
```

Issuing and renewing free Let's Encrypt SSL certificate by Greenlock Express v4 is supported by including the following variables.
```
GREENLOCK_DOMAIN=www.example.com
GREENLOCK_MAINTANER=info@example.com
```

## Building

```
docker build -t konsta2106/entsoe-electricity-price .
```

## Encrypting configs

Command to encrypt config.json:

```
npm run generate
```

## Basic running

```
docker run -p 8080:8080 -d konsta2106/entsoe-electricity-price
```

## Running with encrypted env variables

```
docker run -e CONFIGS -p 8080:8080 -d konsta2106/entsoe-electricity-price

```
## Request body example

```
{
  "timestamp": "2020-05-25T13:02:13.142Z",
  "productCode": "entsoe-electricity-price-product-code",
  "parameters": {
    "period": "2020-06-08T13:00Z/2020-06-09T22:00Z",
    "targetObject": "10YFI-1--------U"
  }
}
```

