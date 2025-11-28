{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Sabrent_9128071117F600059256";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "defaults" "noatime" ];
              };
            };
          };
        };
      };
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10JUCT-63CYNY0_WD-WXL1A56D5ND9";
        content = {
          type = "gpt";
          partitions = {
            raid = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "data";
              };
            };
          };
        };
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10JUCT-63CYNY0_WD-WX81EC59L6DM";
        content = {
          type = "gpt";
          partitions = {
            raid = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "data";
              };
            };
          };
        };
      };
    };
    mdadm = {
      data = {
        type = "mdadm";
        level = 1;
        metadata = "1.2";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/data";
          mountOptions = [
            "defaults"
            "noatime"
          ];
        };
      };
    };
  };
}
