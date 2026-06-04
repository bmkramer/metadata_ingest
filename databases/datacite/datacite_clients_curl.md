curl --request GET \
     --output 20260410_01.jsonl\
     --url 'https://api.datacite.org/clients?certificate=&page%5Bnumber%5D=1&page%5Bsize%5D=1000' \
     --header 'accept: application/vnd.api+json'