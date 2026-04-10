import requests
import time
import jsonlines

email = "ADD YOUR EMAIL HERE"
url_root = "https://api.crossref.org/"
api_endpoint = 'journals' # one of 'journals' or 'members'
file_save_location = 'ADD YOUR FILENAME AND LOCATION'

cursor = "*"
jsonl = []
rows = 1000
max_cursors = 165
cursor_count = 0

while cursor:
    request = requests.get(url=url_root + api_endpoint,
                           params=dict(
                               cursor=cursor,
                               rows=rows,
                               mailto=email
                           ),
                           timeout=20)

    j = request.json()
    items = j['message'].get('items')
    jsonl.extend(items)

    cursor = j['message'].get('next-cursor')
    if len(items) < rows:
        cursor = False

    cursor_count += 1
    if cursor_count > max_cursors:
        break

    time.sleep(0.1)
    print(f'Cursor: {cursor_count}, {len(jsonl)} records')

with open(file_save_location, 'w') as f:
    writer = jsonlines.Writer(f)
    writer.write_all(jsonl)
