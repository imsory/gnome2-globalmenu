NULL = 
SUBDIRS = . tests
STAMP = globalmenu-gnome-private.vapi

BUILT_SOURCES = \
	$(STAMP) \
	$(NULL)

VALASOURCES = \
	module-main.vala \
	globalmenu.vala \
	globalmenu-serializer.vala \
	globalmenu-locator.vala \
	$(NULL)

noinst_LTLIBRARIES = libdyn-patch.la
libdyn_patch_la_SOURCES = \
	dyn-patch.h \
	dyn-patch-main.h \
	dyn-patch-utils.h \
	dyn-patch-vfunc.h \
	dyn-patch-menubar.c \
	dyn-patch-menushell.c \
	dyn-patch-main.c \
	dyn-patch-utils.c \
	dyn-patch-vfunc.c \
	dyn-patch-widget.c \
	$(NULL)

libdyn_patch_la_LIBADD = \
		$(GTK_LIBS) \
		$(NULL)

libdyn_patch_la_LDFLAGS = \
		-g \
		-version-info 1:0:0 \
		-no-undefined \
		$(NULL)
libdyn_patch_la_CPPFLAGS = \
	  -I$(top_srcdir)/libgnomenu \
	  $(GTK_CFLAGS) \
	  -include $(CONFIG_HEADER) \
	  -DG_LOG_DOMAIN=\"GlobalMenu\" \
	  -Werror \
	  -g

libglobalmenu_gnomedir = $(GTK_MODULES_DIR)
libglobalmenu_gnome_LTLIBRARIES = \
	libglobalmenu-gnome.la \
	$(NULL)

libglobalmenu_gnome_la_SOURCES = \
	$(VALASOURCES:.vala=.c) \
	globalmenu-gnome-private.h \
	globalmenu-helper.c \
	$(NULL)

$(STAMP): $(VALASOURCES) dyn-patch.vapi
	$(VALAC) $(VALA_DEFAULT_PKGS) --thread -H globalmenu-gnome-private.h -C --basedir=$(top_srcdir) \
		--library=$(@:.vapi=) --vapidir=. --pkg dyn-patch $(VALASOURCES) \
		--pkg gmodule-2.0 \
		--pkg gtk+-2.0 \
		--pkg gdk-x11-2.0
	touch $@

$(STAMP:.vapi=.deps):
	echo > $@

libglobalmenu_gnome_la_LIBADD = \
		$(GLIB_LIBS) \
		$(GTK_LIBS) \
		libdyn-patch.la \
		$(NULL)

libglobalmenu_gnome_la_LDFLAGS = \
		-g \
		-version-info 1:0:0 \
		-avoid-version \
		-release $(PACKAGE_VERSION) \
		-no-undefined \
		-Wl,--as-needed \
		-export-dynamic \
		-module

libglobalmenu_gnome_la_CPPFLAGS = \
	  -I$(top_srcdir) $(GLIB_CFLAGS) $(GTK_CFLAGS) \
	  -include $(CONFIG_HEADER) \
	  -DG_LOG_DOMAIN=\"GlobalMenu\" \
	  -g

EXTRA_DIST = $(STAMP) $(STAMP:.vapi=.deps)\
	dyn-patch.vapi \
	$(VALASOURCES) \
	$(NULL)

