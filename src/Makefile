ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif

SRCDIR=/home/chirag/Desktop/kdns/core

DEPDIR = $(SRCDIR)/../deps

INCLUDE += -I$(DEPDIR)/libmicrohttpd/src/include
STATIC_LIBS += $(DEPDIR)/libmicrohttpd/src/microhttpd/.libs/libmicrohttpd.a


INCLUDE += -I$(DEPDIR)/libjansson/src
STATIC_LIBS += $(DEPDIR)/libjansson/src/.libs/libjansson.a
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2010-2014 Intel Corporation

# binary name
APP = kdns

KDNS_FWD_METRICS = true
KDNS_METRICS = true


# all source are stored in SRCS-y
SRCS-y := main.c\
dns-conf.c \
parser.c \
netdev.c \
forward.c \
db_update.c \
webserver.c \
domain_update.c \
view_update.c \
kdns-adap.c \
tcp_process.c \
local_udp_process.c \
process.c\
hashMap.c\
metrics.c\
rate_limit.c\
ctrl_msg.c

ifdef KDNS_METRICS
CFLAGS += -DENABLE_KDNS_METRICS
endif
ifdef KDNS_FWD_METRICS
CFLAGS += -DENABLE_KDNS_FWD_METRICS
endif

CFLAGS += $(INCLUDE)

# CFLAGS += $(WERROR_FLAGS) -g -O2 -Wno-cast-qual

CFLAGS += -I$(SRCDIR)/../core/$(RTE_TARGET)/include

LDLIBS_shared += -L$(SRCDIR)/../core/$(RTE_TARGET)/lib/ -lkdns -lrt -lpthread

LDLIBS_static += -L$(SRCDIR)/../core/$(RTE_TARGET)/lib/ -lkdns -lrt -lpthread

LDLIBS_shared += $(STATIC_LIBS)
LDLIBS_static += $(STATIC_LIBS)

PKGCONF ?= pkg-config

# Build using pkg-config variables if possible
ifneq ($(shell $(PKGCONF) --exists libdpdk && echo 0),0)
$(error "no installation of DPDK found")
endif

all: shared
.PHONY: shared static
shared: build/$(APP)-shared
	ln -sf $(APP)-shared build/$(APP)
static: build/$(APP)-static
	ln -sf $(APP)-static build/$(APP)
# CFLAGS += $(INCLUDE)

PC_FILE := $(shell $(PKGCONF) --path libdpdk 2>/dev/null)
CFLAGS += -O3 $(shell $(PKGCONF) --cflags libdpdk)
LDLIBS_shared += $(shell $(PKGCONF) --libs libdpdk)
LDLIBS_static += $(shell $(PKGCONF) --static --libs libdpdk)

ifeq ($(MAKECMDGOALS),static)
# check for broken pkg-config
ifeq ($(shell echo $(LDFLAGS_STATIC) | grep 'whole-archive.*l:lib.*no-whole-archive'),)
$(warning "pkg-config output list does not contain drivers between 'whole-archive'/'no-whole-archive' flags.")
$(error "Cannot generate statically-linked binaries with this version of pkg-config")
endif
endif

CFLAGS += -DALLOW_EXPERIMENTAL_API
# CFLAGS += $(WERROR_FLAGS) -g -O2 -Wno-cast-qual -nostartfiles
# build/$(APP): $(SRCS-y) Makefile $(PC_FILE) | build
# 	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDLIBS)

build/$(APP)-shared: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDLIBS_shared)

build/$(APP)-static: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDLIBS_static)

# build/$(APP)-static: $(SRCS-y) Makefile $(PC_FILE) | build
# 	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDFLAGS_STATIC)

build:
	@mkdir -p $@

.PHONY: clean
clean:
	rm -f build/$(APP) build/$(APP)-static build/$(APP)-shared
	test -d build && rmdir -p build || true
