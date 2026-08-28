#!/bin/sh
### alpine image uses busybox

# curl CA file option
alias curl='curl --cacert ${TLS_CA_FILE}'
