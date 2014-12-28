super-resty
===========

Experiment with loading code via RESTful API

```
make go &

curl -X POST --data-binary "@body.txt" http://127.0.0.1:9000/code/route1/test

curl http://127.0.0.1:9000/route1/test    # responds with code deployed in previous step
