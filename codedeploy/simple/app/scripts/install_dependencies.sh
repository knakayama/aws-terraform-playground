#!/usr/bin/env bash

[[ -d "/usr/share/nginx/html/wordpress" ]] \
  || curl "https://ja.wordpress.org/latest-ja.tar.gz" \
    | tar xzvpf - -C "/usr/share/nginx/html"
