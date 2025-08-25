self: super: {
  osm-gps-map = super.osm-gps-map.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
      self.automake
      self.autoconf
      self.autoreconfHook
      self.gtk-doc
    ];
    preConfigure = ''
      autoreconf -vfi
      ${oldAttrs.preConfigure or ""}
    '';
  });
}
