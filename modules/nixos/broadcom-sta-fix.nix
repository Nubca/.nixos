self: super: {
  broadcom-sta = super.broadcom-sta.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace src/wl/sys/wl_linux.c \
        --replace '#include <asm/unaligned.h>' '#include <linux/unaligned.h>'
    '';
  });
}
