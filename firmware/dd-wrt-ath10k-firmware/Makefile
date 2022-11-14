include $(TOPDIR)/rules.mk

PKG_NAME:=dd-wrt-ath10k-firmware
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

FIRMWARE_FILE_1_5 = ./files/ath10k-firmware-38eeda3ae6f90fde5546bdd48ee4ff3090f238c0/ath10k/$(1)/hw1.0/firmware-5.bin
FIRMWARE_FILE_2_5 = ./files/ath10k-firmware-38eeda3ae6f90fde5546bdd48ee4ff3090f238c0/ath10k/$(1)/hw2.0/firmware-5.bin

define Package/ath10k-firmware-default-ct
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/kn6plv/dd-wrt-ath10k-firmware/
endef

define Package/ath10k-firmware-qca4019-ct
  $(Package/ath10k-firmware-default-ct)
  TITLE:=DD-WRT Alternate ath10k firmware for QCA4018/9
  PROVIDES:=ath10k-firmware-qca4019
endef

define Package/ath10k-firmware-qca9888-ct
  $(Package/ath10k-firmware-default-ct)
  TITLE:=DD-WRT Alternate ath10k firmware for QCA9888
  PROVIDES:=ath10k-firmware-qca9888
endef

define Package/ath10k-firmware-qca4019-ct/description
  DD-WRT Alternate ath10k firmware
  Provides support for 5MHz and 10MHz channels
endef

define Package/ath10k-firmware-qca9888-ct/description
  DD-WRT Alternate ath10k firmware
  Provides support for 5MHz and 10MHz channels
endef

define Build/Compile
endef

define Package/ath10k-firmware-qca4019-ct/install
	$(INSTALL_DIR) $(1)/lib/firmware/ath10k/QCA4019/hw1.0
	$(INSTALL_DATA) $(call FIRMWARE_FILE_1_5,QCA4019) $(1)/lib/firmware/ath10k/QCA4019/hw1.0/firmware-5.bin
endef

define Package/ath10k-firmware-qca9888-ct/install
	$(INSTALL_DIR) $(1)/lib/firmware/ath10k/QCA9888/hw2.0
	$(INSTALL_DATA) $(call FIRMWARE_FILE_2_5,QCA9888) $(1)/lib/firmware/ath10k/QCA9888/hw2.0/firmware-5.bin
endef

$(eval $(call BuildPackage,ath10k-firmware-qca4019-ct))
$(eval $(call BuildPackage,ath10k-firmware-qca9888-ct))
