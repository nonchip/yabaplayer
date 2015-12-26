ffi  = require "ffi"
bit  = require "bit"
jit  = require "jit"
J    = require "jack_lib"
math = require "math"

output_port = J.t_port!
client      = J.t_client!

local sample_rate

cb_process = do
  scale=2 * math.pi * 440
  counter=0
  J.cb_process (nframes, argp)->
    outb = ffi.cast "jack_default_audio_sample_t*", J.jack_port_get_buffer output_port, nframes
    outb[i] = math.sin scale * (counter+i) / sample_rate for i = 0, nframes - 1
    counter+=nframes
    0

cb_shutdown = J.cb_shutdown (argp)->
  print "shutting down by JACK"
  os.exit 1

client_name = "sine"
server_name = ffi.NULL
options = ffi.cast "jack_options_t", J.JackNullOption
status_p = J.t_status!

client = assert J.jack_client_open client_name, options, status_p, server_name

J.jack_set_process_callback client, cb_process, ffi.NULL

J.jack_on_shutdown client, cb_shutdown, ffi.NULL

sample_rate = J.jack_get_sample_rate client

output_port = assert J.jack_port_register client, "output",
              J.JACK_DEFAULT_AUDIO_TYPE,
              J.JackPortIsOutput, 0

if 0 ~= J.jack_activate client
  error "cannot activate client"

ports = assert J.jack_get_ports client, ffi.NULL, ffi.NULL, bit.bor J.JackPortIsPhysical, J.JackPortIsInput

if 0 ~= J.jack_connect client, J.jack_port_name(output_port), ports[0]
  error "cannot connect output ports"

ports=nil

ffi.cdef "unsigned int sleep(unsigned int seconds);"

jit.off! -- callback fence start
while true
  ffi.C.sleep 10
  collectgarbage! -- we can at least do something useful here, so clean up.
jit.on! -- callback fence end

J.jack_client_close client
