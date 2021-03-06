VERSION = $(shell git describe --tags)
PREFIX = /usr/local
GTK = gtk+-3.0
VTE = vte-2.90
TERMINFO = ${PREFIX}/share/terminfo

CXXFLAGS := -std=c++11 -O3 \
	    -Wall -Wextra -pedantic \
	    -Winit-self \
	    -Wshadow \
	    -Wformat=2 \
	    -Wmissing-declarations \
	    -Wstrict-overflow=5 \
	    -Wcast-align \
	    -Wcast-qual \
	    -Wconversion \
	    -Wunused-macros \
	    -Wwrite-strings \
	    -DNDEBUG \
	    -D_POSIX_C_SOURCE=200809L \
	    -DTERMITE_VERSION=\"${VERSION}\" \
	    ${shell pkg-config --cflags ${GTK} ${VTE}} \
	    ${CXXFLAGS}

ifeq (${CXX}, g++)
	CXXFLAGS += -Wno-missing-field-initializers
endif

ifeq (${CXX}, clang++)
	CXXFLAGS += -Wimplicit-fallthrough
endif

LDFLAGS := -s -Wl,--as-needed ${LDFLAGS}
LDLIBS := ${shell pkg-config --libs ${GTK} ${VTE}}

termite: termite.cc url_regex.hh util/clamp.hh util/maybe.hh util/memory.hh
	${CXX} ${CXXFLAGS} ${LDFLAGS} $< ${LDLIBS} -o $@

install: termite termite.desktop termite.terminfo
	mkdir -p ${DESTDIR}${TERMINFO}
	install -Dm755 termite ${DESTDIR}${PREFIX}/bin/termite
	install -Dm644 termite.desktop ${DESTDIR}${PREFIX}/share/applications/termite.desktop
	tic termite.terminfo -o ${DESTDIR}${TERMINFO}

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/termite

clean:
	rm termite

.PHONY: clean install uninstall
