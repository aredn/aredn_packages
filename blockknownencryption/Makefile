include $(TOPDIR)/rules.mk

PKG_NAME:=blockknownencryption
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/blockknownencryption
  SECTION:=base
  CATEGORY:=Network
  TITLE:=Block Known Encryption
  #DESCRIPTION:=This variable is obsolete. use the Package/name/description define instead!
  URL:=http://bridge.sourceforge.net/
  MAINTAINER:=Conrad Lara - KG6JEI <kg6jei@amsat.org>

endef

define Package/blockknownencryption/description
  Adds custom firewall rules in /etc/local/mesh-firewall/ to block ports known to be used for the transfer of encrypted protocols.
  This list is not comprehensive and is not guranteed to block all encrypted programs from using the MESH.
endef

define Build/Compile
endef

define Package/blockknownencryption/install
	$(INSTALL_DIR) $(1)/etc/local/mesh-firewall
	$(INSTALL_BIN) ./files/20-blockknownencryption $(1)/etc/local/mesh-firewall
endef

define Package/blockknownencryption/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
  echo "Reloading firewall for rules to take effect."
  /etc/init.d/firewall reload > /dev/null 2>&1
fi
exit 0
endef

define Package/blockknownencryption/postrm
#!/bin/sh
  if [ -z "$${IPKG_INSTROOT}" ]; then
  echo "Restarting firewall without Block Known Encryption rules."
  /etc/init.d/firewall restart > /dev/null 2>&1
fi
exit 0
endef

$(eval $(call BuildPackage,blockknownencryption))
