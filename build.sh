#!/bin/bash
#set -x

cd "$(dirname "$0")"

# setup the protoc path 
PATH_GAPI=$GOPATH/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.6.2/third_party/googleapis
PATH_GATEWAY=$GOPATH/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.6.2
PATH_PROTOBUF=$GOPATH/pkg/mod/github.com/google/protobuf@v3.6.1+incompatible/src
PATH_PROTO=proto
EXTDIR=protoext

init(){
    go get -u github.com/google/protobuf@v3.6.1
    go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
    go get -u google.golang.org/grpc
    go get -u github.com/grpc-ecosystem/grpc-gateway@v1.6.2
    go get -u github.com/rakyll/statik
    initproto
}

initproto(){
    # copy google/protobuf proto into local directory protoext
    mkdir -p ${EXTDIR}
    cp -r ${PATH_PROTOBUF}/google ${EXTDIR} && find ${EXTDIR} -type f ! -iname "*.proto" -delete
    find ${EXTDIR} -type d -empty -delete
}

genSwaggerStaticFiles(){
    # Copy from https://github.com/swagger-api/swagger-ui/tree/master/dist
    echo TODO
}

gen(){
    PFILE=service.proto
    # setup the output directory
    PKG_OUT=proto
    SWAGGER_OUT=webroot/openapi-ui
    VUE_OUT=webroot/foo-ui

    PATH_INCLUDE="-I$PATH_GAPI -I$PATH_GATEWAY -I$PATH_PROTO -I$EXTDIR"
    # golang/protobuf: Go support for Google's protocol buffers https://github.com/golang/protobuf
    protoc ${PATH_INCLUDE} --go_out=plugins=grpc:${PKG_OUT} $PFILE
    protoc ${PATH_INCLUDE} --grpc-gateway_out=logtostderr=true:${PKG_OUT} $PFILE
    # Generate ltcstd-draft.swagger.json in webroot
    protoc ${PATH_INCLUDE} --swagger_out=logtostderr=true:${SWAGGER_OUT} $PFILE
    sed "s/HTML_TITLE/GRPC BASE DLTDOJO/g" ${SWAGGER_OUT}/index.html.tpl > ${SWAGGER_OUT}/index.html
    sed -i "s/swagger.json/service.swagger.json/g" ${SWAGGER_OUT}/index.html
    # Copy web ui
    rm -rf ${VUE_OUT}
    cp -r hello-vue/dist ${VUE_OUT}
    # Generate static assets for OpenAPI
    statik -m -f -src webroot
    build
}

build(){
    go build .
}

case "$1" in 
    init)   init ;;
    initproto)   initproto ;;
    gen)   gen ;;
    build)   build ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac
