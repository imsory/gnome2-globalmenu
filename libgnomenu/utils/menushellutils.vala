namespace Gnomenu {
	[CCode (cname="gtk_menu_shell_get_item")]
	public extern weak Gtk.MenuItem gtk_menu_shell_get_item(Gtk.MenuShell * menu_shell, int position);
	[CCode (cname="gtk_menu_shell_remove_all")]
	public extern void gtk_menu_shell_remove_all(Gtk.MenuShell * menushell);
	[CCode (cname="gtk_menu_shell_set_length")]
	public extern void gtk_menu_shell_set_length(Gtk.MenuShell * menushell, int length);
	[CCode (cname="gtk_menu_shell_get_length")]
	public extern int gtk_menu_shell_get_length(Gtk.MenuShell * menushell);
	[CCode (cname="gtk_menu_shell_get_item_position")]
	public extern int gtk_menu_shell_get_item_position(Gtk.MenuShell * menu_shell, Gtk.MenuItem * item);

}
