PANDOC ?= pandoc
BUILD_DIR := build
EPUB := $(BUILD_DIR)/月迷津渡.epub
MANUSCRIPT := $(sort $(wildcard manuscript/*.md))

COVER := $(firstword $(wildcard assets/cover.jpg assets/cover.png))
ifneq ($(COVER),)
COVER_OPT := --epub-cover-image=$(COVER)
endif

.PHONY: build ocr clean

build: $(EPUB)

$(EPUB): metadata.yaml $(MANUSCRIPT) assets/epub.css scripts/build.sh scripts/newpage.lua scripts/ascii-heading-ids.lua scripts/chapter-titlepage.lua scripts/poem-title.lua scripts/poem-stanzas.lua scripts/xuanwen-title.lua scripts/pangu.lua scripts/fix-nav.py $(COVER)
	@bash scripts/build.sh

ocr:
	@bash scripts/ocr.sh

clean:
	rm -rf $(BUILD_DIR)
