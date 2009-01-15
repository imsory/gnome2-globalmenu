using Gtk;
using Gnomenu;

namespace Gnomenu {
	class TestGrab: TestMan {
		TestGrab() {
			base("/Grab");

			add("Grab", () => {
				Gtk.Window window = new Gtk.Window(WindowType.TOPLEVEL);
				Gtk.Window root = new Window.from_gdk_window(Gdk.get_default_root_window());
				window.destroy += Gtk.main_quit;
				window.show_all();

				uint keyval = Gdk.keyval_from_name("F10");
				if(false == grab_key(root.window, keyval, 0)) {
					message("grab failed");
				}
				root.key_press_event += (window, event) => {
					message("key: %s", Gdk.keyval_name(event.keyval));
				};
				Gtk.main();
			});
		}
		public static int main(string[] args) {
			Test.init(ref args);
			Gtk.init(ref args);
			var t = new TestGrab();

			t.run();
			return 0;
		}
	}
}