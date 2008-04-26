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
	public signal void onevent(string msg);
	public int64 ping (string msg) {
		message (msg);
		return counter++;
	}
}

public class Valadbus.MainWindow : Window {
	private DBus.Connection _conn;
	private TestServer server;
	private dynamic DBus.Object proxy;

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

		var toolbar_server = new Toolbar ();
		vbox.pack_start (toolbar_server, false, false, 0);
		toolbar_server.show ();

		var toolbar_client = new Toolbar ();
		vbox.pack_start (toolbar_client, false, false, 0);
		toolbar_client.show ();

		var button_listen = new ToolButton (null, "listen");
		toolbar_server.insert (button_listen, -1);
		button_listen.is_important = true;
		button_listen.clicked += on_listen_clicked;
		button_listen.show ();

		var button_event = new ToolButton (null, "event");
		toolbar_server.insert (button_event, -1);
		button_event.is_important = true;
		button_event.clicked += on_event_clicked;
		button_event.show ();

		var button_bind = new ToolButton (null, "bind");
		toolbar_client.insert (button_bind, -1);
		button_bind.is_important = true;
		button_bind.clicked += on_bind_clicked;
		button_bind.show ();

		var button_ping = new ToolButton (null, "ping");
		toolbar_client.insert (button_ping, -1);
		button_ping.is_important = true;
		button_ping.clicked += on_ping_clicked;
		button_ping.show ();


	}

	public void run () {
		show ();

		Gtk.main ();
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
	private void on_event_clicked(ToolButton button){
		try {
			server.onevent("a big event");
			message("emit a event");
		} catch (Error e) {
			message("emiting signal failed %s", e.message);
		}
	}

	private void on_bind_clicked(ToolButton button){
		try {
			proxy = conn.get_object ("org.gnome.TestService", "/org/gnome/test", "org.gnome.TestServer");
			proxy.onevent += on_event_received;
		} catch (Error e) {
			message("bind failed %s", e.message);
		}
	}
	private void on_event_received(dynamic DBus.Object proxy, string message_){
		message ("event: message %s", message_);
	}
	private void on_ping_clicked(ToolButton button){
		try {
			int64 pong = proxy.ping ("Hello from Vala");
			message (pong.to_string ());
			
		} catch (Error e) {
			message("ping failed %s", e.message);
		}
	}

	static int main (string[] args) {
		Gtk.init (ref args);

		var window = new MainWindow ();
		window.run ();
		return 0;
	}

}
