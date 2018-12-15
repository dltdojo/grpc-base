package server

// reference https://github.com/gogo/grpc-example/blob/master/server/server.go

import (
	"context"
	pb "github.com/dltdojo/grpc-base/proto"
)

type Server struct{}

// SayHello implements helloworld.GreeterServer
func (s *Server) Echo(ctx context.Context, in *pb.FooMessage) (*pb.FooMessage, error) {
	return nil, nil
}

func New() *Server {
	return &Server{}
}
