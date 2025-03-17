#get schemas list
curl -X GET \
  -H "Authorization: Basic YWRtaW46cGFzczEyMzEyMzIzMzJf" \
  --cacert /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt \
  "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443/subjects"


# get details for the schema from registry
curl -X GET \
  -H "Authorization: Basic YWRtaW46cGFzczEyMzEyMzIzMzJf" \
  --cacert /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt \
  "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443/subjects/events_new-value/versions"


# setup competibility to NONE
curl -X PUT \                           
  -H "Authorization: Basic YWRtaW46cGFzczEyMzEyMzIzMzJf" \
  -H "Content-Type: application/json" \
  --cacert /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt \
  -d '{"compatibility": "NONE"}' \
  "https://rc1a-uh1223iqirsiht83.mdb.yandexcloud.net:443/config/subjects/events_new-value/compatibility"
