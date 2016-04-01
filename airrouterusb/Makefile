include $(TOPDIR)/rules.mk

PKG_NAME:=AirRouterUSB
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/airrouterusb
  SECTION:=base
  CATEGORY:=Utilities
  DEPENDS:=+kmod-usb2 +kmod-usb-storage +kmod-fs-ext4 +kmod-fs-vfat +kmod-fs-ntfs +block-mount +kmod-nls-cp437 +kmod-nls-iso8859-1
  TITLE:=USB Drive Support for AirRouters
  URL:=http://www.aredn.org/
  MAINTAINER:=AREDN Dev Team
endef

define Package/airrouterusb/description
 Adds support for USB block devices (ie. thumb drives) to devices with USB ports (ie. AirRouter)
endef

define Build/Compile
endef

define Package/airrouterusb/install
	$(INSTALL_DATA) ./files/fstab $(1)/etc/config/fstab
endef

define Package/airrouterusb/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
  echo ""
  echo ""
  /etc/init.d/fstab enable > /dev/null 2>&1
  touch /tmp/reboot-required
  echo "Please reboot your node now"
  echo ""
  echo ""
fi
exit 0
endef

define Package/airrouterusb/postrm
echo ""
echo ""
/etc/init.d/fstab disable > /dev/null 2>&1
echo ""
echo ""
exit 0
endef

$(eval $(call BuildPackage,airrouterusb))
