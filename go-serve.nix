{ stdenv, go }:

stdenv.mkDerivation {
  pname = "go-serve";
  version = "LOL";

  src = ./serve.go;

  sourceRoot = ".";

  unpackCmd = ''
    cp $src ./serve.go
  '';

  nativeBuildInputs = [ go ];

  buildPhase = ''
    export HOME=$TMP/home
    go build -trimpath ./serve.go
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp serve $out/bin
  '';
}
