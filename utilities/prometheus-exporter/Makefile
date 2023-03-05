PKG_NAME:=prometheus-exporter
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/prometheus-exporter
	SECTION:=utilities
	CATEGORY:=
	MAINTAINER:=AREDN Dev Team
	TITLE:=prometheus-exporter
	URL:=http://www.arednmesh.org/
endef

define Package/prometheus-exporter/description
	This package provides prometheus compatible metrics
	for the node.
endef

define Package/prometheus-exporter/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/
	$(INSTALL_BIN) ./files/main $(1)/www/cgi-bin/metrics
	$(INSTALL_DIR) $(1)/usr/local/bin/metrics/
	$(CP) ./files/metrics/* $(1)/usr/local/bin/metrics/
endef

defined Build/Compile
endef

$(eval $(call BuildPackage,prometheus-exporter))
