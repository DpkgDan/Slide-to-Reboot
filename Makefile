ARCHS = armv7 arm64
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = SlidetoReboot
SlidetoReboot_FILES = Tweak.xm
SlidetoReboot_FRAMEWORKS = Foundation UIKit CoreFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
