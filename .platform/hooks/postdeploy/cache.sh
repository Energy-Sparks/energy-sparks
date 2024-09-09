#!/bin/sh

[ -f /keep_cache ] || run-as-webapp bin/rake tmp:cache:clear
