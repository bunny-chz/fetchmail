#
# Porting fetchmail software to OpenWrt 2102 for compatibility.
# 
# fetchmail 6.4.39 is from https://sourceforge.net/projects/fetchmail/files/branch_6.4-obsolete/
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fetchmail
# 6.4.39 is matched current openwrt openssl 1.1.1n
PKG_VERSION:=6.4.39
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://downloads.sourceforge.net/project/fetchmail/branch_6.4-obsolete
PKG_HASH:=75109a1f307b538155fa05f5ef298e8298cb4deae95aed24c16b38d36ff0a186

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=sourceforge-net-projects-fetchmail
PKG_BUILD_DEPENDS:=
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/autotools.mk

define Package/fetchmail
	SECTION:=mail
	CATEGORY:=Mail
	TITLE:=Fetch mail from remote IMAP/POP3 servers
	URL:=https://www.fetchmail.info/
	DEPENDS:=+libopenssl +libpthread
endef

define Package/fetchmail/description
	fetchmail retrieves mail from IMAP/POP3 servers.
	Supports IMAP ID command.
endef

CONFIGURE_ARGS += \
	--disable-nls \
	--without-kerberos \
	--without-gssapi \
	--with-ssl=openssl

define Package/fetchmail/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/fetchmail $(1)/usr/bin/
	$(INSTALL_BIN) ./files/fetchmail_deliver.sh $(1)/usr/bin/
	$(INSTALL_BIN) ./files/update_fetchmailrc.sh $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/fetchmailrc $(1)/etc/config/
endef

$(eval $(call BuildPackage,fetchmail))
