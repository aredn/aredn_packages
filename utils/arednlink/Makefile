PKG_NAME:=arednlink
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/arednlink
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-socket ucode-mod-uci +socat
	MAINTAINER:=AREDN Dev Team
	TITLE:=AREDN Link
	URL:=http://www.arednmesh.org/
	PKGARCH:=all
endef

define Package/arednlink/description
	This package provide distributed name and service discovery and publishing.
endef

define Package/arednlink/install
	$(INSTALL_DIR) $(1)/usr/local/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/arednlink $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/arednlink-ctl $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/arednlink-dump $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/arednlink.init $(1)/etc/init.d/arednlink
endef

define Build/Compile
endef

$(eval $(call BuildPackage,arednlink))
