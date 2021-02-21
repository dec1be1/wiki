#!/usr/bin/env python3

import ovh
from sys import argv

ApplicationKey='<AK>'
ApplicationSecret='<AS>'
ConsumerKey='<CK>'

client = ovh.Client(
    endpoint='ovh-eu',
    application_key=ApplicationKey,
    application_secret=ApplicationSecret,
    consumer_key=ConsumerKey,
)

method = argv[1]
payload = argv[2]

# Print nice welcome message
print("Welcome", client.get('/me')['firstname'])

if method == 'GET':
    print(client.get(payload))
elif method == 'POST':
    print(client.post(payload))
elif method == 'PUT':
    print(client.put(payload))
elif method == 'DELETE':
    print(client.delete(payload))
else:
    print("Error: bad method")

