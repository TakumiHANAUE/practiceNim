import httpClient
import json
import strutils
import os
import osproc

const AuthDockerUrlBase: string = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:"
const DockerRegistryUri: string = "https://registry.hub.docker.com/"
# Image manifest V2 Schema 2 を使う。
const TypeDockerManifestV2: string = "application/vnd.docker.distribution.manifest.v2+json"
# Ubuntu は OCIイメージで提供されるので OCI のメディアタイプを定義しておく
const TypeOciIndex: string = "application/vnd.oci.image.index.v1+json" # for ubuntu:latest
const TypeOciManifest: string = "application/vnd.oci.image.manifest.v1+json" # for ubuntu:latest

proc addPrefix(imageName: string): string =
    result = "library/" & imageName

proc getImageName(imageName: string): string =
    result = addPrefix(imageName).split(':')[0]

proc getImageReference(imageName: string): string =
    if imageName.contains(":"):
        result = addPrefix(imageName).split(':')[1]
    else:
        # タグがなければ latest にする。
        result = "latest"

proc getToken(client: HttpClient, imageName: string, operations: seq[string] = @["pull"], token: var string): bool = 
    let authDockerUrl = AuthDockerUrlBase & addPrefix(imageName) & ":" & join(operations, ",")
    let respToken = client.get(authDockerUrl)
    if respToken.status == Http200:
        token = parseJson(respToken.body)["token"].getStr()
        result = true
    else:
        echo "Failed to get token : " & respToken.status
        result = false

proc pullImageManifest(client: HttpClient, imageName: string, manifest: var string): bool =
    let manifestUri: string = DockerRegistryUri & "v2/" & getImageName(imageName) & "/manifests/" & getImageReference(imageName)
    let respManifest = client.get(manifestUri)
    if respManifest.status == Http200:
        let mediaType = parseJson(respManifest.body)["mediaType"].getStr()
        if mediaType == TypeOciIndex:
            # TypeOciIndex はManifestのリストになっているので
            # 目的のManifestのdigestを取得する
            var ociDigest: string = ""
            for items in parseJson(respManifest.body)["manifests"]:
                if items["platform"]["architecture"].getStr() == "amd64": # いったんamd64に固定
                    ociDigest = items["digest"].getStr()
                    break
            # 目的のManifestを取得
            let ociManifestUri: string = DockerRegistryUri & "v2/" & getImageName(imageName) & "/manifests/" & ociDigest
            let respOciManifest = client.get(ociManifestUri)
            if respOciManifest.status == Http200:
                manifest = respOciManifest.body
            else:
                echo "Failed to get manifest : " & respOciManifest.status
                result = false
        else:
            # TypeDockerManifestV2 ならそのままManifestを返す。
            manifest = respManifest.body
        result = true
    else:
        echo "Failed to get manifest : " & respManifest.status
        result = false

proc parseImageLayerDigests(manifest: string, digests: var seq[string]): void =
    digests = @[]
    let mediaType = parseJson(manifest)["mediaType"].getStr()
    if mediaType == TypeDockerManifestV2 or mediaType == TypeOciManifest:
        for items in parseJson(manifest)["layers"]:
            digests.add(items["digest"].getStr())
    else:
        echo "Unsupported manifest content-type : " & mediaType

proc pullImageLayers(client: HttpClient, imageName: string, manifest: string, layerFiles: var seq[string]): bool = 
    layerFiles = @[]
    var digests: seq[string]
    parseImageLayerDigests(manifest, digests)
    for items in digests:
        # pull a layer
        let layerUri: string = DockerRegistryUri & "v2/" & getImageName(imageName) & "/blobs/" & items
        let filename = items.split(':')[1]
        let respPullLayer = client.get(layerUri)
        if respPullLayer.status == Http200:
            var f = open(filename, fmWrite)
            if not isNil(f):
                f.write(respPullLayer.body)
                f.close()
                layerFiles.add(filename)
                result = true
        else:
            echo "Failed to get image layer : " & respPullLayer.status
            echo layerUri
            echo respPullLayer.body
            result = false

proc extractImageLayers(layerFiles: seq[string], dstDir: string): void = 
    for items in layerFiles:
        if existsFile(items):
            discard execCmd("tar zxf " & items & " -C " & dstDir)
            removeFile(items)

proc pullImage*(imageName: string, dstDir: string): bool = 
    let client = newHttpClient()

    var token: string
    if not getToken(client, imageName, @["pull"], token):
        return false
    client.headers.add("Authorization", "Bearer " & token)
    client.headers.add("Accept", TypeDockerManifestV2)
    client.headers.add("Accept", TypeOciManifest)
    client.headers.add("Accept", TypeOciIndex)

    var manifest: string
    if not pullImageManifest(client, imageName, manifest):
        return false

    var layerFiles: seq[string]
    if not pullImageLayers(client, imageName, manifest, layerFiles):
        return false

    extractImageLayers(layerFiles, dstDir)
    return true