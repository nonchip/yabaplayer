(audio_linda)->
  ffi = require "ffi"
  class J extends require "JACK"
    new: (@the_linda,...)=>
      super ...
    cb_process_port_buffer: (buf,port,nframes)=>
      portkey="port["..ffi.string(@@j.jack_port_name(port)).."]"
      if @the_linda\count(portkey) > nframes*2
        ret = {@the_linda\receive 0, @the_linda.batched, portkey, nframes, nframes}
        if ret[1] and #ret==nframes+1
          @the_linda\set 0, "status-"..portkey, true
          for i=0,nframes-1
            buf[i]=ffi.cast "jack_default_audio_sample_t", ret[i+2] or 0
          return
      ffi.fill buf, nframes * ffi.sizeof"jack_default_audio_sample_t"
      @the_linda\set 0, "status-"..portkey, false
  J audio_linda
