#!/bin/sh

[ -f /keep_cache ] || run-as-webapp bin/rails r Rails.cache.clear
