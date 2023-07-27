{ config, pkgs, lib, ... }: {
  programs.plasma = {
    enable = true;
    shortcuts = { };
    files = {
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments.1.Wallpaper.org.kde.image.General"."Image" = "${./wallpaper.png}";
      "plasma-org.kde.plasma.desktop-appletsrc"."Containments.1.Wallpaper.org.kde.image.General".configGroupNesting = [ "Containments" "1" "Wallpaper" "org.kde.image" "General" ];
    };
  };
  # home.activation.reload-plasma = lib.hm.dag.entryAfter [ "configure-plasma" ] ''
  #   ${pkgs.libsForQt5.kdbusaddons}/bin/kquitapp5 plasmashell || true
  #   ${pkgs.libsForQt5.kde-cli-tools}/bin/kstart5 ${pkgs.libsForQt5.plasma-workspace}/bin/plasmashell
  # '';
}
