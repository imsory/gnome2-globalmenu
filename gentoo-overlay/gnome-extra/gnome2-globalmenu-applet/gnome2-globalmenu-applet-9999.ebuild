# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 subversion autotools

ESVN_REPO_URI="http://gnome2-globalmenu.googlecode.com/svn/trunk/${PN}"

DESCRIPTION="Global menubar applet for Gnome2."
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 -x86"
IUSE=""

DEPEND="x11-libs/gtk+
	x11-libs/libwnck"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

GTKMENUBAR_PATCH_VERSION=${GTKMENUBAR_PATCH_VERSION:-"trunk"}
GTKMENUBAR_HEADER_URL="http://gnome2-globalmenu.googlecode.com/svn/${GTKMENUBAR_PATCH_VERSION}/gtk2-aqd/gtkmenuembed-x11.h"

src_compile() {
	wget "${GTKMENUBAR_HEADER_URL}" -P "${WORKDIR}/gtk2-aqd" || die "Can't fetch gtkmenuembed-x11.h"
	./autogen.sh --prefix=/usr --sysconfdir=/etc
	gnome2_src_compile
}

src_install() {
	gnome2_src_install
	cp -a GNOME_GlobalMenuApplet.server.sample GNOME_GlobalMenuApplet.server
	sed -i "s;APP_LOCATION;/usr/libexec;" GNOME_GlobalMenuApplet.server
	insinto /usr/lib/bonobo/servers
	doins GNOME_GlobalMenuApplet.server
}

pkg_postinst() {
	gnome2_pkg_postinst

	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Thank you"
}
