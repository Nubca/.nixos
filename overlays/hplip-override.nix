self: super: {
  hplip = super.hplip.overrideAttrs (oldAttrs: {
    src = super.fetchurl {
      url = "https://developers.hp.com/sites/default/files/hplip-3.24.4-plugin.run";
      sha256 = "da771a39f8506785004a80a1b3c51db9fde968fe707a51a65a35e86ebee382da"; # Replace with the correct hash
      name = "hplip-3.24.4-plugin.run";
      executable = true;
      postFetch = ''
        chmod +x $out
      '';
    };
  });
}
