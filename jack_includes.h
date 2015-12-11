#include <jack/jack.h>
#include <jack/statistics.h>
#include <jack/intclient.h>
#include <jack/ringbuffer.h>
#include <jack/transport.h>
#include <jack/types.h>
#include <jack/thread.h>
#include <jack/midiport.h>
#include <jack/session.h>
#include <jack/control.h>
#include <jack/metadata.h>

const static int    _JACK_MAX_FRAMES          =  JACK_MAX_FRAMES;
const static int    _JACK_LOAD_INIT_LIMIT     =  JACK_LOAD_INIT_LIMIT;
const static int    _JackOpenOptions          =  JackOpenOptions;
const static int    _JackLoadOptions          =  JackLoadOptions;
//const static char*  _JACK_DEFAULT_AUDIO_TYPE  =  JACK_DEFAULT_AUDIO_TYPE;
//const static char*  _JACK_DEFAULT_MIDI_TYPE   =  JACK_DEFAULT_MIDI_TYPE;

