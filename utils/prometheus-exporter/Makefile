PKG_NAME:=prometheus-exporter
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/prometheus-exporter
	SECTION:=utils
	CATEGORY:=Utilities
	MAINTAINER:=AREDN Dev Team
	TITLE:=Prometheus metrics exporter
	URL:=http://www.arednmesh.org/
	PKGARCH:=all
endef

define Package/prometheus-exporter/description
	This package provides prometheus compatible metrics
	for the node.
endef

define Package/prometheus-exporter/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/
	$(INSTALL_DIR) $(1)/usr/local/bin/mgr/
	$(INSTALL_DIR) $(1)/usr/local/bin/metrics/
	$(INSTALL_DIR) $(1)/usr/local/bin/metrics/periodics/
	$(INSTALL_BIN) ./files/service/periodic-metrics.lua $(1)/usr/local/bin/mgr/
	$(INSTALL_BIN) ./files/main $(1)/www/cgi-bin/metrics
	$(CP) ./files/metrics/* $(1)/usr/local/bin/metrics/
	$(CP) ./files/periodics/* $(1)/usr/local/bin/metrics/periodics/
endef

define Build/Compile
endef

$(eval $(call BuildPackage,prometheus-exporter))
