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

public class Dialogs.Preferences.Preferences : Gtk.Dialog {
    public string view { get; construct; }
    private Gtk.Stack stack;
    private uint timeout_id = 0;

    private const Gtk.TargetEntry[] TARGET_ENTRIES_LABELS = {
        {"LABELROW", Gtk.TargetFlags.SAME_APP, 0}
    };

    public Preferences (string view="home") {
        Object (
            view: view,
            transient_for: Planner.instance.main_window,
            deletable: true,
            resizable: true,
            destroy_with_parent: true,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
            modal: true,
            title: _("Preferences")
        );
    }

    construct {
        get_style_context ().add_class ("app");

        Planner.event_bus.unselect_all ();
        width_request = 525;
        height_request = 500;

        stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        stack.add_named (get_home_widget (), "home");
        stack.add_named (get_homepage_widget (), "homepage");
        stack.add_named (get_badge_count_widget (), "badge-count");
        stack.add_named (get_theme_widget (), "theme");
        stack.add_named (get_task_widget (), "task");
        stack.add_named (get_quick_add_widget (), "quick-add");
        stack.add_named (get_plugins_widget (), "plugins");
        stack.add_named (get_todoist_widget (), "todoist");
        stack.add_named (get_general_widget (), "general");
        stack.add_named (get_labels_widget (), "labels");
        stack.add_named (get_calendar_widget (), "calendar");

        Timeout.add (125, () => {
            stack.visible_child_name = view;
            return GLib.Source.REMOVE;
        });

        var stack_scrolled = new Gtk.ScrolledWindow (null, null);
        stack_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        stack_scrolled.width_request = 246;
        stack_scrolled.expand = true;
        stack_scrolled.add (stack);

        var content_area = get_content_area ();
        content_area.border_width = 0;
        content_area.add (stack_scrolled);

        // add_button (_("Close"), Gtk.ResponseType.CLOSE);
        
        Planner.utils.init_labels_color ();

        response.connect ((response_id) => {
            destroy ();
        });

        key_press_event.connect ((event) => {
            if (event.keyval == 65307) {
                return true;
            }

            return false;
        });
    }

    private Gtk.Widget get_plugins_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("preferences-plugin", _("Plugins"));

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (Planner.plugins.get_view (), false, true, 0);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });
        
        return main_box;
    }

    private Gtk.Widget get_home_widget () {
        /* General */
        var general_label = new Granite.HeaderLabel (_("General"));
        general_label.margin_start = 6;

        var start_page_item = new Dialogs.Preferences.Item ("go-home", _("Homepage"));
        var badge_item = new Dialogs.Preferences.Item ("planner-badge-count", _("Badge Count"));
        var theme_item = new Dialogs.Preferences.Item ("preferences-color", _("Appearance"));
        var task_item = new Dialogs.Preferences.Item ("gnome-menu", _("Padrões de tarefas"));
        var quick_add_item = new Dialogs.Preferences.Item ("planner-quick-add", _("Quick Add"));
        var general_item = new Dialogs.Preferences.Item ("preferences-system", _("General"), true);

        var general_grid = new Gtk.Grid ();
        general_grid.valign = Gtk.Align.START;
        general_grid.get_style_context ().add_class ("preferences-view");
        general_grid.orientation = Gtk.Orientation.VERTICAL;
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
		general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        general_grid.add (start_page_item);
        general_grid.add (badge_item);
        general_grid.add (theme_item);
        general_grid.add (task_item);
        general_grid.add (quick_add_item);
        general_grid.add (general_item);

        /* Addons */
        var addons_label = new Granite.HeaderLabel (_("Add-ons"));
        addons_label.margin_start = 6;

        var todoist_item = new Dialogs.Preferences.Item ("planner-todoist", "Todoist");
        var plugins_item = new Dialogs.Preferences.Item ("preferences-plugin", "Complementos");
        var calendar_item = new Dialogs.Preferences.Item ("orage", _("Calendar Events"));
        var labels_item = new Dialogs.Preferences.Item ("tag", _("Labels"));
        var shortcuts_item = new Dialogs.Preferences.Item ("preferences-desktop-keyboard", _("Keyboard Shortcuts"), true);

        var share_b = new Gtk.Button.with_label (_("Share"));
        share_b.clicked.connect (() => {
            var s = new Services.ExportImport ();
            s.save_file_as ();
        });

        var addons_grid = new Gtk.Grid ();
        addons_grid.margin_top = 18;
        addons_grid.valign = Gtk.Align.START;
        addons_grid.get_style_context ().add_class ("preferences-view");
        addons_grid.orientation = Gtk.Orientation.VERTICAL;
        addons_grid.add (todoist_item);
        addons_grid.add (calendar_item);
        addons_grid.add (labels_item);
        addons_grid.add (plugins_item);
        // addons_grid.add (shortcuts_item);
        addons_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var others_grid = new Gtk.Grid ();
        others_grid.margin_top = 18;
        others_grid.margin_bottom = 3;
        others_grid.valign = Gtk.Align.START;
        others_grid.get_style_context ().add_class ("preferences-view");
        others_grid.orientation = Gtk.Orientation.VERTICAL;

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.valign = Gtk.Align.START;
        main_grid.add (general_grid);
        main_grid.add (addons_grid);
        main_grid.add (others_grid);

        var main_scrolled = new Gtk.ScrolledWindow (null, null);
        main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_scrolled.expand = true;
        main_scrolled.add (main_grid);

        start_page_item.activated.connect (() => {
            stack.visible_child_name = "homepage";
        });

        badge_item.activated.connect (() => {
            stack.visible_child_name = "badge-count";
        });

        theme_item.activated.connect (() => {
            stack.visible_child_name = "theme";
        });

        plugins_item.activated.connect (() => {
            stack.visible_child_name = "plugins";
        });

        task_item.activated.connect (() => {
            stack.visible_child_name = "task";
        });

        quick_add_item.activated.connect (() => {
            stack.visible_child_name = "quick-add";
        });

        general_item.activated.connect (() => {
            stack.visible_child_name = "general";
        });

        todoist_item.activated.connect (() => {
            if (Planner.settings.get_boolean ("todoist-account")) {
                stack.visible_child_name = "todoist";
            } else {
                var todoist_oauth = new Dialogs.TodoistOAuth ("preferences");
                todoist_oauth.show_all ();
            }
        });

        labels_item.activated.connect (() => {
            stack.visible_child_name = "labels";
        });

        shortcuts_item.activated.connect (() => {
            destroy ();

            var dialog = new Dialogs.ShortcutsDialog ();
            dialog.destroy.connect (Gtk.main_quit);
            dialog.show_all ();
        });

        calendar_item.activated.connect (() => {
            stack.visible_child_name = "calendar";
        });

        //  backups_item.activated.connect (() => {
        //      stack.visible_child_name = "backups";
        //  });

        return main_scrolled;
    }

    private Gtk.Widget get_homepage_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("go-home", _("Homepage"));

        var description_label = new Gtk.Label (
            _("When you open up Planner, make sure you see the tasks that are most important. The default homepage is your <b>Inbox</b> view, but you can change it to whatever you'd like.") // vala-lint=line-length
        );
        description_label.justify = Gtk.Justification.FILL;
        description_label.use_markup = true;
        description_label.wrap = true;
        description_label.xalign = 0;
        description_label.margin_bottom = 6;
        description_label.margin_top = 6;
        description_label.margin_start = 12;
        description_label.margin_end = 12;

        var inbox_radio = new Gtk.RadioButton.with_label (null, _("Inbox"));
        inbox_radio.margin_top = 12;
        inbox_radio.get_style_context ().add_class ("preference-item-radio");

        var today_radio = new Gtk.RadioButton.with_label_from_widget (inbox_radio, _("Today"));
        today_radio.get_style_context ().add_class ("preference-item-radio");

        var upcoming_radio = new Gtk.RadioButton.with_label_from_widget (inbox_radio, _("Upcoming"));
        upcoming_radio.get_style_context ().add_class ("preference-item-radio");

        if (!Planner.settings.get_boolean ("homepage-project")) {
            int type = Planner.settings.get_enum ("homepage-item");
            if (type == 0) {
                inbox_radio.active = true;
            } else if (type == 1) {
                today_radio.active = true;
            } else if (type == 2) {
                upcoming_radio.active = true;
            }
        }

        var project_header = new Granite.HeaderLabel (_("Projects"));
        project_header.margin_start = 12;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.margin_top = 6;
        box.valign = Gtk.Align.START;
        box.hexpand = true;
        box.pack_start (description_label, false, true, 0);
        box.pack_start (inbox_radio, false, true, 0);
        box.pack_start (today_radio, false, true, 0);
        box.pack_start (upcoming_radio, false, true, 0);
        box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        box.pack_start (project_header, false, true, 0);

        foreach (var project in Planner.database.get_all_projects ()) {
            if (project.inbox_project == 0) {
                var project_radio = new Gtk.RadioButton.with_label_from_widget (inbox_radio, project.name);
                project_radio.get_style_context ().add_class ("preference-item-radio");
                box.pack_start (project_radio, false, false, 0);

                project_radio.toggled.connect (() => {
                    Planner.settings.set_boolean ("homepage-project", true);
                    Planner.settings.set_int64 ("homepage-project-id", project.id);
                });

                if (Planner.settings.get_boolean ("homepage-project")) {
                    if (Planner.settings.get_int64 ("homepage-project-id") == project.id) {
                        project_radio.active = true;
                    }
                }
            }
        }

        box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);

        var box_scrolled = new Gtk.ScrolledWindow (null, null);
        box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        box_scrolled.expand = true;
        box_scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (box_scrolled, false, true, 0);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        inbox_radio.toggled.connect (() => {
            Planner.settings.set_boolean ("homepage-project", false);
            Planner.settings.set_enum ("homepage-item", 0);
        });

        today_radio.toggled.connect (() => {
            Planner.settings.set_boolean ("homepage-project", false);
            Planner.settings.set_enum ("homepage-item", 1);
        });

        upcoming_radio.toggled.connect (() => {
            Planner.settings.set_boolean ("homepage-project", false);
            Planner.settings.set_enum ("homepage-item", 2);
        });

        return main_box;
    }

    private Gtk.Widget get_task_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("gnome-menu", _("Padrões das tarefas"));

        var new_tasks_position_switch = new Dialogs.Preferences.ItemSwitch (
            _("New tasks on top"),
            Planner.settings.get_enum ("new-tasks-position") == 0
        );
        new_tasks_position_switch.margin_top = 12;

        var underline_tasks_switch = new Dialogs.Preferences.ItemSwitch (
            _("Sublinhar tarefas concluídas."),
            Planner.settings.get_boolean ("underline-completed-tasks")
        );
        underline_tasks_switch.margin_top = 12;

        List<string> list = new List<string> ();
        list.append (_("Priority 1"));
        list.append (_("Priority 2"));
        list.append (_("Priority 3"));
        list.append (_("None"));

        var default_priority = new Dialogs.Preferences.ItemSelect (
            _("Prioridade padrão"),
            Planner.settings.get_enum ("default-priority"),
            list
        );
        default_priority.margin_top = 12;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.margin_top = 6;
        box.valign = Gtk.Align.START;
        box.hexpand = true;
        box.add (new_tasks_position_switch);
        box.add (new Gtk.Label (_("Indicate the position where the new tasks were created.")) {
            wrap = true,
            xalign = 0,
            margin_start = 12,
            margin_end = 12,
            justify = Gtk.Justification.FILL
        });
        box.add (underline_tasks_switch);
        box.add (default_priority);

        var box_scrolled = new Gtk.ScrolledWindow (null, null);
        box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        box_scrolled.expand = true;
        box_scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (box_scrolled, false, true, 0);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        new_tasks_position_switch.activated.connect ((value) => {
            if (value) {
                Planner.settings.set_enum ("new-tasks-position", 0);
            } else {
                Planner.settings.set_enum ("new-tasks-position", -1);
            }
        });

        underline_tasks_switch.activated.connect ((value) => {
            Planner.settings.set_boolean ("underline-completed-tasks", value);
        });

        default_priority.activated.connect ((index) => {
            Planner.settings.set_enum ("default-priority", index);
        });

        return main_box;
    }

    private Gtk.Widget get_badge_count_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("planner-badge-count", _("Badge Count"));

        var description_label = new Gtk.Label (
            _("Choose which items should be counted for the badge on the application icon.")
        );
        description_label.justify = Gtk.Justification.FILL;
        description_label.wrap = true;
        description_label.xalign = 0;
        description_label.margin_bottom = 6;
        description_label.margin_top = 6;
        description_label.margin_start = 12;
        description_label.margin_end = 12;

        var none_radio = new Gtk.RadioButton.with_label (null, _("None"));
        none_radio.margin_top = 12;
        none_radio.get_style_context ().add_class ("preference-item-radio");

        var inbox_radio = new Gtk.RadioButton.with_label_from_widget (none_radio, _("Inbox"));
        inbox_radio.get_style_context ().add_class ("preference-item-radio");

        var today_radio = new Gtk.RadioButton.with_label_from_widget (none_radio, _("Today"));
        today_radio.get_style_context ().add_class ("preference-item-radio");

        var today_inbox_radio = new Gtk.RadioButton.with_label_from_widget (none_radio, _("Today + Inbox"));
        today_inbox_radio.get_style_context ().add_class ("preference-item-radio");

        int type = Planner.settings.get_enum ("badge-count");
        if (type == 0) {
            none_radio.active = true;
        } else if (type == 1) {
            inbox_radio.active = true;
        } else if (type == 2) {
            today_radio.active = true;
        } else {
            today_inbox_radio.active = true;
        }

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_top = 6;
        main_box.valign = Gtk.Align.START;
        main_box.hexpand = true;
        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (description_label, false, true, 0);
        main_box.pack_start (none_radio, false, true, 0);
        main_box.pack_start (inbox_radio, false, true, 0);
        main_box.pack_start (today_radio, false, true, 0);
        main_box.pack_start (today_inbox_radio, false, true, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        none_radio.toggled.connect (() => {
            Planner.settings.set_enum ("badge-count", 0);
        });

        inbox_radio.toggled.connect (() => {
            Planner.settings.set_enum ("badge-count", 1);
        });

        today_radio.toggled.connect (() => {
            Planner.settings.set_enum ("badge-count", 2);
        });

        today_inbox_radio.toggled.connect (() => {
            Planner.settings.set_enum ("badge-count", 3);
        });

        return main_box;
    }

    private Gtk.Widget get_theme_widget () {
        var info_box = new Dialogs.Preferences.TopBox ("night-light", _("Appearance"));

        var description_label = new Gtk.Label (
            _("Personalize the look and feel of your Planner by choosing the theme that best suits you.")
        );
        description_label.margin = 6;
        description_label.margin_bottom = 6;
        description_label.margin_start = 12;
        description_label.margin_end = 12;
        description_label.justify = Gtk.Justification.FILL;
        description_label.wrap = true;
        description_label.xalign = 0;

        var light_radio = new Gtk.RadioButton.with_label (null, _("Light"));
        light_radio.get_style_context ().add_class ("preference-item-radio");

        var night_radio = new Gtk.RadioButton.with_label_from_widget (light_radio, _("Night"));
        night_radio.get_style_context ().add_class ("preference-item-radio");

        var dark_blue_radio = new Gtk.RadioButton.with_label_from_widget (light_radio, _("Dark Blue"));
        dark_blue_radio.get_style_context ().add_class ("preference-item-radio");

        var arc_dark_radio = new Gtk.RadioButton.with_label_from_widget (light_radio, _("Arc Dark"));
        arc_dark_radio.get_style_context ().add_class ("preference-item-radio");

        var font_size_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.5, 2, 0.1);
        font_size_scale.hexpand = true;
        font_size_scale.set_value (Planner.settings.get_double ("font-scale"));
        font_size_scale.add_mark (1, Gtk.PositionType.LEFT, null);
        font_size_scale.draw_value = false;
        font_size_scale.margin_top = 3;
        font_size_scale.margin_bottom = 6;

        var font_size_small = new Gtk.Image ();
        font_size_small.gicon = new ThemedIcon ("font-x-generic-symbolic");
        font_size_small.pixel_size = 16;
        font_size_small.margin_start = 12;
        
        var font_size_large = new Gtk.Image ();
        font_size_large.gicon = new ThemedIcon ("font-x-generic-symbolic");
        font_size_large.pixel_size = 24;
        font_size_large.margin_end = 12;

        var font_size_grid = new Gtk.Grid ();
        font_size_grid.get_style_context ().add_class ("preferences-view");
        font_size_grid.column_spacing = 12;
        font_size_grid.hexpand = true;
        font_size_grid.add (font_size_small);
        font_size_grid.add (font_size_scale);
        font_size_grid.add (font_size_large);
        font_size_grid.valign = Gtk.Align.START;

        List<string> list = new List<string> ();
        list.append ("elementary");
        list.append ("Ubuntu");
        list.append ("Windows");
        list.append ("macOS");
        list.append ("Minimize Left");
        list.append ("Minimize Right");
        list.append ("Close Only Left");
        list.append ("Close Only Right");

        var use_system_decoration_val = Planner.settings.get_boolean ("use-system-decoration");
        var button_layout = new Dialogs.Preferences.ItemSelect (
            _("Button layout"),
            Planner.settings.get_enum ("button-layout"),
            list
        );
        button_layout.set_combobox_sensitive (!use_system_decoration_val);
        button_layout.margin_top = 12;

        var use_system_decoration = new Dialogs.Preferences.ItemSwitch (
            // The reason we need a restart is because GTK has to tell the
            // window manager whether to add any window decorations *before*
            // the window is realized.
            _("Use system window decoration (needs restart)"),
            use_system_decoration_val
        );
        use_system_decoration.margin_top = 12;
       
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.valign = Gtk.Align.START;
        main_box.expand = true;

        main_box.pack_start (info_box, false, false, 0);
        main_box.pack_start (description_label, false, false, 0);
        main_box.pack_start (new Granite.HeaderLabel (_("Theme")) {
            margin_start = 12
        }, false, false, 0);
        main_box.pack_start (light_radio, false, false, 0);
        main_box.pack_start (night_radio, false, false, 0);
        main_box.pack_start (dark_blue_radio, false, false, 0);
        main_box.pack_start (arc_dark_radio, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (new Granite.HeaderLabel (_("Font Size")) {
            margin_start = 12,
            margin_top = 12
        }, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (font_size_grid);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (button_layout);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);
        main_box.pack_start (use_system_decoration);

        if (Planner.settings.get_enum ("appearance") == 0) {
            light_radio.active = true;
        } else if (Planner.settings.get_enum ("appearance") == 1) {
            night_radio.active = true;
        } else if (Planner.settings.get_enum ("appearance") == 2) {
            dark_blue_radio.active = true;
        } else if (Planner.settings.get_enum ("appearance") == 3) {
            arc_dark_radio.active = true;
        }   

        info_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        light_radio.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 0);
        });

        night_radio.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 1);
        });

        dark_blue_radio.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 2);
        });

        arc_dark_radio.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 3);
        });

        font_size_scale.value_changed.connect (() => {
            Planner.settings.set_double ("font-scale", font_size_scale.get_value ());
        });

        button_layout.activated.connect ((index) => {
            Planner.settings.set_enum ("button-layout", index);
        });

        use_system_decoration.activated.connect ((value) => {
            Planner.settings.set_boolean ("use-system-decoration", value);
            button_layout.set_combobox_sensitive (!value);
        });

        return main_box;
    }

    private Gtk.Widget get_quick_add_widget () {
        var info_box = new Dialogs.Preferences.TopBox ("night-light", _("Quick Add"));

        var description_label = new Gtk.Label (
            _("Don't worry about which app you're using. You can use a keyboard shortcut to open the Quick Add window, where you can enter a pending task and quickly return to work. You can change the keyboard shortcut whenever you want.") // vala-lint=line-length
        );
        description_label.margin = 6;
        description_label.margin_bottom = 6;
        description_label.margin_start = 12;
        description_label.margin_end = 12;
        description_label.justify = Gtk.Justification.FILL;
        description_label.wrap = true;
        description_label.xalign = 0;

        var enabled_switch = new Dialogs.Preferences.ItemSwitch (_("Enabled"), Planner.settings.get_boolean ("quick-add-enabled"));
        enabled_switch.margin_top = 6;

        var shortcut_label = new Gtk.Label (_("Keyboard Shortcuts"));
        shortcut_label.get_style_context ().add_class ("font-weight-600");

        string keys = Planner.settings.get_string ("quick-add-shortcut");
        uint accelerator_key;
        Gdk.ModifierType accelerator_mods;
        Gtk.accelerator_parse (keys, out accelerator_key, out accelerator_mods);
        var shortcut_hint = Gtk.accelerator_get_label (accelerator_key, accelerator_mods);

        var accels = new Widgets.ShortcutLabel (shortcut_hint.split ("+"));
        accels.halign = Gtk.Align.END;

        var keybinding_toggle_recording_button = new Gtk.ToggleButton.with_label (_ ("Press keys…"));
        keybinding_toggle_recording_button.get_style_context ().add_class ("flat");
        keybinding_toggle_recording_button.valign = Gtk.Align.CENTER;

        var shortcut_stack = new Gtk.Stack ();
        shortcut_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        shortcut_stack.add_named (accels, "accels");
        shortcut_stack.add_named (keybinding_toggle_recording_button, "button");

        var shortcut_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        shortcut_box.margin_start = 12;
        shortcut_box.margin_top = 3;
        shortcut_box.margin_bottom = 3;
        shortcut_box.margin_end = 12;
        shortcut_box.pack_start (shortcut_label, false, false, 0);
        shortcut_box.pack_end (shortcut_stack, false, false, 0);

        var shortcut_v_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        shortcut_v_box.margin_top = 6;
        shortcut_v_box.get_style_context ().add_class ("preferences-view");
        shortcut_v_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        shortcut_v_box.add (shortcut_box);

        var shortcut_eventbox = new Gtk.EventBox ();
        shortcut_eventbox.add (shortcut_v_box);

        var change_button = new Gtk.Button.with_label (_("Change Keyboard Shortcut"));
        change_button.can_focus = false;
        change_button.get_style_context ().add_class ("flat");
        change_button.get_style_context ().add_class ("no-padding");
        change_button.get_style_context ().add_class ("inbox");
        change_button.halign = Gtk.Align.END;
        change_button.margin_end = 6;

        var save_last_switch = new Dialogs.Preferences.ItemSwitch (
            _("Save Last Selected Project"),
            Planner.settings.get_boolean ("quick-add-save-last-project"),
            false
        );
        save_last_switch.margin_top = 6;
        
        var automatically_close_switch = new Dialogs.Preferences.ItemSwitch (
            _("Automatically close loses focus"),
            Planner.settings.get_boolean ("quick-add-close-loses-focus")
        );

        var revealer_box = new Gtk.Grid ();
        revealer_box.orientation = Gtk.Orientation.VERTICAL;
        revealer_box.add (shortcut_eventbox);
        revealer_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        revealer_box.add (change_button);
        revealer_box.add (save_last_switch);
        revealer_box.add (automatically_close_switch);

        var box_revealer = new Gtk.Revealer ();
        box_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        box_revealer.add (revealer_box);
        box_revealer.reveal_child = Planner.settings.get_boolean ("quick-add-enabled");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (info_box, false, false, 0);
        main_box.pack_start (description_label, false, false, 0);
        main_box.pack_start (enabled_switch, false, false, 0);
        main_box.pack_start (box_revealer, false, false, 0);

        shortcut_eventbox.enter_notify_event.connect ((event) => {
            // shortcut_stack.visible_child_name = "button";
            return true;
        });

        shortcut_eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            if (keybinding_toggle_recording_button.active == false) {
                // shortcut_stack.visible_child_name = "accels";
            }

            return true;
        });

        info_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        save_last_switch.activated.connect ((value) => {
            Planner.settings.set_boolean ("quick-add-save-last-project", value);
        });

        automatically_close_switch.activated.connect ((value) => {
            Planner.settings.set_boolean ("quick-add-close-loses-focus", value);
        });

        change_button.clicked.connect (() => {
            keybinding_toggle_recording_button.active = true;
            shortcut_stack.visible_child_name = "button";
        });
        
         // Listen to key events on the window for setting keyboard shortcuts
        this.key_release_event.connect ((event) => {
            if (keybinding_toggle_recording_button.active) {
                keybinding_toggle_recording_button.active = false;

                if (event.keyval == Gdk.Key.Escape && no_modifier_set (event.state)) {
                    return true;
                } else if (event.keyval == Gdk.Key.BackSpace && no_modifier_set (event.state)) {
                    Planner.settings.set_string ("quick-add-shortcut", "");
                } else if (event.is_modifier == 0) {
                    var mods = event.state & Gtk.accelerator_get_default_mod_mask ();
                    string accelerator = Gtk.accelerator_name (event.keyval, mods);
                    Planner.settings.set_string ("quick-add-shortcut", accelerator);
                }

                return true;
            }

            shortcut_stack.visible_child_name = "accels";
            return false;
        });

        Planner.settings.changed.connect ((key) => {
            if (key == "quick-add-shortcut" || key == "quick-add-enabled") {
                box_revealer.reveal_child = Planner.settings.get_boolean ("quick-add-enabled");

                string _keys = Planner.settings.get_string ("quick-add-shortcut");
                uint _accelerator_key;
                Gdk.ModifierType _accelerator_mods;
                Gtk.accelerator_parse (_keys, out _accelerator_key, out _accelerator_mods);
                var _shortcut_hint = Gtk.accelerator_get_label (_accelerator_key, _accelerator_mods);

                accels.update_accels (_shortcut_hint.split ("+"));

                // Set shortcut
                Planner.utils.set_quick_add_shortcut (_keys, Planner.settings.get_boolean ("quick-add-enabled"));
            }
        });

        enabled_switch.activated.connect ((val) => {
            Planner.settings.set_boolean ("quick-add-enabled", val);
        });

        return main_box;
    }

    private static bool no_modifier_set (Gdk.ModifierType mods) {
        return (mods & Gtk.accelerator_get_default_mod_mask ()) == 0;
    }

    private Gtk.Widget get_general_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("night-light", _("General"));
        top_box.margin_bottom = 12;

        var de_header = new Granite.HeaderLabel (_("DE Integration"));
        de_header.margin_start = 12;

        var run_background_switch = new Dialogs.Preferences.ItemSwitch (
            _("Run in background"), Planner.settings.get_boolean ("run-in-background")
        );

        var run_background_label = new Gtk.Label (
            _("Enable this setting to keep Planner running in the background when it closes. This will allow Planner to continue updating and sending reminder notifications.") // vala-lint=line-length
        );
        run_background_label.wrap = true;
        run_background_label.xalign = 0;
        run_background_label.margin_start = 12;
        run_background_label.halign = Gtk.Align.START;

        var run_startup_switch = new Dialogs.Preferences.ItemSwitch (
            _("Run on startup"), Planner.settings.get_boolean ("run-on-startup")
        );
        run_startup_switch.margin_top = 12;

        var run_startup_label = new Gtk.Label (_("Enable this setting to make Planner startup with the system."));
        run_startup_label.wrap = true;
        run_startup_label.xalign = 0;
        run_startup_label.margin_start = 12;
        run_startup_label.halign = Gtk.Align.START;

        // var database_settings = new Dialogs.Preferences.DatabaseSettings ();

        var dz_header = new Granite.HeaderLabel (_("Danger zone"));
        dz_header.get_style_context ().add_class ("label-danger");
        dz_header.margin_start = 12;
        dz_header.margin_top = 6;

        var database_header = new Granite.HeaderLabel (_("Date & time"));
        database_header.margin_start = 12;
        database_header.margin_top = 6;

        var clear_db_item = new Dialogs.Preferences.ItemButton (_("Reset all"), _("Reset"));
        var export_db_item = new Dialogs.Preferences.ItemButton (_("Export Database"), _("Export"));

        List<string> week_list = new List<string> ();
        week_list.append ("Domingo");
        week_list.append ("Segunda");
        week_list.append ("Terça");
        week_list.append ("Quarta");
        week_list.append ("Quinta");
        week_list.append ("Sexta");
        week_list.append ("Sábado");

        var start_week = new Dialogs.Preferences.ItemSelect (
            _("Start of the week"),
            Planner.settings.get_enum ("start-week"),
            week_list,
            false
        );
        start_week.margin_top = 12;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.expand = true;
        box.pack_start (de_header, false, false, 0);
        box.pack_start (run_background_switch, false, false, 0);
        box.pack_start (run_background_label, false, false, 0);
        box.pack_start (run_startup_switch, false, false, 0);
        box.pack_start (run_startup_label, false, false, 0);
        // box.pack_start (button_layout, false, false, 0);
        box.pack_start (start_week, false, false, 0);
        box.pack_start (export_db_item, false, false, 0);
        box.pack_start (dz_header, false, false, 0);
        box.pack_start (clear_db_item, false, false, 0);

        var box_scrolled = new Gtk.ScrolledWindow (null, null);
        box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        box_scrolled.expand = true;
        box_scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (box_scrolled, true, true, 0);

        run_startup_switch.activated.connect ((val) => {
            Planner.settings.set_boolean ("run-on-startup", val);
            Planner.utils.set_autostart (val);
        });

        run_background_switch.activated.connect ((val) => {
            Planner.settings.set_boolean ("run-in-background", val);
        });

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        start_week.activated.connect ((index) => {
            Planner.settings.set_enum ("start-week", index);
        });

        export_db_item.activated.connect (() => {
            var s = new Services.ExportImport ();
            s.save_file_as ();
        });

        clear_db_item.activated.connect (() => {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Are you sure you want to reset all?"),
                _("It process removes all stored information without the possibility of undoing it."),
                "edit-delete",
            Gtk.ButtonsType.CANCEL);

            var remove_button = new Gtk.Button.with_label (_("Reset all"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (remove_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                Planner.database.reset_all ();
                destroy ();
            }

            message_dialog.destroy ();
        });

        return main_box;
    }

    private Gtk.Widget get_labels_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("tag", _("Labels"));

        var description_label = new Gtk.Label (
            _("Save time by batching similar tasks together using labels. You’ll be able to pull up a list of all tasks with any given label in a matter of seconds.") // vala-lint=line-length
        );
        description_label.margin = 6;
        description_label.margin_bottom = 12;
        description_label.margin_start = 12;
        description_label.margin_end = 12;
        description_label.justify = Gtk.Justification.FILL;
        description_label.wrap = true;
        description_label.xalign = 0;

        var listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        listbox.get_style_context ().add_class ("background");
        listbox.hexpand = true;

        var box_scrolled = new Gtk.ScrolledWindow (null, null);
        box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        box_scrolled.expand = true;
        box_scrolled.add (listbox);

        Gtk.drag_dest_set (listbox, Gtk.DestDefaults.ALL, TARGET_ENTRIES_LABELS, Gdk.DragAction.MOVE);
        listbox.drag_data_received.connect ((context, x, y, selection_data, target_type, time) => {
            Widgets.LabelRow target;
            Widgets.LabelRow source;
            Gtk.Allocation alloc;
            int new_pos;

            target = (Widgets.LabelRow) listbox.get_row_at_y (y);
            target.get_allocation (out alloc);

            var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
            source = (Widgets.LabelRow) row;

            int last_index = (int) listbox.get_children ().length;

            if (target == null) {
                new_pos = last_index - 1;
            } else {
                new_pos = target.get_index () + 1;
            }

            source.get_parent ().remove (source);

            listbox.insert (source, new_pos);
            listbox.show_all ();

            update_label_order (listbox);
        });

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.hexpand = true;

        var new_label = new Widgets.NewLabel ();

        box.pack_start (description_label, false, false, 0);
        box.pack_start (new_label, false, true, 0);
        box.pack_start (box_scrolled, false, true, 0);
        box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        main_box.expand = true;

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (box, false, true, 0);
        add_all_labels (listbox, box_scrolled);

        Planner.database.label_added.connect ((label) => {
            var row = new Widgets.LabelRow (label);
            row.scrolled = box_scrolled;
            
            listbox.insert (row, 0);
            listbox.show_all ();

            update_label_order (listbox);
        });

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        listbox.row_activated.connect ((row) => {
            var item = ((Widgets.LabelRow) row);
            item.edit ();
        });

        new_label.insert_row.connect ((row, position) => {
            listbox.insert (row, position);
            listbox.show_all ();
        });

        return main_box;
    }

    private void update_label_order (Gtk.ListBox listbox) {
        timeout_id = Timeout.add (150, () => {
            timeout_id = 0;

            new Thread<void*> ("update_label_order", () => {
                listbox.foreach ((widget) => {
                    var row = (Gtk.ListBoxRow) widget;
                    int index = row.get_index ();

                    var label = ((Widgets.LabelRow) row).label;

                    new Thread<void*> ("update_label_order", () => {
                        Planner.database.update_label_item_order (label.id, index);

                        return null;
                    });
                });

                return null;
            });
            
            return GLib.Source.REMOVE;
        });
    }

    private Gtk.Widget get_todoist_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("planner-todoist", _("Todoist"));

        Granite.Widgets.Avatar user_avatar;
        if (Planner.settings.get_string ("todoist-user-image-id") != "") {
            user_avatar = new Granite.Widgets.Avatar.from_file (
                GLib.Path.build_filename (
                    Planner.utils.AVATARS_FOLDER,
                    Planner.settings.get_string ("todoist-user-image-id") + ".jpg"
                ),
                64
            );
        } else {
            user_avatar = new Granite.Widgets.Avatar.with_default_icon (64);
        }

        user_avatar.margin_top = 12;

        var username_label = new Gtk.Label (Planner.settings.get_string ("user-name"));
        username_label.margin_top = 6;
        username_label.get_style_context ().add_class ("h3");

        var email_label = new Gtk.Label (Planner.settings.get_string ("todoist-user-email"));
        email_label.get_style_context ().add_class ("dim-label");

        var last_update = new Gtk.Label (_("Last successful sync: %s".printf (
            Planner.utils.get_relative_datetime_from_string (Planner.settings.get_string ("todoist-last-sync"))
        )));
        last_update.margin_top = 12;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;

        var sync_server_switch = new Dialogs.Preferences.ItemSwitch (
            _("Sync server"), Planner.settings.get_boolean ("todoist-sync-server")
        );
        sync_server_switch.margin_top = 24;

        var sync_server_label = new Gtk.Label (
            _("Activate this setting so that Planner automatically synchronizes with your Todoist account every 15 minutes.") // vala-lint=line-length
        );
        sync_server_label.halign = Gtk.Align.START;
        sync_server_label.wrap = true;
        sync_server_label.margin_start = 12;
        sync_server_label.margin_top = 3;
        sync_server_label.xalign = (float) 0.0;

        var delete_image = new Gtk.Image ();
        delete_image.pixel_size = 16;
        delete_image.gicon = new ThemedIcon ("user-trash-symbolic");

        var delete_label = new Gtk.Label (_("Log out"));
        delete_label.get_style_context ().add_class ("font-weight-600");
        delete_label.get_style_context ().add_class ("label-danger");
        delete_label.ellipsize = Pango.EllipsizeMode.END;
        delete_label.halign = Gtk.Align.START;
        delete_label.valign = Gtk.Align.CENTER;

        var create_button = new Gtk.Button.from_icon_name ("pan-end-symbolic", Gtk.IconSize.MENU);
        create_button.get_style_context ().add_class ("flat");
        create_button.can_focus = false;
        create_button.valign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.hexpand = true;
        box.margin = 3;
        box.margin_start = 12;
        box.margin_end = 6;
        box.pack_start (delete_label, false, false, 0);
        box.pack_end (create_button, false, true, 0);

        var d_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        d_box.margin_top = 16;
        d_box.get_style_context ().add_class ("preferences-view");
        d_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        d_box.add (box);
        d_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var eventbox = new Gtk.EventBox ();
        eventbox.add (d_box);

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (user_avatar, false, false, 0);
        main_box.pack_start (username_label, false, false, 0);
        main_box.pack_start (email_label, false, false, 0);
        main_box.pack_start (last_update, false, false, 0);
        main_box.pack_start (sync_server_switch, false, true, 0);
        main_box.pack_start (sync_server_label, false, true, 0);
        main_box.pack_start (eventbox, false, true, 0);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        sync_server_switch.activated.connect ((val) => {
            Planner.settings.set_boolean ("todoist-sync-server", val);
        });

        eventbox.button_press_event.connect ((sender, evt) => {
            if (evt.type == Gdk.EventType.BUTTON_PRESS) {
                var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                    _("Are you sure you want to log out?"),
                    _("This process will close your Todoist session on this device."),
                    "system-log-out",
                Gtk.ButtonsType.CANCEL);

                var remove_button = new Gtk.Button.with_label (_("Log out"));
                remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
                message_dialog.add_action_widget (remove_button, Gtk.ResponseType.ACCEPT);

                message_dialog.show_all ();

                if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                    // Log out Todoist
                    Planner.todoist.log_out ();

                    // Save user name
                    Planner.settings.set_string ("user-name", GLib.Environment.get_real_name ());

                    // Create Inbox Project
                    var inbox_project = Planner.database.create_inbox_project ();

                    // Set settings
                    Planner.settings.set_int64 ("inbox-project", inbox_project.id);

                    destroy ();
                }

                message_dialog.destroy ();

                return true;
            }

            return false;
        });

        return main_box;
    }

    private Gtk.Widget get_calendar_widget () {
        var top_box = new Dialogs.Preferences.TopBox ("orage", _("Calendar Events"));

        var description_label = new Gtk.Label (
            _("You can connect your <b>Calendar</b> app to Planner to see your events and to-dos together in one place. You’ll see events from both personal and shared calendars in <b>Today</b> and <b>Upcoming</b>. This is useful when you’re managing your day, and as you plan the week ahead.") // vala-lint=line-length
        );
        description_label.margin = 6;
        description_label.use_markup = true;
        description_label.margin_bottom = 12;
        description_label.margin_start = 12;
        description_label.margin_end = 12;
        description_label.justify = Gtk.Justification.FILL;
        description_label.wrap = true;
        description_label.xalign = 0;

        var enabled_switch = new Dialogs.Preferences.ItemSwitch (_("Enabled"), Planner.settings.get_boolean ("calendar-enabled"));

        var listbox = new Gtk.ListBox ();
        listbox.margin_top = 12;
        listbox.valign = Gtk.Align.START;
        listbox.selection_mode = Gtk.SelectionMode.NONE;
        listbox.hexpand = true;
        listbox.get_style_context ().add_class ("background");
        listbox.set_sort_func ((child1, child2) => {
            var comparison = ((Widgets.SourceItem)child1).location.collate (((Widgets.SourceItem)child2).location);
            if (comparison == 0)
                return ((Widgets.SourceItem)child1).label.collate (((Widgets.SourceItem)child2).label);
            else
                return comparison;
        });

        var listbox_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        listbox_box.hexpand = true;
        listbox_box.pack_start (listbox, false, false, 0);
        listbox_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, true, 0);

        var revealer = new Gtk.Revealer ();
        revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        revealer.add (listbox_box);
        revealer.reveal_child = Planner.settings.get_boolean ("calendar-enabled");

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.hexpand = true;

        box.pack_start (description_label, false, false, 0);
        box.pack_start (enabled_switch, false, true, 0);
        box.pack_start (revealer, false, true, 0);

        var box_scrolled = new Gtk.ScrolledWindow (null, null);
        box_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        box_scrolled.expand = true;
        box_scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        main_box.expand = true;

        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (box_scrolled, false, true, 0);

        Planner.calendar_model.get_all_sources.begin (listbox);

        top_box.back_activated.connect (() => {
            stack.visible_child_name = "home";
        });

        enabled_switch.activated.connect ((val) => {
            Planner.settings.set_boolean ("calendar-enabled", val);
        });

        Planner.settings.changed.connect ((key) => {
            if (key == "calendar-enabled") {
                revealer.reveal_child = Planner.settings.get_boolean ("calendar-enabled");
            }
        });

        return main_box;
    }

    private void add_all_labels (Gtk.ListBox listbox, Gtk.ScrolledWindow scrolled) {
        foreach (Objects.Label label in Planner.database.get_all_labels ()) {
            var row = new Widgets.LabelRow (label);
            row.scrolled = scrolled;

            listbox.add (row);
        }

        listbox.show_all ();
    }
}

public class PreferenceItemRadio : Gtk.RadioButton {
    public PreferenceItemRadio () {
        get_style_context ().add_class ("preferences-view");
    }
}

public class PreferencePerson : Gtk.ListBoxRow {
    public string fullname { get; construct; }

    public PreferencePerson (string fullname) {
        Object (fullname: fullname);
    }

    construct {
        var avatar = new Gtk.Image.from_pixbuf (
            new Gdk.Pixbuf.from_resource_at_scale (Planner.utils.get_random_avatar (), 24, 24, false)
        );

        avatar.margin_start = 6;

        var name_label = new Gtk.Label (fullname);
        name_label.get_style_context ().add_class ("h3");
        name_label.get_style_context ().add_class ("font-weight-600");

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 6;
        grid.add (avatar);
        grid.add (name_label);
        
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class ("preferences-view");
        main_box.pack_start (grid);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        add (main_box);
    }
}
