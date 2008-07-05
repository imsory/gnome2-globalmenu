# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#inherit eutils subversion gnome2
inherit autotools subversion gnome2

ESVN_REPO_URI="http://gnome2-globalmenu.googlecode.com/svn/branches/0.4_wp_socket/"

DESCRIPTION="Global menubar applet for Gnome2."
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="xfce gnome doc"

DEPEND="x11-libs/gtk+
	x11-libs/libwnck
	xfce? xfce-base/xfce4-panel
	gnome? gnome-base/gnome-panel"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

ESVN_BOOTSTRAP="autogen.sh"

src_unpack() {
	NOCONFIGURE=yes subversion_src_unpack
}

src_compile() {
	local myconf=""
	use gnome || myconf="${myconf} --disable-gnome-applet"
	use xfce || myconf="${myconf} --disable-xfce-plugin"
	gnome2_src_compile ${myconf}
}

pkg_postinst() {
	gnome2_pkg_postinst

	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Thank you"
}
