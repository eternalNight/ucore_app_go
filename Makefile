CURRENT := $(shell pwd)
export GOHOSTOS := linux
export GOHOSTARCH := amd64
export GOOS := ucoresmp
export GOARCH := amd64
export GOROOT := $(CURRENT)
export PATH := $(PATH):$(GOROOT)/bin
export CGO_ENABLED := 0

root-fs := $(GOROOT)/rootfs

all: go-tools tests

bin:
	@cd $(GOROOT)/src && ./make.bash

go-tools: bin

testcases := $(foreach file, $(wildcard $(GOROOT)/testsuit/*.go), $(notdir $(file)))
testcases-out := $(foreach file, $(testcases), $(root-fs)/bin/$(file:%.go=%))

$(testcases-out): $(root-fs)/bin/%: $(GOROOT)/testsuit/%.go | bin $(root-fs)
	@cd $(dir $<) && 6g $< && 6l -o $@ ${<:%.go=%.6}

tests: $(testcases-out)

$(root-fs):
	@mkdir -p $@/bin

clean:
	@cd $(GOROOT)/src && . $(GOROOT)/src/clean.bash > /dev/null
	@rm -rf bin
	@rm -rf $(root-fs)
	@rm -rf $(GOROOT)/testsuit/*.6

.PHONY: all gc-tools tests clean
