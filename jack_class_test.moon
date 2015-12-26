ffi=require "ffi"
JACK=require "jack"

my_client=JACK!

ffi.cdef "unsigned int sleep(unsigned int seconds);"
jit.off! -- callback fence start
while true
  ffi.C.sleep -1
jit.on! -- callback fence end
