# Ref: https://www.redblobgames.com/pathfinding/a-star/introduction.html

import std/heapqueue # 優先度付きキュー
import std/tables
import std/strformat

import graphutils

type
    PositionInfo = tuple
        position: Position
        priority: int

var mapData: seq[string] = @[]

# 独自の型でheapqueueを使うには < 演算子を実装しないといけない
proc `<` (p1, p2: PositionInfo): bool = p1.priority < p2.priority

proc echoPath(startPos, goalPos: Position, cameFrom: Table[Position, Position]): void =
    # ゴール地点からスタート地点まで逆に辿る
    var p = goalPos
    var path: seq[Position] = @[]
    while p != startPos:
        path.add(p)
        p = cameFrom[p]
    path.add(startPos)
    echo path

proc echoCostMap(costSoFar: Table[Position, int]): void =
    for y in 0 .. mapData.high:
        for x in 0 .. mapData[y].high:
            let p: Position = (x, y)
            if p in costSoFar:
                stdout.write(fmt"{costSoFar[p]:2} ")
            else:
                stdout.write("XX ")
        echo ""

proc getCost(next: Position): int =
    result = ord(mapData[next.y][next.x]) - ord('0')

proc heuristic(goalPos, nextPos: Position): int =
    result = getDistance(goalPos, nextPos)

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
var frontier = initHeapQueue[PositionInfo]()
frontier.push((startPos, 0))

# cameFrom : 到達した座標と移動元の座標
## key : 到達した座標
## value : 移動元の座標
var cameFrom = initTable[Position, Position]()
# スタート地点の移動元として無効な座標を入れる
cameFrom[startPos] = (-1, -1)

# costSoFar : 当該座標までのかかったcost
## key : 座標
## value : 座標までのかかったcost
var costSoFar = initTable[Position, int]()
costSoFar[startPos] = 0

# スタート地点～ゴール地点までの経路を探索する
while frontier.len != 0:
    # current : 現在地点
    let current = (frontier.pop()).position
    # ゴール地点に到達したら探索終わり
    if current == goalPos:
        break
    # 現在地点の隣接地点を、次に扱う座標として登録
    for next in current.getNeighbors():
        let newCost = costSoFar[current] + getCost(next)
        # 以下のいずれかの条件に一致する場合、更新する
        ## costSoFarに記録されていない
        ## すでに記録されているcostSoFarよ小さいcost
        if next notin costSoFar or newCost < costSoFar[next]:
            costSoFar[next] = newCost
            let priority = newCost + heuristic(goalPos, next)
            frontier.push((next, priority))
            cameFrom[next] = current

echoPath(startPos, goalPos, cameFrom)
echoCostMap(costSoFar)
