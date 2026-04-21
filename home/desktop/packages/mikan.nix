{ lib, pkgs, src }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "mikan";
  version = "latest";

  inherit src;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    glib
    gtk3
    libepoxy
    at-spi2-atk
    cairo
    pango
    gdk-pixbuf
    libx11
    libxcursor
    libxext
    libxrandr
    libxi
  ];

  dontUnpack = true;

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "io.nichijou.flutter.mikan";
      desktopName = "Mikan";
      comment = "Mikan Project";
      exec = "mikan %U";
      terminal = false;
      icon = "mikan";
      startupNotify = true;
      startupWMClass = "mikan";
      categories = [ "Network" "AudioVideo" ];
      type = "Application";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/mikan $out/bin
    cp -r ${src}/. $out/opt/mikan/
    chmod +x $out/opt/mikan/mikan

    install -Dm444 \
      $out/opt/mikan/data/flutter_assets/assets/mikan.png \
      $out/share/icons/hicolor/512x512/apps/mikan.png

    runHook postInstall
  '';

  preFixup = ''
    addAutoPatchelfSearchPath $out/opt/mikan/lib
  '';

  postFixup = ''
    makeWrapper $out/opt/mikan/mikan $out/bin/mikan \
      --chdir $out/opt/mikan \
      --prefix LD_LIBRARY_PATH : $out/opt/mikan/lib
  '';

  meta = {
    description = "Mikan Project desktop client";
    homepage = "https://github.com/iota9star/mikan_flutter";
    license = lib.licenses.asl20;
    mainProgram = "mikan";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
