# Name and release number of this package
PKG_NAME:=hamchat
PKG_VERSION:=0.1.1
PKG_RELEASE:=5

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/hamchat
  SECTION:=net
  CATEGORY:=Network
  MAINTAINER:=AREDN Dev Team
  TITLE:=hamchat -- A simple chat script
  URL:=http://www.aredn.org/
  DEPENDS:=+perl
endef

define Package/hamchat/description
  This package provides a simple chat application
  for use for basic communications.
endef

define Package/hamchat/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/hamchat/
	$(INSTALL_BIN) ./files/hamchat.pl $(1)/www/cgi-bin/hamchat/
	$(INSTALL_DIR) $(1)/www/hamchat/
	$(CP) ./files/styles.css $(1)/www/hamchat/
endef

define Package/hamchat/postinst
#!/bin/sh
grep "HamChat|1|" /etc/config.mesh/_setup.services.dmz &> /dev/null
DMZPRESENT=$$?
grep "HamChat|1|" /etc/config.mesh/_setup.services.nat &> /dev/null
NATPRESENT=$$?
NODEMODE=$$(uci -q -c /etc/local/uci/ get hsmmmesh.settings.config)

if [ "$$DMZPRESENT" != 0 ]; then
  echo "HamChat|1|http|$$(uname -n)|8080|cgi-bin/hamchat/hamchat.pl" >> /etc/config.mesh/_setup.services.dmz
fi

if [ "$$NATPRESENT" != 0 ]; then
  echo "HamChat|1|http|$$(uname -n)|8080|cgi-bin/hamchat/hamchat.pl" >> /etc/config.mesh/_setup.services.nat
fi

if [ "$$NODEMODE" = "mesh" ]; then
  echo "Applying service announcement"
  /usr/local/bin/node-setup -a -p mesh &> /dev/null
  echo "<br><br>"
fi

echo "HamChat has been setup at http://$$(uname -n):8080/cgi-bin/hamchat/hamchat.pl"
echo "<br>"
echo "An advertised service has been added for HamChat on the Services configuration page"
endef

define Build/Compile
endef

$(eval $(call BuildPackage,hamchat))

