include $(TOPDIR)/rules.mk
 
PKG_NAME:=dd-wrt-ath10k-firmware
PKG_VERSION:=0.0.1
PKG_RELEASE:=1
 
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=https://github.com/kn6plv/dd-wrt.git
#PKG_SOURCE_DATE:=2022-11-13
#PKG_SOURCE_VERSION:=5a53f8fc46444c72adae3847368b03616bca4f2f
#PKG_MIRROR_HASH:=skip
 
include $(INCLUDE_DIR)/package.mk

FIRMWARE_FILE_5 = $(DL_DIR)/ath10k-firmware-38eeda3ae6f90fde5546bdd48ee4ff3090f238c0/ath10k/$(1)/hw-1.0/firmware-5.bin
 
define Package/ath10k-ct-firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/kn6plv/dd-wrt-ath10k-firmware/
endef

define Package/ath10k-firmware-qca4019-ct
  $(Package/ath10k-ct-firmware-default)
  TITLE:=DD-WRT Alternate ath10k firmware for QCA4018/9
  PROVIDES:=ath10k-firmware-qca4019
  CONFLICTS:=ath10k-firmware-qca4019
endef
 
define Package/ath10k-firmware-qca4019-ct/description
  DD-WRT Alternate ath10k firmware
  Provides support for 10 MHz and 5MHz channels
endef

define Build/Compile
endef
 
define Package/ath10k-firmware-qca4019-ct/install
  $(INSTALL_DIR) $(1)/lib/firmware/ath10k/QCA4019/hw1.0
  $(INSTALL_DATA) $(call FIRMWARE_FILE_5,QCA4019) $(1)/lib/firmware/ath10k/QCA4019/hw1.0/firmware-5.bin
endef
 
$(eval $(call BuildPackage,ath10k-firmware-qca4019-ct))