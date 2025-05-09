{ config, lib, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://bitwarden.example.com"; # Use your real domain
      SIGNUPS_ALLOWED = false; # Only allow admin-invited users
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      # Email settings for invites, password resets, etc.
      SMTP_HOST = "127.0.0.1";
      SMTP_PORT = 25;
      SMTP_SSL = false;
      SMTP_FROM = "[email protected]";
      SMTP_FROM_NAME = "Bitwarden Server";
      # Yubikey integration (see below)
      YUBICO_CLIENT_ID = "your_yubico_client_id";
      YUBICO_SECRET_KEY = "your_yubico_secret_key";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "[email protected]";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    virtualHosts."bitwarden.example.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
      };
    };
  };
}  
