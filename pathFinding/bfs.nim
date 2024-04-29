# Ref: https://www.redblobgames.com/pathfinding/a-star/introduction.html

import std/deques
import std/tables

import graphutils

var mapData: seq[string] = @[]

proc echoPath(startPos, goalPos: Position, cameFrom: Table[Position, Position]): void =
    var p = goalPos
    var path: seq[Position] = @[]
    while p != startPos:
        path.add(p)
        p = cameFrom[p]
    path.add(startPos)
    echo path

##########

# make Map data
let fileName = "./map.txt"
let file = open(fileName, fmRead)
for line in file.lines:
    mapData.add(line)
close(file)
setXMax(mapData[0].high)
setYMax(mapData.high)

# スタート地点
let startPos: Position = (0, 2)
# ゴール地点
let goalPos: Position = (7, 3)

# frontier : 次に扱う座標を入れたキュー
var frontier = initDeque[Position]()
frontier.addLast(startPos)
# cameFrom : 到達した座標と移動元の座標
## key : 到達した座標
## value : 移動元の座標
var cameFrom = initTable[Position, Position]()
# スタート地点の移動元として無効な座標を入れる
cameFrom[startPos] = (-1, -1)

# スタート地点～ゴール地点までの経路を探索する
while frontier.len != 0:
    # current : 現在地点
    let current = frontier.popFirst()
    # ゴール地点に到達したら探索終わり
    if current == goalPos:
        break
    # 現在地点の隣接地点を、次に扱う座標として登録
    for next in current.getNeighbors():
        if next notin cameFrom:
            frontier.addLast(next)
            cameFrom[next] = current

echoPath(startPos, goalPos, cameFrom)
