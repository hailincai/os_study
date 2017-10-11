Ubuntu 14.04 development environment installation

Install bochs 2.6.9
1. sudp apt-get update
2. sudo apt-get install xorg-dev nasm build-essential
3. go to bochs folder, run
   3.1 ./configure --with-x11 --enable-debugger --enable-disasm
   3.2 make
   3.3 make install . After install all BIOS image for bochs will be at /usr/local/share/bochs


System upgrade in Ubuntu
  sudo apt-get install aptitude
  sudp aptitude safe-upgrade