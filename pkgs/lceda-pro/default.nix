{
    stdenv,
    fetchzip,
    lib,
    makeDesktopItem,
    makeWrapper,
    copyDesktopItems,
    xdg-utils,
    electron,
}: let
    programName = "lceda-pro";
    programVersion = "2.2.44.12";
in stdenv.mkDerivation {
    pname = programName;
    version = programVersion;
    src = fetchzip {
        url = "https://image.lceda.cn/files/lceda-pro-linux-x64-${programVersion}.zip";
        hash = ""; # TODO
        stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $TEMPDIR/${programName}
        cp -rf ${programName} $out/${programName}
        mv $out/${programName}/resources/app/assets/db/lceda-std.elib $TEMPDIR/${programName}/db.elib

        makeWrapper ${electron}/bin/electron $out/bin/${programName} \
            --add-flags $out/${programName}/resources/app/ \
            --add-flags "--gtk4 --enable-wayland-ime" \
            --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ stdenv.cc.cc ]}" \
            --set PATH "${lib.makeBinPath [ xdg-utils ]}"

        mkdir -p $out/share/icons/hicolor/512x512/apps
        install -Dm444 $out/${programName}/icon/icon_512x512.png $out/share/icons/lceda.png
        install -Dm444 $out/${programName}/icon/icon_512x512.png $out/share/icons/hicolor/512x512/apps/lceda.png

        mkdir -p $out/share/applications

        runHook postInstall
    '';

    preFixup = ''
        patchelf \
            --set-rpath "$out/${programName}" \
            $out/${programName}/${programName}
    '';

    meta = with lib; {
        homepage = "https://lceda.cn/";
        description = "Highly efficient domestic PCB design tools, permanently free";
        license = licenses.unfree;
        platforms = platforms.linux;
    };
}

