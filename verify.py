#!/usr/bin/env python3

import sys
import requests

URL = 'https://hvemerdu.dk/v1/unsafe-acks'

if len(sys.argv) <= 1:
    print('error: please provide the code to verify')
    sys.exit(1)

code = sys.argv[1]
data = {'code': code}

response = requests.post(URL, json=data, timeout=100)
print(response.json())
