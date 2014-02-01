include $(TOPDIR)/rules.mk

PKG_NAME:=blockknownencryption
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/blockknownencryption
  SECTION:=base
  CATEGORY:=Network
  DEFAULT:=y
  TITLE:=Block Known Encryption
  #DESCRIPTION:=This variable is obsolete. use the Package/name/description define instead!
  URL:=http://bridge.sourceforge.net/
  MAINTAINER:=Conrad Lara - KG6JEI <kg6jei@amsat.org>

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
	$(INSTALL_DATA) ./files/firewall.user.mesh $(1)/etc/config.mesh/firewall.user
endef

define Package/blockknownencryption/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
  echo ""
  echo ""
  CONFMODE=`uci -q -c /etc/local/uci get hsmmmesh.settings.config`
  if [ "$$_" -eq "0" ] && [ "$${CONFMODE}" != "" ]; then
    /usr/local/bin/node-setup -a $${CONFMODE} > /dev/null 2>&1
    echo "Please reboot your node now"
  else
    echo "Unable to determine your node mode."
    echo "Please save your settings on the Setup page and reboot"
  fi
  echo ""
  echo ""
fi
exit 0
endef

define Package/blockknownencryption/postrm
#!/bin/sh
cat > /etc/config.mesh/firewall << "EOF"
config defaults
        option syn_flood        1
        option input            ACCEPT
        option output           ACCEPT
        option forward          REJECT
# Uncomment this line to disable ipv6 rules
#       option disable_ipv6     1

config zone
        option name             lan
        option network          'lan'
        option input            ACCEPT
        option output           ACCEPT
        option forward          REJECT

config zone
        option name             wan
        option network          'wan'
        option input            REJECT
        option output           ACCEPT
        option forward          REJECT
        option masq             1
        option mtu_fix          1

config zone
        option name             wifi
        option network          'wifi'
        option input            REJECT
        option output           ACCEPT
        option forward          REJECT
        option masq             1
        option mtu_fix          1


config forwarding
        option src              lan
        option dest             wan

config forwarding
        option src              lan
        option dest             wifi

config forwarding
        option src              wifi
        option dest             wifi


# Allow IPv4 ping
config rule
        option name             Allow-Ping
        option src              wifi
        option proto            icmp
        option icmp_type        echo-request
        option family           ipv4
        option target           ACCEPT

config include
        option path /etc/firewall.user


config rule
       option src              wan
       option dest_port        2222
       option proto    tcp
       option target   ACCEPT

config rule
       option src              wan
       option dest_port        8080
       option proto    tcp
       option target   ACCEPT

config rule
       option src              wifi
       option dest_port        2222
       option proto    tcp
       option target   ACCEPT

config rule
       option src              wifi
       option dest_port        8080
       option proto    tcp
       option target   ACCEPT

config rule
       option src              wifi
       option dest_port        698
       option proto    udp
       option target   ACCEPT

config rule
       option src              wifi
       option dest_port        1978
       option proto    tcp
       option target   ACCEPT

config rule
       option src              wifi
       option dest_port        23
       option proto    tcp
       option target   ACCEPT
EOF

cat > /etc/config.mesh/firewall.user << "EOF"
# This file is interpreted as shell script.
# Put your custom iptables rules here, they will
# be executed with each firewall (re-)start.
EOF

echo ""
echo ""
CONFMODE=`uci -q -c /etc/local/uci get hsmmmesh.settings.config`
if [ "$$_" -eq "0" ] && [ "$${CONFMODE}" != "" ]; then
  /usr/local/bin/node-setup -a $${CONFMODE} > /dev/null 2>&1
  echo "Please reboot your node now"
else
  echo "Unable to determine your node mode."
  echo "Please save your settings on the Setup page and reboot"
fi
echo ""
echo ""
exit 0
endef

$(eval $(call BuildPackage,blockknownencryption))
