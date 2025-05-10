#!/bin/bash
rebar3 as prod get-deps

docker build -t mapreduce/erlangmapreduce -f Dockerfile .

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/v4e3t3o3
docker tag mapreduce/erlangmapreduce:latest public.ecr.aws/v4e3t3o3/mapreduce/erlangmapreduce:err-det50
docker push public.ecr.aws/v4e3t3o3/mapreduce/erlangmapreduce:err-det50