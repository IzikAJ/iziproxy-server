require "kilt"
require "kilt/slang"

# Just a proxy processing of *.slim files to "slang" library
# (yes, I`m too lazy to search better solution)
Kilt.register_engine("slim", Slang.embed)
