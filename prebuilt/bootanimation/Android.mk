#
# Copyright (C) 2018-2019 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifeq ($(TARGET_SCREEN_WIDTH),)
    $(warning TARGET_SCREEN_WIDTH is not set, using default value: 1080)
    TARGET_SCREEN_WIDTH := 1080
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
    $(warning TARGET_SCREEN_HEIGHT is not set, using default value: 1920)
    TARGET_SCREEN_HEIGHT := 1920
endif
BOOTFPS := 25

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION): INTERMEDIATES := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/intermediates
$(TARGET_GENERATED_BOOTANIMATION): $(SOONG_ZIP)
	@echo "Building bootanimation.zip"
	@rm -rf $(dir $@)
	@mkdir -p $(dir $@)/intermediates
	$(hide) if [ $(TARGET_SCREEN_HEIGHT) -lt $(TARGET_SCREEN_WIDTH) ]; then \
	    IMAGEWIDTH=$(TARGET_SCREEN_HEIGHT); \
	else \
	    IMAGEWIDTH=$(TARGET_SCREEN_WIDTH); \
	fi; \
	IMAGESCALEWIDTH=$$IMAGEWIDTH; \
	IMAGESCALEHEIGHT=$$(expr $$IMAGESCALEWIDTH \* 16 \/ 9); \
	RESOLUTION="$$IMAGESCALEWIDTH"x"$$IMAGESCALEHEIGHT"; \
	if [ "$$IMAGESCALEWIDTH" -eq 1080 ]; then \
	    tar xfp vendor/addons/prebuilt/bootanimation/bootanimation_1080.tar -C $(INTERMEDIATES); \
	else \
	    tar xfp vendor/addons/prebuilt/bootanimation/bootanimation.tar -C $(INTERMEDIATES); \
	    prebuilts/tools-lineage/${HOST_OS}-x86/bin/mogrify -resize $$RESOLUTION -colors 250 $(INTERMEDIATES)/*/*.png; \
	fi; \
	echo "$$IMAGESCALEWIDTH $$IMAGESCALEHEIGHT $(BOOTFPS)" > $(INTERMEDIATES)/desc.txt; \
	cat vendor/addons/prebuilt/bootanimation/desc.txt >> $(INTERMEDIATES)/desc.txt;
	$(hide) $(SOONG_ZIP) -L 0 -o $(TARGET_GENERATED_BOOTANIMATION) -C $(INTERMEDIATES) -D $(INTERMEDIATES)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@cp $(TARGET_BOOTANIMATION) $@
