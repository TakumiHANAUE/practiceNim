# import httpClient
# import json
# import strutils
# import osproc
import os
import dockerRegistoryClient

let imageName = "ubuntu:latest"
# let nameAndReference: string = "library/" & imageName
# let authDockerUrl: string = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:" & nameAndReference & ":pull"
# let dockerRegistryUri: string = "https://registry.hub.docker.com/"

# let name: string = nameAndReference.split(':')[0] # need "library" for official image
# let reference: string = nameAndReference.split(':')[1]
# let client = newHttpClient()

# # get token
# var token: string = ""
# let respToken = client.get(authDockerUrl)
# if respToken.status == Http200:
#     token = parseJson(respToken.body)["token"].getStr()
# else:
#     quit "Cannot get token : " & respToken.status

# # add Authorization header
# client.headers.add("Authorization", "Bearer " & token)

# # Pulling an Image Manifest
# let manifestUri: string = dockerRegistryUri & "v2/" & name & "/manifests/" & reference
# let respManifest = client.get(manifestUri)
# if respManifest.status != Http200:
#     quit "Cannot get manifest : " & respToken.status

# # Check if the manifest is exists
# let respManifestExist = client.request(manifestUri, "HEAD")
# if respManifestExist.status != Http200:
#     quit "Manifest isn't exists : " & respManifestExist.status

# Make directory to extract image layers
let dirname: string = "target"
if existsDir(dirname):
    removeDir(dirname)
createDir(dirname)

# # Pulling image layers
# var digest: string = ""
# for items in parseJson(respManifest.body)["fsLayers"]:
#     # get a digest from Manifest
#     digest = items["blobSum"].getStr()
#     # pull a layer
#     let layerUri: string = dockerRegistryUri & "v2/" & name & "/blobs/" & digest
#     let filename = digest.split(':')[1]
#     # client.downloadFile(layerUri, filename)
#     let respPullLayer = client.get(layerUri)
#     if respPullLayer.status == Http200:
#         var f = open(filename, fmWrite)
#         if not isNil(f):
#             f.write(respPullLayer.body)
#             f.close()
#             discard execCmd("tar xf " & filename & " -C " & dirname)
#             removeFile(filename)
#     else:
#         quit "Failed to get image layer : " & respPullLayer.status


if pullImage(imageName, dirname):
    echo "Success to pull image : " & imageName
else:
    echo "Failed to pull image : " & imageName

