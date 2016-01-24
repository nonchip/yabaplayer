#!/bin/zsh

cd "$(dirname "$(readlink -f "$0")")"

echo 'return [==[' > jack_cdef.lua

cpp jack_includes.h | grep -v '^#' | grep -v '^$' >> jack_cdef.lua

echo ']==]' >> jack_cdef.lua

moonc *.moon

luajit -bn JACK.jack_lib jack_lib.lua jack_lib.o
luajit -bn JACK.jack_cdef jack_cdef.lua jack_cdef.o
luajit -bn JACK init.lua jack.o

gcc -O -shared -fpic -o JACK.so *.o
