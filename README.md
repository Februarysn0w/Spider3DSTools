3DS 9.x Code Loading Utilities
===============================================================================

Here is a collection of scripts and tools used for loading code on 9.x 3DS. 
Check out [my posts](http://yifan.lu/category/devices/3ds/) to see how all 
this works. Please note this is only for developers and 3DS researchers and 
there is nothing here for the end user. This is NOT a CFW or any kind of ROM 
loader.

## How do I compile?

You need an arm-none-eabi-gcc toolchain installed. Then just run "make".
The toolchain that is tested with is <http://www.yagarto.de/>. To build ROP for version 4.x or 5.x run "make ASFLAGS=-Dfw=4" or "make ASFLAGS=-Dfw=5" respectively.

## Scripts

### LoadCode

This is an Spider ROP script that loads "code.bin" as ARM11 userland code from 
the SD card and runs it. It exploits the [gspwn](http://smealum.net/?p=517) 
vulnerability to load the code.

### LoadROP

This is an deobfuscated and cleaned up version of GW's first stage Launcher.dat 
loader with two changes. 1) No decryption is done, and 2) no indexing is done. 
This means you place the raw ROP.dat on the sdcard. It is tested to work with 
[regionthree](http://github.com/smealum/regionthree).

### MemoryDump

Taken from [WinterMute](https://github.com/WinterMute/ROPInstaller) ROP scripts 
for mset on 4.x and 6.x. Dumps memory to sdcard with 9.x spider. Currently only 9.x is supported because IFile_Write gadget is not defined for another versions.

### RegionThree

Taken from [smealum] (https://github.com/smealum/regionthree) and [yifanlu](https://github.com/yifanlu/Spider3DSTools/wiki/RegionThree-Loading) ROP scripts

### VCInject

Special version of LoadCode to run with GB/GBC Virtual Console rom injection by [KazoWAR](http://gbatemp.net/threads/injecting-roms-into-vc-with-only-the-web-browser-sure.379760/). URL parameter is passed to the code.bin as rom filename. For now only 9.x code.bin is available.

### Code (UVLoader Lite)

A stripped down version of [UVLoader](http://github.com/yifanlu/UVLoader) that 
generates ARM code that runs with LoadCode. Currently it does nothing except 
display a random pattern on screen. Think of it as a lazy hello world. It is 
a starting point for your code.

### Browserify

Compile with "gcc -o browserify browserify.c" on your computer. Then convert 
any spider ROP payload to JS string with "browserify LoadCode.dat" (as an 
example).

## ROP exploit index.html

Modified version which eliminates the need of frame.html, any server-side and to run Browserify each time you compiled the code. Also loads ROP payload directly from the WEB-server as a .dat file specified as a first HTTP GET parameter. The second HTTP GET parameter will substitute first filename inside the ROP code. e.x. http://hostname/index.html?LoadCode.dat&newcode.bin or http://hostname/index.html?VCInject.dat&gbc/newrom.gbc

## On spider ROP payloads

There are specific data at specific offsets that spider must see for the ROP to 
work. If you look in any of the example ROP scripts, you'll see where the data 
is placed. If you add/remove code, you must reposition all the InitData so it 
is at the same place. Additionally, you must make sure the ROP script is 
exactly 0x300 bytes long. If anyone has a way to automate this, please send a 
pull request.

## Thanks

* smea for ROP gadgets used in LoadCode
* WinterMute for ROP boilerplate code and inspiration for MemoryDump
