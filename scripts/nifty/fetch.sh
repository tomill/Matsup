set -x
set -e

curl \
    -H "X-NCMB-Application-Key: $APPKEY" \
    -H "X-NCMB-Signature: hg3N0UUdOhP3mmvrP+2NTycNc4tz4f0/6Nh2x0obkk8=" \
    -H "X-NCMB-Timestamp: 2015-11-18T14:49:51.000Z" \
    -H "Content-Type: application/json" \
    "https://mb.api.cloud.nifty.com/2013-09-01/classes/timeline?where=%7B%22createDate%22%3A%7B%22%24lt%22%3A%7B%22__type%22%3A%22Date%22%2C%22iso%22%3A%222015-11-18T14%3A22%3A51.137Z%22%7D+%7D%7D&order=-createDate&limit=30&include=user"

