lanes = require"lanes".configure{
  protect_allocator: true
  verbose_errors: true
}
ffi=require "ffi"

jackthread_factory=lanes.gen "*", require "jackthread"

raw_audio_linda = lanes.linda!
raw_audio_linda\limit "port[yabaplayer:output-1]", 1024*100
raw_audio_linda\limit "port[yabaplayer:output-2]", 1024*100

jackthread=jackthread_factory raw_audio_linda

fp=io.open"example.f32", "r"
str=fp\read "*a"
len=#str
ptr=ffi.cast "float*", ffi.cast "void*", str
for i=0,len/ffi.sizeof"float"
  while not raw_audio_linda\send 1, "port[yabaplayer:output-1]", ptr[i]
    nil

ffi.cdef "unsigned int sleep(unsigned int seconds);"
jit.off! -- callback fence start
wait=true
while wait
  ffi.C.sleep 1
  if false==raw_audio_linda\get "status-port[yabaplayer:output-1]"
    wait=false
  if false==raw_audio_linda\get "status-port[yabaplayer:output-2]"
    wait=false
jit.on! -- callback fence end

os.exit 0
