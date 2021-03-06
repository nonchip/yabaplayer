ffi = require "ffi"
j   = require "JACK.jack_lib"

class JACK
  @j:j
  cb_error: (str)=>
    j.jack_client_close @cl
    error str
    0
  cb_shutdown: =>
    j.jack_client_close @cl
    error "JACK shutdown"
    0
  cb_process: (nframes)=>
    for i,port in ipairs @oports
      @cb_process_port port,nframes
    0
  cb_process_port: (port,nframes)=>
    buf = ffi.cast "jack_default_audio_sample_t*", j.jack_port_get_buffer port, nframes
    @cb_process_port_buffer buf, port, nframes
  cb_process_port_buffer: (buf,port,nframes)=>
    ffi.fill buf, nframes * ffi.sizeof"jack_default_audio_sample_t"
  cb_samplerate: (rate)=>
    @samplerate=rate
    print "new sample rate: %d"\format rate
    0
  new: (@clientname="yabaplayer", nchannels=2, @options=j.JackNullOption)=>
    j.jack_set_error_function j.cb_error (str)-> @cb_error ffi.string str
    status_p = j.t_status!
    @cl = assert j.jack_client_open @clientname, @options, status_p, ffi.NULL
    @samplerate=j.jack_get_sample_rate @cl
    j.jack_on_shutdown @cl, j.cb_shutdown((argp)-> @cb_shutdown!), ffi.NULL
    j.jack_set_process_callback @cl, j.cb_process((nframes,argp)-> @cb_process nframes), ffi.NULL
    j.jack_set_sample_rate_callback @cl, j.cb_samplerate((rate,argp)-> @cb_samplerate rate), ffi.NULL
    @oports=[j.jack_port_register @cl, "output-"..i, j.JACK_DEFAULT_AUDIO_TYPE, j.JackPortIsOutput, 0 for i=1,nchannels]
    j.jack_activate @cl
    cports = j.jack_get_ports @cl, ffi.NULL, ffi.NULL, bit.bor j.JackPortIsPhysical, j.JackPortIsInput
    if cports and cports~=ffi.NULL
      for i=1,nchannels
        if 0 ~= j.jack_connect @cl, j.jack_port_name(@oports[i]), cports[i-1]
          print "INFO: cannot connect port output-"..i
