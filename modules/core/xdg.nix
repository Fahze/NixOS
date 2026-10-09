{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.loupe ];

  # Lists below are the exact MimeType entries declared by each app's own
  # .desktop file (or, for Loupe, its data/meson.build) in the pinned
  # nixpkgs, read directly from the built packages rather than guessed.
  home-manager.sharedModules = [
    (_: {
      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          let
            loupe = "org.gnome.Loupe.desktop";
            mpv = "mpv.desktop";
            fileRoller = "org.gnome.FileRoller.desktop";
            code = "code.desktop";
            thunar = "thunar.desktop";

            imageMimeTypes = [
              "image/apng"
              "image/bmp"
              "image/gif"
              "image/jp2"
              "image/jpeg"
              "image/png"
              "image/qoi"
              "image/tiff"
              "image/vnd.microsoft.icon"
              "image/webp"
              "image/x-dds"
              "image/x-exr"
              "image/x-portable-anymap"
              "image/x-portable-bitmap"
              "image/x-portable-graymap"
              "image/x-portable-pixmap"
              "image/x-qoi"
              "image/x-tga"
              "image/x-win-bitmap"
              "image/x-xbitmap"
              "image/x-xpixmap"
              "image/svg+xml"
              "image/svg+xml-compressed"
              "image/avif"
              "image/heic"
              "image/jxl"
            ];

            videoAudioMimeTypes = [
              "application/ogg"
              "application/x-ogg"
              "application/mxf"
              "application/sdp"
              "application/smil"
              "application/x-smil"
              "application/streamingmedia"
              "application/x-streamingmedia"
              "application/vnd.rn-realmedia"
              "application/vnd.rn-realmedia-vbr"
              "audio/aac"
              "audio/x-aac"
              "audio/vnd.dolby.heaac.1"
              "audio/vnd.dolby.heaac.2"
              "audio/aiff"
              "audio/x-aiff"
              "audio/m4a"
              "audio/x-m4a"
              "application/x-extension-m4a"
              "audio/mp1"
              "audio/x-mp1"
              "audio/mp2"
              "audio/x-mp2"
              "audio/mp3"
              "audio/x-mp3"
              "audio/mpeg"
              "audio/mpeg2"
              "audio/mpeg3"
              "audio/mpegurl"
              "audio/x-mpegurl"
              "audio/mpg"
              "audio/x-mpg"
              "audio/rn-mpeg"
              "audio/musepack"
              "audio/x-musepack"
              "audio/ogg"
              "audio/scpls"
              "audio/x-scpls"
              "audio/vnd.rn-realaudio"
              "audio/wav"
              "audio/x-pn-wav"
              "audio/x-pn-windows-pcm"
              "audio/x-realaudio"
              "audio/x-pn-realaudio"
              "audio/x-ms-wma"
              "audio/x-pls"
              "audio/x-wav"
              "video/mpeg"
              "video/x-mpeg2"
              "video/x-mpeg3"
              "video/mp4v-es"
              "video/x-m4v"
              "video/mp4"
              "application/x-extension-mp4"
              "video/divx"
              "video/vnd.divx"
              "video/msvideo"
              "video/x-msvideo"
              "video/ogg"
              "video/quicktime"
              "video/vnd.rn-realvideo"
              "video/x-ms-afs"
              "video/x-ms-asf"
              "audio/x-ms-asf"
              "application/vnd.ms-asf"
              "video/x-ms-wmv"
              "video/x-ms-wmx"
              "video/x-ms-wvxvideo"
              "video/x-avi"
              "video/avi"
              "video/x-flic"
              "video/fli"
              "video/x-flc"
              "video/flv"
              "video/x-flv"
              "video/x-theora"
              "video/x-theora+ogg"
              "video/x-matroska"
              "video/mkv"
              "audio/x-matroska"
              "application/x-matroska"
              "video/webm"
              "audio/webm"
              "audio/vorbis"
              "audio/x-vorbis"
              "audio/x-vorbis+ogg"
              "video/x-ogm"
              "video/x-ogm+ogg"
              "application/x-ogm"
              "application/x-ogm-audio"
              "application/x-ogm-video"
              "application/x-shorten"
              "audio/x-shorten"
              "audio/x-ape"
              "audio/x-wavpack"
              "audio/x-tta"
              "audio/AMR"
              "audio/ac3"
              "audio/eac3"
              "audio/amr-wb"
              "video/mp2t"
              "audio/flac"
              "audio/mp4"
              "application/x-mpegurl"
              "video/vnd.mpegurl"
              "application/vnd.apple.mpegurl"
              "audio/x-pn-au"
              "video/3gp"
              "video/3gpp"
              "video/3gpp2"
              "audio/3gpp"
              "audio/3gpp2"
              "video/dv"
              "audio/dv"
              "audio/opus"
              "audio/vnd.dts"
              "audio/vnd.dts.hd"
              "audio/x-adpcm"
              "application/x-cue"
              "audio/m3u"
              "audio/vnd.wave"
              "video/vnd.avi"
            ];

            archiveMimeTypes = [
              "application/bzip2"
              "application/gzip"
              "application/vnd.android.package-archive"
              "application/vnd.ms-cab-compressed"
              "application/vnd.debian.binary-package"
              "application/vnd.rar"
              "application/x-7z-compressed"
              "application/x-7z-compressed-tar"
              "application/x-ace"
              "application/x-alz"
              "application/x-apple-diskimage"
              "application/x-ar"
              "application/x-archive"
              "application/x-arj"
              "application/x-brotli"
              "application/x-bzip-brotli-tar"
              "application/x-bzip"
              "application/x-bzip-compressed-tar"
              "application/x-bzip1"
              "application/x-bzip1-compressed-tar"
              "application/x-bzip3"
              "application/x-bzip3-compressed-tar"
              "application/x-cabinet"
              "application/x-cd-image"
              "application/x-compress"
              "application/x-compressed-tar"
              "application/x-cpio"
              "application/x-chrome-extension"
              "application/x-deb"
              "application/x-ear"
              "application/x-ms-dos-executable"
              "application/x-gtar"
              "application/x-gzip"
              "application/x-gzpostscript"
              "application/x-java-archive"
              "application/x-lha"
              "application/x-lhz"
              "application/x-lrzip"
              "application/x-lrzip-compressed-tar"
              "application/x-lz4"
              "application/x-lzip"
              "application/x-lzip-compressed-tar"
              "application/x-lzma"
              "application/x-lzma-compressed-tar"
              "application/x-lzop"
              "application/x-lz4-compressed-tar"
              "application/x-ms-wim"
              "application/x-rar"
              "application/x-rar-compressed"
              "application/x-rpm"
              "application/x-source-rpm"
              "application/x-rzip"
              "application/x-rzip-compressed-tar"
              "application/x-tar"
              "application/x-tarz"
              "application/x-tzo"
              "application/x-stuffit"
              "application/x-war"
              "application/x-xar"
              "application/x-xz"
              "application/x-xz-compressed-tar"
              "application/x-zip"
              "application/x-zip-compressed"
              "application/x-zstd-compressed-tar"
              "application/x-zoo"
              "application/zip"
              "application/zstd"
            ];
          in
          (builtins.listToAttrs (
            map (m: {
              name = m;
              value = loupe;
            }) imageMimeTypes
          ))
          // (builtins.listToAttrs (
            map (m: {
              name = m;
              value = mpv;
            }) videoAudioMimeTypes
          ))
          // (builtins.listToAttrs (
            map (m: {
              name = m;
              value = fileRoller;
            }) archiveMimeTypes
          ))
          // {
            "text/plain" = code;
            "inode/directory" = thunar;
          };
      };
    })
  ];
}
