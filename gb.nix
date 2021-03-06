{ src # flake input
, lib, makeWrapper, buildGoModule, fetchFromGitHub, lepton }:

buildGoModule {
  pname = "gb-backup";
  version = "unstable-2021-11-01";

  inherit src;

  vendorSha256 = "sha256-m+J0keS+RzfTqdm7jYKrNIm/Fy9fN7P4gig3bWoIqJI=";

  nativeBuildInputs = [ makeWrapper ];

  checkInputs = [ lepton ];

  postFixup = ''
    wrapProgram $out/bin/gb --prefix PATH : ${lib.makeBinPath [ lepton ]}
  '';

  meta = with lib; {
    description = "Gamer Backup, a super opinionated cloud backup system";
    homepage = "https://github.com/leijurv/gb";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ babbaj ];
    platforms = platforms.unix;
  };
}
