kdbus$(EXT)-y := \
	bus.o \
	connection.o \
	endpoint.o \
	handle.o \
	memfd.o \
	main.o \
	match.o \
	message.o \
	metadata.o \
	names.o \
	notify.o \
	domain.o \
	policy.o \
	pool.o \
	util.o

obj-m += kdbus$(EXT).o

KERNELDIR 		?= /lib/modules/$(shell uname -r)/build
MODULESDIR		:= $(shell dirname $(KERNELDIR))
RELEASESTR		:= $(shell basename $(MODULESDIR))
PWD			:= $(shell pwd)

all: module test

test::
	$(MAKE) -C test KBUILD_MODNAME=kdbus$(EXT)

module:
	$(MAKE) -C $(KERNELDIR) M=$(PWD)

clean:
	rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
	rm -f Module.markers Module.symvers modules.order
	rm -rf .tmp_versions Modules.symvers $(hostprogs-y)
	$(MAKE) -C test clean

check:
	test/test-kdbus

install: module
	mkdir -p $(MODULESDIR)/kernel/drivers/kdbus$(EXT)/
	cp -f kdbus$(EXT).ko $(MODULESDIR)/kernel/drivers/kdbus$(EXT)/
	depmod $(RELEASESTR)

uninstall:
	rm -f $(MODULESDIR)/kernel/drivers/kdbus/kdbus$(EXT).ko

coccicheck:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) coccicheck

tt: all
	sudo sh -c 'dmesg -c > /dev/null'
	-sudo sh -c 'rmmod kdbus$(EXT)'
	sudo sh -c 'insmod kdbus$(EXT).ko'
	-sudo sh -c 'sync; umount / 2> /dev/null'
	test/test-kdbus
	dmesg
