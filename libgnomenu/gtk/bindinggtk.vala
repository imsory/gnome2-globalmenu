using GLib;
using Gdk;
using Gtk;
using Gnomenu;
using GtkAQD;
using XML;

namespace GnomenuGtk {
	private weak Client client() {
		return Singleton.instance().client;
	}
	private weak Document document() {
		return Singleton.instance().document;
	}
	private void submenu_notify(Gtk.Widget widget, ParamSpec pspec) {
		weak Gtk.Menu submenu = (widget as Gtk.MenuItem).submenu;
		if(submenu != null) {
			bind_widget(submenu, widget as Gtk.Widget);
		}
	}
	private void child_remove(Gtk.Widget widget, Gtk.Widget c) {
		unbind_widget(c); /*This might be not so useful, since the node is removed when 
									the MenuShell is disposed*/
	}
	private void child_insert(Gtk.Widget w, Gtk.Widget c, int pos) {
		bind_widget(c, w, pos);
	}
	private void bind_widget(Gtk.Widget widget, Gtk.Widget? parent_widget /*override parent widget*/= null, int pos = -1) {
		if(!(widget is Gtk.MenuItem)
		&& !(widget is Gtk.MenuShell)
		&& !(widget is Gtk.Window)) return;

		weak string name = document().wrap(widget);
		if(document().lookup(name) != null) return;

		weak XML.Node parent_node;
		if(parent_widget == null) {
			parent_node = document().root;
		}
		else {
			weak string parent = document().wrap(parent_widget);
			parent_node = document().lookup(parent);
		}

		Gnomenu.Document.Widget node = document().CreateWidget("widget", name);
		parent_node.insert(node, pos);

		if(widget is Gtk.MenuShell) {
			weak List<weak Gtk.Widget> children = (widget as Gtk.Container).get_children();
			foreach(weak Gtk.Widget child in children) {
				bind_widget(child, widget, children.index(child));
			}
			(widget as GtkAQD.MenuShell).insert += child_insert;
			(widget as GtkAQD.MenuShell).remove += child_remove;
		}
		if(widget is Gtk.MenuItem) {
			weak Gtk.Menu submenu = (widget as Gtk.MenuItem).submenu;
			if(submenu != null) {
				bind_widget(submenu, widget);
			}
			widget.notify["submenu"] += submenu_notify;
		}
	}
	protected void unbind_widget(Gtk.Widget widget) {
		if(widget is Gtk.MenuShell) {
			weak List<weak Gtk.Widget> children = (widget as Gtk.Container).get_children();
			foreach(weak Gtk.Widget child in children) {
				unbind_widget(child);
			}
			(widget as GtkAQD.MenuShell).insert -= child_insert;
			(widget as GtkAQD.MenuShell).remove -= child_remove;
		}
		if(widget is Gtk.MenuItem) {
			weak Gtk.Menu submenu = (widget as Gtk.MenuItem).submenu;
			if(submenu != null) {
				unbind_widget(submenu);
			}
			widget.notify["submenu"] -= submenu_notify;
		}
	}
	public void bind_menu(Gtk.Widget window, Gtk.Widget menu) {
		weak string window_name = document().wrap(window);
		weak string menu_name = document().wrap(menu);
		bind_widget(window);
		bind_widget(menu, window);
		window.realize += (window) => {
			weak string window_name = document().wrap(window);
			client().register_window(window_name, XWINDOW(window.window).to_string());
		};
		window.unrealize += (window) => {
			weak string window_name = document().wrap(window);
			client().unregister_window(window_name);
		};
	}
	public void unbind_menu(Gtk.Widget window, Gtk.Widget menu) {
		weak string window_name = document().wrap(window);
		weak string menu_name = document().wrap(menu);
		weak Gnomenu.Document.Widget node =document().lookup(menu_name) as Gnomenu.Document.Widget;
		if(node != null && node.parent != null) node.parent.remove(node);
	}
}
