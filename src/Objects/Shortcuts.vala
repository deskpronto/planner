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

public class Objects.Shortcuts : GLib.Object {
    public string name { get; set; }
    public string[] accels { get; set; }

    public Shortcuts (string name, string[] accels) {
        this.name = name;
        this.accels = accels;
    }
}
