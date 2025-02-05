_final: prev: {
  linuxPackages = prev.linuxPackages.extend (_lpself: lpsuper: {
    nvidiaPackages = lpsuper.nvidiaPackages // {
      legacy_470 =
        let
          aurPatches = prev.fetchgit {
            url = "https://aur.archlinux.org/nvidia-470xx-utils.git";
            rev = "3ead0736b24d809c6b4390748feb11f1c3c1f342";
            hash = "sha256-XcPjyvKRLU5W88szWEqiWfJHFtm1IGr9jBzyt9qtdWQ=";
          };
          patchset = [
            "0001-Fix-conftest-to-ignore-implicit-function-declaration.patch"
            "0002-Fix-conftest-to-use-a-short-wchar_t.patch"
            "0003-Fix-conftest-to-use-nv_drm_gem_vmap-which-has-the-se.patch"
            "kernel-6.10.patch"
            "kernel-6.12.patch"
          ];
        in
          lpsuper.nvidiaPackages.generic {
            version = "470.256.02";
            sha256_64bit = "sha256-1kUYYt62lbsER/O3zWJo9z6BFowQ4sEFl/8/oBNJsd4=";
            sha256_aarch64 = "sha256-e+QvE+S3Fv3JRqC9ZyxTSiCu8gJdZXSz10gF/EN6DY0=";
            settingsSha256 = "sha256-kftQ4JB0iSlE8r/Ze/+UMnwLzn0nfQtqYXBj+t6Aguk=";
            persistencedSha256 = "sha256-iYoSib9VEdwjOPBP1+Hx5wCIMhW8q8cCHu9PULWfnyQ=";

            patches = map (patch: "${aurPatches}/${patch}") patchset;
            prePatch = "cd kernel";
            postPatch = "cd ..";
        };
    };
  });
}
