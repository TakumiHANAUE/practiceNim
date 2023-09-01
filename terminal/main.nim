import terminal

var f: File
var success: bool = open(f, "/dev/pts/0", fmReadWrite)
echo success
eraseLine(f)
close(f)