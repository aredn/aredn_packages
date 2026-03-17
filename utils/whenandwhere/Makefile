PKG_NAME:=whenandwhere
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/whenandwhere
	SECTION:=utils
	CATEGORY:=Utilities
	MAINTAINER:=AREDN Dev Team
	TITLE:=Use a GPS device to set node location and time
	URL:=http://www.arednmesh.org/
	DEPENDS:= +gpsd \
		+kmod-usb-acm +kmod-usb-core +kmod-usb-ehci \
		+kmod-usb-xhci-hcd +kmod-usb2 +kmod-usb3 \
		+kmod-usb-serial-pl2303 +kmod-usb-serial \
		+kmod-usb-dwc2 +kmod-usb-dwc3 \
		+TARGET_ipq40xx:kmod-usb-dwc3-qcom
endef

define Package/whenandwhere/description
	Use a GPS device to set node location and time.
endef

define Package/whenandwhere/install
	touch $(1)/tmp/whenandwhere
endef

define Build/Compile
endef

$(eval $(call BuildPackage,whenandwhere))
