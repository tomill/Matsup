set -x
set -e

# ab style
curl \
    -H "X-Parse-Application-Id: $APPID" \
    -H "X-Parse-REST-API-Key: $APIKEY" \
    "https://api.parse.com/1/classes/Timeline?order=-createdAt&limit=30&include=user&where=%7B%22user%22%3A%7B%22%24notInQuery%22%3A%7B%22where%22%3A%7B%22disabled%22%3Atrue%7D%2C%22className%22%3A%22_User%22%7D%7D%7D"

# # select * from *public or me* timeline left join user
# # where 
# #   createdAt < "the point" and
# #   user.disabled <> true order by createdAt desc limit 30
# curl -X GET \
#   -H "X-Parse-Application-Id: $APPID" \
#   -H "X-Parse-REST-API-Key: $APIKEY" \
#   -H "X-Parse-Session-Token: $SESSTOKEN" \
#   -G \
#     --data-urlencode 'order=-createdAt' \
#     --data-urlencode 'limit=30' \
#     --data-urlencode 'include=user' \
#     --data-urlencode 'where={
#         "createdAt":{"$lt":"2015-11-18T08:03:19.314Z"}
#         ,
#         "user":{"$notInQuery":{"where":{"disabled":true},"className":"_User"}}
#     }' \
#   https://api.parse.com/1/classes/Timeline


