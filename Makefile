THEOS_PACKAGE_SCHEME ?= rootless

TARGET = iphone:clang:latest:16.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NightNight
NightNight_FILES = Tweak.xm \
                   NNSettings.m \
                   NNBatteryMonitor.m \
                   NNHibernationController.m \
                   NNStateStore.m \
                   NNLocalSilence.m \
                   NNWakeGuard.m \
                   NNPrivateAPI.m \
                   NNLog.m
NightNight_FRAMEWORKS = UIKit Foundation CoreFoundation IOKit
NightNight_PRIVATE_FRAMEWORKS = SpringBoard Preferences MediaRemote
NightNight_CFLAGS = -fobjc-arc -Wall -Wextra -Wno-unused-parameter -I$(THEOS_PROJECT_DIR) $(NIGHTNIGHT_EXTRA_CFLAGS)
NightNight_LDFLAGS += -Wl,-segalign,4000 \
                      -F$(THEOS)/sdks/iPhoneOS14.5.sdk/System/Library/PrivateFrameworks

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = NightNightPrefs
NightNightPrefs_FILES = prefs/NightNightRootListController.m NNSettings.m
NightNightPrefs_FRAMEWORKS = UIKit Foundation
NightNightPrefs_PRIVATE_FRAMEWORKS = Preferences
NightNightPrefs_INSTALL_PATH = /Library/PreferenceBundles
NightNightPrefs_RESOURCE_DIRS = prefs/Resources
NightNightPrefs_CFLAGS = -fobjc-arc -Wall -Wextra -I$(THEOS_PROJECT_DIR)
NightNightPrefs_LDFLAGS += -F$(THEOS)/sdks/iPhoneOS14.5.sdk/System/Library/PrivateFrameworks

include $(THEOS_MAKE_PATH)/bundle.mk

TOOL_NAME = NightNightRunner
NightNightRunner_FILES = runner/main.m
NightNightRunner_FRAMEWORKS = Foundation IOKit
NightNightRunner_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
NightNightRunner_CFLAGS = -fobjc-arc -Wall -Wextra
NightNightRunner_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	@if [ -f "$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/NightNightRunner" ]; then \
		ldid -S"$(THEOS_PROJECT_DIR)/tools/NightNightRunner.entitlements" \
			"$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/NightNightRunner"; \
	fi
