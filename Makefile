ARCHS = arm64
TARGET = iphone:clang:latest:latest
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController Metal MetalKit

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-writable-strings -Wno-error -Wno-nontrivial-memcall -I./ImGui -I.
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-error

# Tự động load toàn bộ file .mm và .cpp
$(TWEAK_NAME)_FILES = $(wildcard MenuLoad/*.mm) \
                      $(wildcard Source/*.mm) \
                      $(wildcard ImGui/*.mm) \
                      $(wildcard ImGui/*.cpp)

# Dòng này cực kỳ quan trọng: Đóng gói file ảnh (logo.png) nằm trong thư mục MenuLoad vào file cài đặt
$(TWEAK_NAME)_RESOURCE_DIRS = MenuLoad

include $(THEOS_MAKE_PATH)/tweak.mk
