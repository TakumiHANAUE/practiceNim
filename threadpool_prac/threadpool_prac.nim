# https://forum.nim-lang.org/t/3640
import threadpool
from os import sleep

proc sum(count: int): int =
    echo "Start sum 0 to ", count
    result = 0
    for i in 0..count:
        result += i
    echo "Finish sum 0 to ", count

var
    future1 = spawn sum(100000000)
    future2 = spawn sum(10)

while (not future1.isReady) and (not future2.isReady):
    echo "waiting..."
    sleep(100)

echo "future1: ", ^future1
echo "future2: ", ^future2
