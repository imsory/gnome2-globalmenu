NULL = 
VALAC = ../../branches/0.6-devel/vala/valac
AUTOMAKE_OPTIONS = subdir-objects

SUBDIRS = \
	po \
	$(NULL)

AM_CPPFLAGS = \
	$(VALA_DBUS_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

BUILT_SOURCES = src/vala-dbus.vala.stamp

bin_PROGRAMS = vala-dbus

vala_dbus_VALASOURCES = \
	src/mainwindow.vala \
	$(NULL)

vala_dbus_SOURCES = \
	$(vala_dbus_VALASOURCES:.vala=.c) \
	$(vala_dbus_VALASOURCES:.vala=.h) \
	$(NULL)

src/vala-dbus.vala.stamp: $(vala_dbus_VALASOURCES)
	$(VALAC) -C --pkg gtk+-2.0 --pkg dbus-glib-1 --basedir $(top_srcdir) $^
	touch $@

vala_dbus_LDADD = \
	$(VALA_DBUS_LIBS) \
	$(NULL)

EXTRA_DIST = \
	intltool-extract.in \
	intltool-update.in \
	intltool-merge.in \
	$(vala_dbus_VALASOURCES) \
	src/vala-dbus.vala.stamp \
	$(NULL)

DISTCLEANFILES = \
	intltool-extract \
	intltool-update \
	intltool-merge \
	po/.intltool-merge-cache \
	$(NULL)

