# Name and release number of this package
PKG_NAME:=hamchat
PKG_VERSION:=0.1.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/hamchat
  SECTION:=net
  CATEGORY:=Network
  TITLE:=hamchat -- A simple chat script
  URL:=http://www.bbhndev.org/
endef

define Package/hamchat/description
  This package provides a simple chat application
  for use for basic communications.
endef

define Package/hamchat/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/hamchat/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hamchat.pl $(1)/www/cgi-bin/hamchat/
	$(CP) ./files/styles.css $(1)/www/cgi-bin/hamchat/
endef

$(eval $(call BuildPackage,hamchat))

