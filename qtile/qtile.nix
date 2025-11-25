# /etc/nixos/qtile/qtile.nix
{ config, pkgs, lib, ... }:

let
  hostname = config.networking.hostName; # Get hostname from NixOS config

  # --- Define Settings Per Host ---

  # Default settings (for tNix)
  defaultSettings = {
    has_battery = true;
    layout_margin = 8;
    layout_border_width = 3;
    widget_font_size_default = 26;
    widget_padding_default = 4;
    widget_font_size_groupbox = 18;
    widget_margin_y_groupbox = 3;
    widget_margin_x_groupbox = 2;
    widget_padding_y_groupbox = 3;
    widget_padding_x_groupbox = 2;
    widget_borderwidth_groupbox = 4;
    widget_linewidth_sep = 3;
    widget_padding_sep = 6;
    widget_font_size_layout = 16;
    widget_font_size_windowname = 16;
    widget_font_size_clock = 18;
    widget_font_size_battery = 18;
    widget_font_size_systray = 18;
    bar_size = 26;
    # systray_screen_index = 0; # Systray on Screen 0 (first screen)
    # Wallpapers are declared and set to the below via each users xxhome.nix file.
    wallpaper_screen0 = "~/.config/qtile/0-Monitor.jpg"; # Example system path
    # wallpaper_screen1 = "~/.config/qtile/1-Main.jpg";    # Example system path
  };

  # Overrides for Desktop machines
  useDesktopOverrides = {
    has_battery = false;
    # Scaling, layout, systray position same as Default
  };

  # Overrides for mpNix (HiDPI Laptop)
  useHiDPIOverrides = {
    # has_battery = true;
    layout_margin = 15;
    layout_border_width = 8;
    widget_font_size_default = 46;
    widget_padding_default = 6;
    widget_font_size_groupbox = 40;
    widget_margin_y_groupbox = 3; # Keep margins/paddings reasonable even if font is huge
    widget_margin_x_groupbox = 2;
    widget_padding_y_groupbox = 3;
    widget_padding_x_groupbox = 2;
    widget_borderwidth_groupbox = 8;
    widget_linewidth_sep = 5;
    widget_padding_sep = 12;
    widget_font_size_layout = 32;
    widget_font_size_windowname = 36;
    widget_font_size_clock = 46;
    widget_font_size_battery = 46;
    widget_font_size_systray = 42;
    bar_size = 48;
    # systray_screen_index = 1; # Systray on Screen 1 (second screen)
  };

  # --- Determine Final Settings ---
  finalSettings = lib.recursiveUpdate defaultSettings (
    if hostname == "iNix" || hostname == "uMix" || hostname == "pNix" then useDesktopOverrides
    else if hostname == "mpNix" || hostname == "nNix" then useHiDPIOverrides
    else {} # Use defaults for tNix or any other hostname
  );

  # --- Generate Conditional Python Code Snippets ---

  # Battery Widget + Separator Code
  batteryWidgetCode = if finalSettings.has_battery then ''
    widget.Sep( # Separator before Battery
        linewidth=${toString finalSettings.widget_linewidth_sep},
        padding=${toString finalSettings.widget_padding_sep},
        foreground=colors[3],
        background=colors[1]
    ),
    widget.Battery(
        font="Noto Sans",
        foreground=colors[5],
        background=colors[1],
        charge_char='➚',
        discharge_char='➘',
        fontsize=${toString finalSettings.widget_font_size_battery},
        update_interval=20,
        format='{percent:2.0%} {char} {hour:d}:{min:02d}', # Added hour format
        low_percentage=0.2, # Example: Warn below 20%
        low_foreground="cd1f3f" # Example: Red warning color (color 6)
    ),
  '' else ""; # Empty string if no battery needed

  # --- Prepare Substitutions Map ---
  substitutions = (lib.mapAttrs (n: v: toString v) (
    lib.filterAttrs (n: v: !(lib.isList v) && !(lib.isAttrs v)) finalSettings
  )) // {
    # Add the generated Python code snippets
    battery_widget_python_code = batteryWidgetCode;
  };

  # --- Generate the Configuration File ---
  generatedConfigFile = pkgs.runCommand "qtile-config.py" { } ''
    cp ${pkgs.replaceVars ./config.py.template substitutions} $out
  '';

in
{
  # --- Integrate with NixOS Qtile Module ---
  # In base.nix 'services.xserver.windowManager.qtile.enable = true;' is declared.
  # This module provides the configuration *when* qtile is enabled.
  config = lib.mkIf config.services.xserver.windowManager.qtile.enable {

    # Set the generated config file path for the Qtile service
    services.xserver.windowManager.qtile.configFile = generatedConfigFile;

    # Define extra Python packages needed by Qtile or its widgets
    services.xserver.windowManager.qtile.extraPackages = pyPkgs: with pyPkgs; [
      psutil      # Required by Battery widget and others
      dbus-next   # Required by Systray, Notify, etc.
      # qtile-extras # Uncomment if you use widgets from qtile-extras
      # Add other Python dependencies for widgets if needed
    ];

    # Ensure necessary system packages are available (fonts, etc.)
    # This should ideally be handled in fonts.packages or environment.systemPackages elsewhere
    environment.systemPackages = with pkgs; [
      font-awesome # For GroupBox icons
      noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji # For general text/fallback
      # Add xsetroot if not already pulled in by xserver
      xorg.xsetroot
    ];
  };
}
