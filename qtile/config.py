# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import re
import socket
import subprocess
from typing import List  # noqa: F401
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Screen, Rule
from libqtile.lazy import lazy
# from libqtile.utils import guess_terminal

mod = "mod4"
terminal = "alacritty"
browser = "firefox"
editor = "subl3"
home = os.path.expanduser('~')

@lazy.function
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

@lazy.function
def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

keys = [
    # Switch between windows in current stack pane
    Key([mod], "Up", lazy.layout.up()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Right", lazy.layout.right()),

    # Move windows up or down in current stack
    Key([mod, "control"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "control"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "control"], "Left", lazy.layout.shuffle_left()),
    Key([mod, "control"], "Right", lazy.layout.shuffle_right()),

    # Swap panes of split stack
    Key([mod], "Tab", lazy.layout.rotate()),

    # Brightness
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight -inc 5")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -dec 5")),

    # Volume
    Key([], "XF86AudioMute", lazy.spawn("pulsemixer --toggle-mute")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pulsemixer --change-volume -5 --max-volume 100")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pulsemixer --change-volume +5 --max-volume 100")),
    # Key([], "XF86AudioMute", lazy.spawn("amixer -D pulse sset Master toggle")),
    # Key([], "XF86AudioLowerVolume", lazy.spawn("amixer -D pulse sset Master 5%-")),
    # Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer -D pulse sset Master 5%+")),

    # Media player
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    Key([], "XF86AudioStop", lazy.spawn("playerctl stop")),

    # Normalize layout
    Key([mod], "n", lazy.layout.normalize()),

    # Print Screen
    Key([], "Print", lazy.spawn("scrot 'Screen-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")),

    # RESIZE UP, DOWN, LEFT, RIGHT
    Key([mod, "control"], "l",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "Right",
        lazy.layout.grow_right(),
        lazy.layout.grow(),
        lazy.layout.increase_ratio(),
        lazy.layout.delete(),
        ),
    Key([mod, "control"], "h",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "Left",
        lazy.layout.grow_left(),
        lazy.layout.shrink(),
        lazy.layout.decrease_ratio(),
        lazy.layout.add(),
        ),
    Key([mod, "control"], "k",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        ),
    Key([mod, "control"], "j",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),
    Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        ),


    # Flip Layout for Monadtall/Monadwide
    Key([mod, "shift"], "f", lazy.layout.flip()),

    # Flip Layout for BSP
    Key([mod, "mod1"], "k", lazy.layout.flip_up()),
    Key([mod, "mod1"], "j", lazy.layout.flip_down()),
    Key([mod, "mod1"], "l", lazy.layout.flip_right()),
    Key([mod, "mod1"], "h", lazy.layout.flip_left()),

    # Move windows Up or Down BSP Layout
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),

    # Move windows Up or Down Monadtall/Monadwide Layout
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Left", lazy.layout.swap_left()),
    Key([mod, "shift"], "Right", lazy.layout.swap_right()),

    # Toggle Floating Layout
    Key([mod, "shift"], "space", lazy.window.toggle_floating()),


    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn(terminal)),

    # Dmenu
    Key([mod], "p", lazy.spawn("dmenu_run")),

    # File Manager
    Key([mod, "shift"], "p", lazy.spawn("pcmanfm")),
    Key([mod, "shift"], "o", lazy.spawn(terminal+'-e ranger')),
    Key([mod, "shift"], "b", lazy.spawn(browser)),
    Key([mod, "shift"], "v", lazy.spawn("vlc")),
    Key([mod, "shift"], "m", lazy.spawn("mousepad")),


    # Toggle between different layouts as defined below
    Key([mod, "shift"], "space", lazy.next_layout()),
    Key([mod, "shift"], "q", lazy.window.kill()),

    Key([mod, "shift"], "r", lazy.restart()),
    Key([mod, "control"], "c", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
]

groups = []

group_names = ["1", "2", "3", "4", "5", "6",]
# group_labels = ["", "", "", "", "", "", "", "", "", "",]
group_labels = ["home", "web", "sys", "file", "qbit", "xdm",]
group_layouts = ["monadtall", "monadtall", "monadtall", "monadtall", "monadtall", "monadtall",]

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        ))

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen()),
        Key([mod], "Tab", lazy.screen.next_group()),
        Key(["mod1"], "Tab", lazy.screen.next_group()),
        Key(["mod1", "shift"], "Tab", lazy.screen.prev_group()),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name) , lazy.group[i.name].toscreen()),
    ])

def init_layout_theme():
    return {"margin":5,
            "border_width":2,
            "border_focus": "#5e81ac",
            "border_normal": "#4c566a"
            }

layout_theme = init_layout_theme()

layouts = [
    layout.MonadTall(margin=8, border_width=2, border_focus="#5e81ac", border_normal="#4c566a"),
    layout.MonadWide(margin=8, border_width=2, border_focus="#5e81ac", border_normal="#4c566a"),
    layout.Matrix(**layout_theme),
    layout.Bsp(**layout_theme),
    layout.Floating(**layout_theme),
    layout.RatioTile(**layout_theme),
    layout.Max(**layout_theme)
    # layout.Max(),
    # layout.Stack(num_stacks=2),
    # Try more layouts by unleashing below layouts.
    # layout.Bsp(),
    # layout.Columns(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

def init_colors():
    return [["#2F343F", "#2F343F"], # color 0
            ["#2F343F", "#2F343F"], # color 1
            ["#c0c5ce", "#c0c5ce"], # color 2
            ["#fba922", "#fba922"], # color 3
            ["#3384d0", "#3384d0"], # color 4
            ["#f3f4f5", "#f3f4f5"], # color 5
            ["#cd1f3f", "#cd1f3f"], # color 6
            ["#62FF00", "#62FF00"], # color 7
            ["#6790eb", "#6790eb"], # color 8
            ["#a9a9a9", "#a9a9a9"]] # color 9


colors = init_colors()

def init_widgets_defaults():
    return dict(
        font='Ubuntu Bold',
        fontsize=12,
        padding=3,
        background=colors[0])

widget_defaults = init_widgets_defaults()

def init_widgets_list():
    prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())
    widgets_list = [
                widget.Sep(
                    linewidth = 0,
                    padding = 6,
                    foreground = colors[2],
                    background = colors[0]
                ),
                widget.GroupBox(
                    font = "Ubuntu Bold",
                    fontsize = 10,
                    active = colors[3],
                    block_highlight_text_color = '#fdfdfd',
                    borderwidth = 3,
                    highlight_color = '#cbb9b5',
                    highlight_method = "block",
                    inactive = colors[2],
                    this_current_screen_border = '#a42d3d',
                    this_screen_border = colors[3],
                    other_current_screen_border = colors[0],
                    other_screen_border = colors[3],
                    margin_x = 0,
                    margin_y = 3,
                    padding_x = 3,
                    padding_y = 5,
                    rounded = False,
                    foreground = colors[2],
                    background = colors[0]
                    #use_mouse_wheel = False
                ),
                widget.Sep(
                    linewidth = 0,
                    padding = 5,
                    foreground = colors[2],
                    background = colors[0]
                ),
                widget.WindowName(
                    foreground = colors[2],
                    padding = 5
                ),
                widget.Sep(
                       linewidth = 0,
                       padding = 10,
                       background = colors[0]
                ),
                widget.CurrentLayoutIcon(
                    font = 'Font Awesome 5 Free Solid',
                    custom_icon_paths = [os.path.expanduser("~/.config/qtile/icons")],
                    background = colors[0],
                    foreground = colors[2],
                    padding = 0,
                    scale = 0.6
                ),
                widget.CurrentLayout(
                    foreground = colors[2],
                    padding = 3
                ),
                # widget.TextBox(
                #     font = 'Font Awesome 5 Free Solid',
                #     text = '',
                #     background = colors[0],
                #     padding = 2
                # ),
                # widget.Memory(
                #     format = '{MemUsed}M / {MemTotal}M',
                #     interval = 5.0
                # ),
                # widget.TextBox(
                #     font = 'Font Awesome 5 Free Solid',
                #     text = '',
                #     background = colors[0],
                #     padding = 0
                # ),
                # widget.CPU(
                #     format = '{load_percent}%',
                #     update_interval = 5.0,
                #     padding = 2
                # ),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = ' ',
                    background = colors[0],
                    padding = 0
                ),
                widget.Net(
                    format = 'Down: {down} Up: {up}',
                    update_interval = 5,
                    foreground = colors[2],
                    padding = 3
                ),
                # widget.TextBox(
                #     font = 'Font Awesome 5 Free Solid',
                #     text = '',
                #     background = colors[0],
                #     padding = 2
                # ),
                # widget.TextBox("Tushar Mohod", name="default"),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = '',
                    background = colors[0],
                    padding = 3
                ),
                widget.Backlight(
                    backlight_name = 'intel_backlight',
                    format = '{percent:2.0%}',
                    foreground = colors[2],
                    step = 5,
                    padding = 3
                ),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = '',
                    background = colors[0],
                    padding = 3
                ),
                widget.PulseVolume(
                    fmt = '{}',
                    padding = 3,
                    foreground = colors[2]
                ),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = '',
                    background = colors[0],
                    padding = 3
                ),
                widget.Battery(
                    battery = 0,
                    charge_char = 'Chr',
                    discharge_char = 'Dis',
                    full_char = 'Full',
                    unknown_char = 'Unk',
                    update_interval = 5,
                    format = '{char} {percent:2.0%}',
                    foreground = colors[2],
                    padding = 3
                ),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = '',
                    background = colors[0],
                    padding = 3
                ),
                widget.Clock(format='%a, %b %d', foreground = colors[2]),
                widget.TextBox(
                    font = 'Font Awesome 5 Free Solid',
                    text = '',
                    background = colors[0],
                    padding = 3
                ),
                widget.Clock(format='%I:%M %p', foreground = colors[2]),
                widget.Sep(
                    linewidth = 0,
                    padding = 3,
                    background = colors[0]
                ),
                # widget.QuickExit(),
                widget.Systray(
                    background = colors[0],
                    padding = 1
                ),
                widget.Sep(
                    linewidth = 0,
                    padding = 6,
                    foreground = colors[2],
                    background = colors[0]
                ),
            ]
    return widgets_list

widgets_list = init_widgets_list()

def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    return widgets_screen1

def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    return widgets_screen2

widgets_screen1 = init_widgets_screen1()
widgets_screen2 = init_widgets_screen2()

# For multiple screen setup
def init_screens():
    return [Screen(top=bar.Bar(widgets=init_widgets_screen1(), size=22)), # screen 1
            Screen(top=bar.Bar(widgets=init_widgets_screen2(), size=22))] # screen 2
screens = init_screens()

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon

@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/scripts/autostart.sh'])

# @hook.subscribe.startup
# def start_always():
#     # Set the cursor to something sane in X
#     subprocess.Popen(['xsetroot', '-cursor_name', 'left_ptr'])

# @hook.subscribe.client_new
# def set_floating(window):
#     if (window.window.get_wm_transient_for()
#             or window.window.get_wm_type() in floating_types):
#         window.floating = True

# floating_types = ["notification", "toolbar", "splash", "dialog"]

follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass
])
auto_fullscreen = True
focus_on_window_activation = "smart"

wmname = "LG3D"
