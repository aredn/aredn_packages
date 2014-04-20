# Name and release number of this package
PKG_NAME:=ssidident
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/ssidident
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ssidident -- Sends Callsign Beacons
  DEPENDS:=+libpcap
  URL:=http://www.broadband-hamnet.org
endef

define Package/ssidident/description
  This package provides a metod of sending beacon packets
  with the hostname of the local node.
  these packets can be considered as Callsign Identification
  )In the USA) and can be used for aiming.
  This method also allows you to see what nodes are near you.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef


define Package/ssidident/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssidident $(1)/bin/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(CP) ./files/ssidident.ifacehotplug $(1)/etc/hotplug.d/iface/02-ssidident
endef

$(eval $(call BuildPackage,ssidident))

