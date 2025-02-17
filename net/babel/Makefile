PKG_NAME:=babel
PKG_VERSION:=1.13.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/babel
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+librt +socat
	MAINTAINER:=AREDN Dev Team (AREDN edition of Babel)
	TITLE:=Babel mesh routing
	URL:=https://www.irif.fr/~jch/software/babel/
	PKGARCH:=all
endef

define Package/babel/description
	Babel is a loop-avoiding distance-vector routing protocol
	for IPv6 and IPv4 with fast convergence properties.
endef

define Package/babel/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/config.mesh/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/state/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/babeld $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/babel-ctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/babel-dump $(1)/usr/sbin/
	$(INSTALL_CONF) ./files/babel.conf $(1)/etc/babel.conf
	$(INSTALL_BIN) ./files/babel.init $(1)/etc/init.d/babel
	$(INSTALL_CONF) ./files/babel.mesh $(1)/etc/config.mesh/babel
	$(INSTALL_BIN) ./files/babel.hotplug $(1)/etc/hotplug.d/iface/12-babel
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r ./files/* $(PKG_BUILD_DIR)
	$(Build/Patch)	
endef

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

$(eval $(call BuildPackage,babel))
