#!/bin/bash

pfexec pkgin update
pfexec pkgin -yV in clang gcc49 gcc7 git gmake patch ruby24
pfexec gem install bundler -v '~> 2.1.4'

