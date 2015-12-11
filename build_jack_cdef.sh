#!/bin/zsh

echo 'return [==[' > jack_cdef.lua

cpp jack_includes.h | grep -v '^#' | grep -v '^$' >> jack_cdef.lua

echo ']==]' >> jack_cdef.lua

