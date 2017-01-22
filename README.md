# hdb-dart
A dart implementation of the HDB concept.

# Installation

```
git clone https://github.com/asmundstavdahl/hdb-dart.git
cd hdb-dart
```

# Usage
## Simple
```
./server.sh
```


## Background mode:

```
screen -m -d -S hdb ./server.sh <port (default: 44550)>
```

Reconnect: `screen -r hdb`

Then disconnect again: `Ctrl+A+D`
