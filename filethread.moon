(audio_linda, infile)->
  ffi=require "ffi"
  fp=io.open infile, "r"
  str=fp\read "*a"
  len=#str
  ptr=ffi.cast "float*", ffi.cast "void*", str
  for i=0,len/ffi.sizeof"float"
    while not audio_linda\send 100, "port[yabaplayer:output-1]", ptr[i]
      nil
    audio_linda\send 100, "port[yabaplayer:output-2]", ptr[i]
