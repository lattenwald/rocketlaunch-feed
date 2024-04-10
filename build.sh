#!/bin/sh
docker pull elixir:alpine
docker build --network host -t rocketlaunch_feed -t lattenwald/rocketlaunch_feed .
