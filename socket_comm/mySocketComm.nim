import net

proc socketServer*() : bool =
    var processRet: bool = true

    var server = newSocket()
    var client: Socket
    var address = "127.0.0.1"
    var port: Port = Port(50010)

    try:
        server.bindAddr(port, address)
    except:
        echo getCurrentExceptionMsg()
        processRet = false
    finally:
        echo("Bind: ", processRet)

    try:
        server.listen()
    except:
        echo getCurrentExceptionMsg()
        processRet = false
    finally:
        echo("Listen: ", processRet)

    while true:
        try:
            server.acceptAddr(client, address)
            echo("Client connected from: ", address)
        except:
            echo getCurrentExceptionMsg()
            processRet = false
        finally:
            echo("Accept: ", processRet)

        var recvRet : int = 0
        var recvMsg : string = ""
        try:
            recvMsg = recvLine(client)
        except:
            echo getCurrentExceptionMsg()
            processRet = false
        finally:
            echo recvMsg
    return processRet

proc socketClient*(msg: string) : bool =
    var processRet : bool = true
    var client = newSocket()
    try:
        client.connect("127.0.0.1", Port(50010))
    except:
        echo getCurrentExceptionMsg()
        processRet = false
    finally:
        echo("Connect: ", processRet)
    echo msg
    client.send(msg)
    return processRet

type
    MsgObj* = ref object of RootObj
        param1* : int
        param2* : string

proc socketSendObject*(msg: MsgObj): bool =
    var processRet = false
    var sendMsg : string
    sendMsg = $(msg.param1) & $(msg.param2) & "\n"
    echo sendMsg
    processRet = socketClient(sendMsg)
    return processRet