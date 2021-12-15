{ stdenv, makeWrapper, gradle_6, jdk11 }:

let 
    pname = "sky-cache-exporter";
    version = "2021-12-15";

    src = builtins.fetchGit {
        url = "ssh://git@github.com/nerdsinspace/SkyCacheExporter.git";
        rev = "ac7cc1d5d25f4ff01043258d06dd2d0aa931ba69";
    };

    jar = stdenv.mkDerivation {
        pname = "${pname}-${version}-jar.jar";
        inherit src version;

        nativeBuildInputs = [ gradle_6 ];

        buildPhase = ''
            export GRADLE_USER_HOME=$(mktemp -d)
            gradle build
        '';

        installPhase = ''
            cp build/libs/SkyCacheExporter-1.0-SNAPSHOT-standalone.jar $out
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "flat";
        outputHash = "sha256-DrXm/psQE0+jF02OkieE6YgkrZmoUQlqRbGZEqODYuU=";
    };  
    
in
stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
        mkdir -p $out/
        
        makeWrapper ${jdk11}/bin/java $out/bin/$pname \
            --add-flags '-jar ${jar}'
    '';
}
