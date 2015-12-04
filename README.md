mingw-w64 from source
=====================

A collection of source distributions, and a shell script to extract and build.
Builds mingw-w64-i686-g++ cross compiler, for use on linux, targetting windows.

Additionally there is a script to run "update-alternatives" and add it to your
path.

Configuration Summary
---------------------

- Targetting win32
- gcc 4.9.3
- Posix threads
- Dwarf 2 exceptions
- No multilib

See script for more details.

Usage
-----

First, inspect `config.sh`, and modify it you wish to install to a system directory or something, or try to build a different target.

Both `build.sh` and `update-alternatives.sh` will source `config.sh` before they run.

Now, to build everything:

```
./build.sh
```

This will *try* to run to completion without manual intervention, but you should be prepared for manual intervention.
See code comments and links to guides in `build.sh`.

After it's finished, to link to your path, run

```
./update-alternatives.sh
```

Where I got these tarballs
--------------------------

gcc:        http://ftp.gnu.org/gnu/gcc/gcc-4.9.3/
binutils:   http://ftp.gnu.org/gnu/binutils/
mingw-w64:  http://tcpdiag.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v4.0.4.tar.bz2
gmp:        https://gmplib.org/
mpfr:       http://www.mpfr.org/mpfr-current/
mpc:        http://www.multiprecision.org/index.php?prog=mpc&page=download
