import mySocketComm
import strutils

var msg : MsgObj = MsgObj(param1: 1, param2: "aaa")

var ret : bool
ret = socketSendObject(msg)