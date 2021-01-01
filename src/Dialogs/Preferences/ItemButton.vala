/*
* Copyright © 2021 Sync (https://syncyou.app)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Sync <info@syncyou.app>
*/

public class Dialogs.Preferences.ItemButton : Gtk.EventBox {
    public signal void activated ();
    public Gtk.Label title_label;

    public ItemButton (string title, string button_text, bool visible_separator=true) {
        title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("font-weight-600");

        var default_button = new Gtk.Button.with_label (button_text);
        default_button.can_focus = false;
        default_button.valign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.margin_start = 12;
        box.margin_end = 12;
        box.margin_top = 6;
        box.margin_bottom = 6;
        box.hexpand = true;
        box.pack_start (title_label, false, true, 0);
        box.pack_end (default_button, false, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class ("preferences-view");
        main_box.hexpand = true;
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (box, false, true, 0);

        if (visible_separator == true) {
            main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        }

        default_button.clicked.connect (() => {
            activated ();
        });

        add (main_box);
    }
}
