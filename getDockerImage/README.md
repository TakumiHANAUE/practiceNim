# dockerRegistoryClient

DockerRegistryからイメージをpullする。

- [Docker Registry HTTP API V2](https://docs.docker.com/registry/spec/api/)  
    イメージをpullするまでの手順が書いてある。
    簡単に書くと
    - イメージの Manifest 取得
    - イメージの Layer 取得

- 取得の際は digest を指定する。

- ubuntu:latest のマニフェストを取得しようとすると OCI Index を許可するようにエラーが出る。
    ```
    {"errors":[{"code":"MANIFEST_UNKNOWN","message":"OCI index found, but accept header does not support OCI indexes"}]}
    ```
    Acceptヘッダに `application/vnd.oci.image.index.v1+json` を追加すると解消する。

- OCI イメージという規格がある。  
    [OCI Image Format Specification](https://github.com/opencontainers/image-spec)
    - MediaType  
        [OCI Image Media Types](https://github.com/opencontainers/image-spec/blob/main/media-types.md)

- HTTPレスポンスヘッダの MediaType に応じて layer の digest の抽出の仕方が変わる
    - `application/vnd.docker.distribution.manifest.v2+json` であれば `layers` 配列から取ればよい。  
        [Example Image Manifest](https://docs.docker.com/registry/spec/manifest-v2-2/)
    - `application/vnd.oci.image.index.v1+json` の場合、Manifest のリストとなるので、
        1. 目的のManifestのdigestを取得（目的の`manifests[].platform.architecture`となっている`manifest[].digest`）し、  
            [OCI Image Index Specification](https://github.com/opencontainers/image-spec/blob/main/image-index.md)
        1. その digest を使って Manifest を取得し、
        1. その Manifest の `layer`配列から digest を取得できる。

