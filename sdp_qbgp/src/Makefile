BASEDIR=/local/scratch/essim-jyoti/cbaExDir/provided
export DX_SYSROOT_X86_64=$(BASEDIR)/LINUX_API
CC=$(BASEDIR)/dxcpp/compilers/bin/x86_64-dx-linux-gnu-gcc
INCLIBPATH=$(BASEDIR)/coremw_sdk
INCPATH=$(INCLIBPATH)/include
LIBPATH=$(INCLIBPATH)/lib64
LIBS=-pthread -lm -lSaAmf -lSaCkpt -lSaClm -lSaImmOi -lSaImmOm -lSaLog -lSaNtf
LD_LIBRARY_PATH=$(BASEDIR)/coremw_sdk/lib64
CPPFLAGS= -Wall -g
LDFLAGS= "-Wl,-rpath, $(LIBPATH)"

all:
	rm -f qbgpLauncherExe
	$(CC) $(CPPFLAGS) $(LDFLAGS) -I$(INCPATH) -L$(LIBPATH) $(LIBS) -o qbgpLauncherExe qbgp_amf.c
	echo "QBGP Launcher Application compilation done\n"
