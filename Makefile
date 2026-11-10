ARCHS = arm64
TARGET = iphone:clang:latest:latest
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

# Khai báo Framework
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController Metal MetalKit

# Cờ compile
$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-writable-strings -Wno-error -Wno-nontrivial-memcall -I./ImGui -I.
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-error

# Danh sách file compile
$(TWEAK_NAME)_FILES = $(wildcard MenuLoad/*.mm) \
                      $(wildcard Source/*.mm) \
                      $(wildcard ImGui/*.mm) \
                      $(wildcard ImGui/*.cpp)

# Đóng gói ảnh (logo.png) vào thư mục cài đặt
$(TWEAK_NAME)_LAYOUT_FILES = layout/

include $(THEOS_MAKE_PATH)/tweak.mk
