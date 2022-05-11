{ stdenv, makeWrapper, gradle_6, jdk11 }:

let 
    pname = "sky-cache-exporter";
    version = "2021-12-16";

    src = builtins.fetchGit {
        url = "ssh://git@github.com/nerdsinspace/SkyCacheExporter.git";
        rev = "5b60860aa57b58e4cfdea24c524774ace76f987f";
    };

    jar = stdenv.mkDerivation {
        name = "${pname}-${version}-jar.jar";
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
        #outputHash = "sha256-XmDlaAm+mH++5d0zGp91rVTQpaTtDhfeqc5uY22QEVw=";
        # I think there's an impurity or unpinned dependency
        outputHash = "sha256-/ac7uxmOG76Ha+l/IPP9aJdRqDhW5FOx/0B+Y/HjlLU=";
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
