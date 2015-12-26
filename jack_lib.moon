ffi=require"ffi"
ffi.cdef require "jack_cdef"
jack=ffi.load "libjack"

setmetatable {

  JACK_MAX_FRAMES:          jack._JACK_MAX_FRAMES
  JACK_LOAD_INIT_LIMIT:     jack._JACK_LOAD_INIT_LIMIT
  JackOpenOptions:          jack._JackOpenOptions
  JackLoadOptions:          jack._JackLoadOptions
  --JACK_DEFAULT_AUDIO_TYPE:  jack._JACK_DEFAULT_AUDIO_TYPE
  --JACK_DEFAULT_MIDI_TYPE:   jack._JACK_DEFAULT_MIDI_TYPE
  JACK_DEFAULT_AUDIO_TYPE:  "32 bit float mono audio"
  JACK_DEFAULT_MIDI_TYPE:   "8 bit raw midi"

  t_port:   ffi.typeof "jack_port_t*"
  t_client: ffi.typeof "jack_client_t*"
  t_status: ffi.typeof "jack_status_t*"

  cb_process:    (fun)-> ffi.cast "int(*)(jack_nframes_t,void*)", fun
  cb_shutdown:   (fun)-> ffi.cast "void(*)(void*)",                fun
  cb_error:      (fun)-> ffi.cast "void(*)(const char *)",         fun
  cb_samplerate: (fun)-> ffi.cast "int(*)(jack_nframes_t,void*)", fun

}, { __index: jack }
