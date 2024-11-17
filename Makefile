#/* Copyright (c) 2018 The TIGLabs Authors */

ifdef V
Q =
else
Q = @
endif

ifeq ($(machine),)
machine = native
endif

ifeq ($(JOBS),)
    JOBS := $(shell grep -c ^processor /proc/cpuinfo 2>/dev/null)
    ifeq ($(JOBS),)
        JOBS := 1
    endif
endif


RTE_SDK = $(CURDIR)/dpdk-22.11.6
export RTE_SDK

# Default target, can be overriden by command line or environment
RTE_TARGET ?= build
export RTE_TARGET

# bindir =  $(CURDIR)/bin


VERSION ?= 0.1

.PHONY: default
default: kdns

.PHONY: all
all: dpdk deps kdns bin

.PHONY: dpdk
dpdk:
	$(Q)cd $(RTE_SDK) && meson -Denable_kmods=true -Ddisable_libs=flow_classify build
	$(Q)cd $(RTE_SDK) && ninja -C build
	$(Q)cd $(RTE_SDK) && ninja -C build install

.PHONY: deps
deps:
	$(Q)cd deps && make

.PHONY: kdns
kdns:
	$(Q)cd core && $(MAKE) O=$(RTE_TARGET)
	$(Q)cd core/${RTE_TARGET} && mkdir -p lib
	$(Q)cd core/${RTE_TARGET} && mkdir -p include
	$(Q)cp -a core/$(RTE_TARGET)/libkdns.a core/$(RTE_TARGET)/lib/
	$(Q)cp -a core/*.h core/$(RTE_TARGET)/include/
	$(Q)cd src && $(MAKE) O=$(RTE_TARGET)

.PHONY: bin
bin:
	$(Q)cp -a $(RTE_SDK)/usertools/cpu_layout.py $(CURDIR)/src/$(RTE_TARGET)/cpu_layout.py
	$(Q)cp -a $(RTE_SDK)/usertools/dpdk-devbind.py $(CURDIR)/src/$(RTE_TARGET)/dpdk-devbind.py
	$(Q)cp -a $(RTE_SDK)/$(RTE_TARGET)/kernel/linux/igb_uio/igb_uio.ko $(CURDIR)/src/$(RTE_TARGET)/igb_uio.ko
	$(Q)cp -a $(RTE_SDK)/$(RTE_TARGET)/kernel/linux/kni/rte_kni.ko $(CURDIR)/src/$(RTE_TARGET)/rte_kni.ko
	
.PHONY: clean
clean:
	$(Q)cd core && $(MAKE) O=$(RTE_TARGET) clean
	$(Q)cd src && $(MAKE) O=$(RTE_TARGET) clean
	
.PHONY: distclean
distclean:
	$(Q)cd core && $(MAKE) O=$(RTE_TARGET) clean
	$(Q)cd src && $(MAKE) O=$(RTE_TARGET) clean
	$(Q)cd core && rm -rf $(RTE_TARGET)
	$(Q)cd src && rm -rf $(RTE_TARGET)
	
