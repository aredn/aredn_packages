PKG_NAME:=babeld
PKG_VERSION:=1.13.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/babeld
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+librt
	MAINTAINER:=AREDN Dev Team (AREDN edition of Babel)
	TITLE:=Babel mesh routing
	URL:=https://www.irif.fr/~jch/software/babel/
	PKGARCH:=all
endef

define Package/babeld/description
	Babel is a loop-avoiding distance-vector routing protocol
	for IPv6 and IPv4 with fast convergence properties.
endef

define Package/babeld/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/state/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/babeld $(1)/usr/sbin/
	$(INSTALL_CONF) ./files/babeld.conf $(1)/etc/babeld.conf
	$(INSTALL_BIN) ./files/babeld.init $(1)/etc/init.d/babeld
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r ./files/* $(PKG_BUILD_DIR)
	$(Build/Patch)	
endef

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

$(eval $(call BuildPackage,babeld))
