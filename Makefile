SHELL = /bin/bash
LINK_FLAGS = --link-flags "-static" -D without_openssl
PROGS = grafana-redis

.PHONY : all static compile spec clean bin ci
.PHONY : ${PROGS}

all: static

ci: spec compile static version

static: bin ${PROGS}

bin:
	@mkdir -p bin

grafana-redis: src/bin/main.cr
	crystal build --release $^ -o bin/$@ ${LINK_FLAGS}

spec:
	crystal spec -v

compile:
	@for x in src/bin/*.cr ; do\
	  crystal build "$$x" -o /dev/null ;\
	done

clean:
	@rm -rf bin

version: ${PROGS}
	./bin/$^ --version
