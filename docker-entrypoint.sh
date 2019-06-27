#!/bin/sh

confd -onetime -backend env

exec "$@"
