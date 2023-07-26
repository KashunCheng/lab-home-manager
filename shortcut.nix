let
  defaultShortcut = {
    "vscode-[[:digit:]][.][[:digit:]]+[.][[:digit:]]+" = "code.desktop";
    "firefox-[[:digit:]]+[.][[:digit:]]+[.][[:digit:]]+" = "firefox.desktop";
  };
in
{ lib, homeManagerConfiguration, shortcut ? defaultShortcut, ... }: {
  home.file =
    let
      installedPackages = map (v: { name = v.name; outPath = v.outPath; }) homeManagerConfiguration.config.home.packages;
      findInstalledPackageDerivation = regex: lib.lists.findFirst (s: builtins.isList s.match) null (map (v: { match = builtins.match regex v.name; derivationOutPath = v.outPath; }) installedPackages);
      generateShortcut = filename: drv: {
        "Desktop/${filename}" = {
          enable = true;
          executable = true;
          onChange = "";
          force = false;
          target = "Desktop/${filename}";
          text = null;
          recursive = false;
          source = /. + builtins.unsafeDiscardStringContext "${drv}/share/applications/${filename}";
        };
      };
      mergeFiles = listOfFile: builtins.foldl' lib.trivial.mergeAttrs { } listOfFile;
      files = lib.attrsets.mapAttrsToList
        (regex: filename:
          let
            installedPackage = findInstalledPackageDerivation regex;
          in
          if builtins.isNull installedPackage then { } else generateShortcut filename installedPackage.derivationOutPath)
        shortcut;
    in
    mergeFiles files;
}
