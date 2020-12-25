export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:11.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dimness
Dimness_FILES = $(wildcard *.x)

include $(THEOS_MAKE_PATH)/tweak.mk
