DEBUG = 0
FINALPACKAGE = 1
GO_EASY_ON_ME := 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
ARCHS = arm64 arm64e

TARGET := iphone:clang:13.0:11.0
MIN_IOS_SDK_VERSION = 11.0

THEOS_DEVICE_IP = 192.168.0.8#127.0.0.1 -p 2222

APPLICATION_NAME = NonceSet143
$(APPLICATION_NAME)_FILES = main.m PSAppDelegate.m# support.m $(wildcard exploit/*.c) $(wildcard fishhook/*.c) $(wildcard PatchDebugging/*.m) $(wildcard postexploit/*.m)#$(wildcard *.m) $(wildcard *.c) $(wildcard exploit/*.c) $(wildcard fishhook/*.c) $(wildcard PatchDebugging/*.m) $(wildcard postexploit/*.m) dimentio/libdimentio.c support.m dimentio/libdimentio.c#main.m PSAppDelegate.m# dimentio/libdimentio.c support.m
$(APPLICATION_NAME)_FRAMEWORKS = UIKit CoreGraphics Foundation CoreFoundation SafariServices IOKit
#$(APPLICATION_NAME)_LIBRARIES = dementia
$(APPLICATION_NAME)_LDFLAGS += ./Resources/libdimentio.dylib
$(APPLICATION_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(APPLICATION_NAME)_CFLAGS = -fobjc-arc# -Wno-deprecated-declarations
$(APPLICATION_NAME)_CODESIGN_FLAGS = -Sent.xml

#SUBPROJECTS += dimentio

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod -R 755 $(THEOS_STAGING_DIR)
	sudo chmod 6755 $(THEOS_STAGING_DIR)/Applications/NonceSet143.app/NonceSet143
	sudo chmod 666 $(THEOS_STAGING_DIR)/DEBIAN/control

after-package::
	make clean
	sudo rm -rf .theos/_