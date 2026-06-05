PKG_NAME:=morsemicro-bcf
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/morsemicro-bcf
	SECTION:=firmware
	CATEGORY:=Firmware
	MAINTAINER:=AREDN Dev Team
	TITLE:=Extra BCF files from Morse Micro
	PKGARCH:=all
endef

define Package/morsemicro-bcf/description
	This package provide extra BCF files which are no longer part of the Morse Micro distribution.
endef

define Package/morsemicro-bcf/install
	$(INSTALL_DIR) $(1)/lib/firmware/morse/
	$(INSTALL_BIN) ./files/bcf_h7608_v2.bin $(1)/lib/firmware/morse/
endef

define Build/Compile
endef

$(eval $(call BuildPackage,morsemicro-bcf))
