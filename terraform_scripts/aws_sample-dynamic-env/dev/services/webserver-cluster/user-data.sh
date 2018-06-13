#!/bin/bash

cat > index.html <<EOF

    <h1> Hello, World </h1>
    <h2> DB Address : ${db_address} </h2>
    <h2> DB Port : ${db_port} </h2>
EOF

nohup busybox httpd -f -p "${server_port}" &
