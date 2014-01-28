include $(TOPDIR)/rules.mk

PKG_NAME:=blockknownencryption
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/blockknownencryption
  SECTION:=base
  CATEGORY:=Network
  DEFAULT:=y
  TITLE:=Block Known Encryption
  #DESCRIPTION:=This variable is obsolete. use the Package/name/description define instead!
  URL:=http://bridge.sourceforge.net/
endef

define Package/blockknownencryption/description
 Updates the config_mesh firewall file to block ports that are known to be used for the transfer of encrypted protocols.
 This list is not comprehensive and is not guranteed to block all encrypted programs from using the MESH.
endef

define Build/Compile
endef

define Package/blockknownencryption/install
	$(INSTALL_DIR) $(1)/etc/config.mesh/
	$(INSTALL_DATA) ./files/firewall.mesh $(1)/etc/config.mesh/firewall
endef

define Package/blockknownencryption/postinst
#!/bin/sh
echo ""
echo ""
CONFMODE=`uci -q -c /etc/local/uci get hsmmmesh.settings.config`
if [ "$_" -eq "0" ] && [ "$CONFMODE" != "" ]; then
  /usr/local/bin/node-setup -a $CONFMODE > /dev/null 2>&1
  echo "Please reboot your node now"
else
  echo "Unable to determine your node mode."
  echo "Please save your settings on the Setup page and reboot"
fi
echo ""
echo ""

endef

$(eval $(call BuildPackage,blockknownencryption))
