import httpClient
import json

let client = newHttpClient()
let url : string = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/alpine:latest:pull"
# Token取得にはGETリクエストを使う。
let response = client.get(url)


if response.status == Http200:
    echo parseJson(response.body)["token"].getStr()
else:
    echo response.status

