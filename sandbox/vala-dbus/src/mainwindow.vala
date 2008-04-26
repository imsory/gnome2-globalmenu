/* mainwindow.vala
 *
 * Copyright (C) 2008  
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	 <>
 */

using GLib;
using Gtk;

[DBus (name = "org.gnome.TestServer")]
public class TestServer : GLib.Object {
	int64 counter;
	public signal void event(string msg);
	public int64 ping (string msg) {
		message (msg);
		return counter++;
	}
}

public class Valadbus.MainWindow : Window {
	private TextBuffer text_buffer;
	private string filename;
	private DBus.Connection _conn;
	private TestServer server;
	public DBus.Connection conn {
		get {
			if(_conn == null) _conn = DBus.Bus.get (DBus.BusType.SESSION); 
			return _conn;
		}
	}

	public MainWindow () {
		title = "vala-dbus";
	}

	construct {
		set_default_size (600, 400);

		destroy += Gtk.main_quit;

		var vbox = new VBox (false, 0);
		add (vbox);
		vbox.show ();

		var toolbar = new Toolbar ();
		vbox.pack_start (toolbar, false, false, 0);
		toolbar.show ();

		var button = new ToolButton.from_stock (Gtk.STOCK_SAVE);
		toolbar.insert (button, -1);
		button.is_important = true;
		button.clicked += on_save_clicked;
		button.show ();

		var button_listen = new ToolButton (null, "listen");
		toolbar.insert (button_listen, -1);
		button_listen.is_important = true;
		button_listen.clicked += on_listen_clicked;
		button_listen.show ();

		var button_ping = new ToolButton (null, "ping");
		toolbar.insert (button_ping, -1);
		button_ping.is_important = true;
		button_ping.clicked += on_ping_clicked;
		button_ping.show ();

		var button_event = new ToolButton (null, "event");
		toolbar.insert (button_event, -1);
		button_event.is_important = true;
		button_event.clicked += on_event_clicked;
		button_event.show ();

		var scrolled_window = new ScrolledWindow (null, null);
		vbox.pack_start (scrolled_window, true, true, 0);
		scrolled_window.hscrollbar_policy = PolicyType.AUTOMATIC;
		scrolled_window.vscrollbar_policy = PolicyType.AUTOMATIC;
		scrolled_window.show ();

		text_buffer = new TextBuffer (null);

		var text_view = new TextView.with_buffer (text_buffer);
		scrolled_window.add (text_view);
		text_view.show ();

	}

	public void run () {
		show ();

		Gtk.main ();
	}

	private void on_save_clicked (ToolButton button) {
		if (filename == null) {
			var dialog = new FileChooserDialog (_("Save File"), this, FileChooserAction.SAVE,
				Gtk.STOCK_CANCEL, ResponseType.CANCEL,
				Gtk.STOCK_SAVE, ResponseType.ACCEPT);
			dialog.set_do_overwrite_confirmation (true);
			if (dialog.run () == ResponseType.ACCEPT) {
				filename = dialog.get_filename ();
			}

			dialog.destroy ();
			if (filename == null) {
				return;
			}
		}

		try {
			TextIter start_iter, end_iter;
			text_buffer.get_bounds (out start_iter, out end_iter);
			string text = text_buffer.get_text (start_iter, end_iter, true);
			FileUtils.set_contents (filename, text, -1);
		} catch (FileError e) {
			critical ("Error while trying to save file: %s", e.message);
			filename = null;
		}

	}
	private void on_listen_clicked(ToolButton button){
		try {
			dynamic DBus.Object bus = conn.get_object("org.freedesktop.DBus", "/org/freedesktop/DBus",
				"org.freedesktop.DBus");
			uint request_name_result = bus.RequestName ("org.gnome.TestService", (uint) 0);
			if (request_name_result == DBus.RequestNameReply.PRIMARY_OWNER) {
				server = new TestServer();
				conn.register_object ("/org/gnome/test", server);
				message("object registered");
			} else {
				message("object not registered");
			}
		} catch (Error e) {
			critical ("Error while creating dbus service %s", e.message);
		}
	}
	private void on_ping_clicked(ToolButton button){
		try {
		dynamic DBus.Object test_server_object = conn.get_object ("org.gnome.TestService", "/org/gnome/test", "org.gnome.TestServer");
		int64 pong = test_server_object.ping ("Hello from Vala");
		message (pong.to_string ());
		} catch (Error e) {
			message("ping failed %s", e.message);
		}
	}
	private void on_event_clicked(ToolButton button){
		try {
			server.event("a big event");
		} catch (Error e) {
			message("emiting signal failed %s", e.message);
		}
	}
	static int main (string[] args) {
		Gtk.init (ref args);

		var window = new MainWindow ();
		window.run ();
		return 0;
	}

}
