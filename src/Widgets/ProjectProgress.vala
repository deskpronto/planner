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

using Gtk;
using Cairo;

public class Widgets.ProjectProgress : Gtk.Bin {
    public int min_d { get; construct; }
    private int _line_width;
    private double _percentage;
    private string _center_fill_color;
    private string _radius_fill_color;
    private string _progress_fill_color;

    [Description (nick = "Center Fill", blurb = "Center Fill toggle")]
    public bool center_filled {set; get; default = false;}

    [Description (nick = "Radius Fill", blurb = "Radius Fill toggle")]
    public bool radius_filled {set; get; default = false;}

    [Description (nick = "Font", blurb = "Font description without size, just the font name")]
    public string font {set; get; default = "URW Gothic";}

    [Description (nick = "Line Cap", blurb = "Line Cap for stroke as in Cairo.LineCap")]
    public Cairo.LineCap line_cap {set; get; default = Cairo.LineCap.BUTT;}

    [Description (nick = "Inside circle fill color", blurb = "Center pad fill color (Check Gdk.RGBA parse method)")]
    public string center_fill_color {
        get {
            return _center_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _center_fill_color = value;
            }
        }
    }

    [Description (nick = "Circular radius fill color", blurb = "The circular pad fill color (Check GdkRGBA parse method)")] // vala-lint=line-length
    public string radius_fill_color {
        get {
            return _radius_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _radius_fill_color = value;
            }
        }
    }

    [Description (nick = "Progress fill color", blurb = "Progress line color (Check GdkRGBA parse method)")]
    public string progress_fill_color {
        get {
            return _progress_fill_color;
        }
        set {
            var color = Gdk.RGBA ();
            if (color.parse (value)) {
                _progress_fill_color = value;
            }
        }
    }

    [Description (nick = "Circle width", blurb = "The circle radius line width")]
    public int line_width {
        get {
            return _line_width;
        }
        set {
            if (value < 0) {
                _line_width = 0;
            } else {
                _line_width = value;
            }
        }
    }

    [Description (nick = "Percentage/Value", blurb = "The percentage value [0.0 ... 1.0]")]
    public double percentage {
        get {
            return _percentage;
        }
        set {
            if (value > 1.0) {
                _percentage = 1.0;
            } else if (value < 0.0) {
                _percentage = 0.0;
            } else {
                _percentage = value;
            }
        }
    }

    construct {
        _line_width = 0;
        _percentage = 0;
        _center_fill_color = "#adadad";
        _radius_fill_color = "#d3d3d3";
        _progress_fill_color = "#4a90d9";
    }

    public ProjectProgress (int min_d=10) {
        Object (
            min_d: min_d
        );

        notify.connect (() => {
            queue_draw ();
        });
    }

    private int calculate_radius () {
        return int.min (get_allocated_width () / 2, get_allocated_height () / 2) - 1;
    }

    private int calculate_diameter () {
        return 2 * calculate_radius ();
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.CONSTANT_SIZE;
    }

    public override void get_preferred_width (out int min_w, out int natural_w) {
        var d = calculate_diameter ();
        min_w = min_d;
        if (d > min_d) {
            natural_w = d;
        } else {
            natural_w = min_d;
        }
    }

    public override void get_preferred_height (out int min_h, out int natural_h) {
        var d = calculate_diameter ();
        min_h = min_d;
        if (d > min_d) {
            natural_h = d;
        } else {
            natural_h = min_d;
        }
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        base.size_allocate (allocation);
    }

    public override bool draw (Cairo.Context cr) {
        int delta;
        Gdk.RGBA color;

        cr.save ();

        color = Gdk.RGBA ();

        var center_x = get_allocated_width () / 2;
        var center_y = get_allocated_height () / 2;
        var radius = calculate_radius ();

        if (radius - line_width < 0) {
            delta = 0;
            line_width = radius;
        } else {
            delta = radius - (line_width / 2);
        }

        color = Gdk.RGBA ();
        cr.set_line_cap (line_cap);
        cr.set_line_width (line_width);

        // Center Fill
        if (center_filled == true) {
            cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
            color.parse (center_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);
            cr.fill ();
        }

        // Radius Fill
        if (radius_filled == true) {
            cr.arc (center_x, center_y, delta, 0, 2 * Math.PI);
            color.parse (radius_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);
            cr.stroke ();
        }

        // Progress/Percentage Fill
        if (percentage > 0) {
            color.parse (progress_fill_color);
            Gdk.cairo_set_source_rgba (cr, color);

            if (line_width == 0) {
                cr.move_to (center_x, center_y);
                cr.arc (center_x,
                        center_y,
                        delta + 1,
                        1.5 * Math.PI,
                        (1.5 + percentage * 2) * Math.PI);
                cr.fill ();
            } else {
                cr.arc (center_x,
                        center_y,
                        delta,
                        1.5 * Math.PI,
                        (1.5 + percentage * 2) * Math.PI);
                cr.stroke ();
            }
        }

        cr.restore ();

        return base.draw (cr);
    }
}
