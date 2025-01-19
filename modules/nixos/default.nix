{ config, pkgs, lib, ... }:

{
  home.file.".config/vivaldi/themetweaks.css".text = ''

    .address-top .toolbar-mainbar:after {
      height: unset;
    }
    .address-bottom .toolbar-mainbar {
      box-shadow: unset;
    }

    .bookmark-bar {
      background-color: var(--colorBg);
    }
    .color-behind-tabs-off .bookmark-bar button {
      background-color: var(--colorBg);
    }

    .color-behind-tabs-on .bookmark-bar {
      background-color: var(--colorBg)
    }
    .color-behind-tabs-on .bookmark-bar button {
      background-color: var(--colorBg);
    }

    .bookmark-bar .bookmarkbarItem img {
    	filter: drop-shadow(0 0 1px white);
    }

    .bookmark-bar .bookmarkbarItem.folder svg {
	    color: white
    }

    .bookmark-bar .bookmarkbarItem.folder .title {
	    color: white
    }
  '';
}
