ffi=require "ffi"
JACK=require "jack"

class jackSine extends JACK
  new: (hz,...)=>
    @scale=2 * math.pi * hz
    @counter=0
    super ...
  cb_process_port_buffer: (buf,port,nframes)=>
    buf[i] = math.sin @scale * (@counter+i) / @samplerate for i = 0, nframes - 1
  cb_process: (nframes)=>
    @counter+=nframes
    super nframes

my_client=jackSine 440

ffi.cdef "unsigned int sleep(unsigned int seconds);"
jit.off! -- callback fence start
while true
  ffi.C.sleep -1
jit.on! -- callback fence end
