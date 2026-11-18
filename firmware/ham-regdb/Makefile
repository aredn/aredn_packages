PKG_NAME:=ham-regdb
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/ham-regdb
	SECTION:=firmware
	CATEGORY:=Firmware
	MAINTAINER:=AREDN Dev Team
	TITLE:=Wireless Amateur Radio Regulatory Database
	URL:=http://www.arednmesh.org/
	PKGARCH:=all
endef

define Package/ham-regdb/install
	$(INSTALL_DIR) $(1)/lib/firmware
	$(CP) $(PKG_BUILD_DIR)/ham-regulatory.db $(1)/lib/firmware/
endef

define Build/Compile
	$(STAGING_DIR_HOST)/bin/$(PYTHON) ./files/db2fw.py $(PKG_BUILD_DIR)/ham-regulatory.db ./files/db.txt
endef

$(eval $(call BuildPackage,ham-regdb))
