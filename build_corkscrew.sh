#!/bin/bash

wget http://www.agroman.net/corkscrew/corkscrew-2.0.tar.gz
tar xf corkscrew-2.0.tar.gz
cd corkscrew-2.0
./configure
make
make install
