#!/bin/sh
exec docker run -p 4093:4093 -i -t rocketlaunch_feed $@
