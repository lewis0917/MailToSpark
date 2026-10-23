export THEOS_PACKAGE_SCHEME = rootless

TARGET  := iphone:clang:latest:15.0
ARCHS   := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := MailtoSpark

MailtoSpark_FILES      := Tweak.x
MailtoSpark_CFLAGS     := -fobjc-arc
MailtoSpark_FRAMEWORKS := UIKit

include $(THEOS)/makefiles/tweak.mk
