{ config, pkgs, ... }: 

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  age.secrets.httpAuth = {
    file = ./secrets/httpAuth.age;
    path = "/var/lib/traefik/auth.txt";
    owner = "traefik";
    group = "traefik";
  };
  
  services.traefik = 
  let
    port = p: { loadBalancer = { servers = [{ url = "http://127.0.0.1:${toString p}/"; }]; }; };
  in {
    enable = true;
    staticConfigOptions = {
      #log.level = "DEBUG";
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "web-secure";
            scheme = "https";
          };
        };

        web-secure = {
          address = ":443";
          http.tls.certResolver = "le";
        };
      };
      certificatesResolvers.le.acme = {
        email = "babbaj45@gmail.com";
        keyType = "RSA4096";
        storage = "/var/lib/traefik/acme.json";
        #caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"; # debugging
        httpChallenge.entryPoint = "web";
      };
    };

    dynamicConfigOptions = {
      # this along with sts-headers middleware is enough for A+ ssl report
      tls.options.default = {
        minVersion = "VersionTLS12";
        sniStrict = true;
        cipherSuites = [
          "TLS_AES_256_GCM_SHA384"
          "TLS_CHACHA20_POLY1305_SHA256"
          "TLS_AES_128_GCM_SHA256"
          #"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
          #"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
          "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
          #"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"  
        ];
      };

      http = {
        middlewares.no-kittens-allowed.basicAuth.usersFile = config.age.secrets.httpAuth.path;
        middlewares.sts-headers.headers = {
          stsincludesubdomains = true;
          stspreload = true;
          stsseconds = 315360000;
          forcestsheader = true;
        };
        # this just returns the default page of the public file server
        middlewares.cringe-404.errors = {
          status = [ "404" ];
          service = "simpleHttpPublic";
          query = "/";
        };

        routers.gbRouter = {
          #rule = "Host(`gb.medium.faith`)";
          rule = "ClientIP(`192.168.70.0/24`)"; # wireguard only
          middlewares = [ "sts-headers" "no-kittens-allowed" ];
          tls.certResolver = "le";
          service = "gb";
        };
        services.gb = port 7893;

        routers.publicRouter = {
          rule = "Host(`memes.medium.faith`)";  
          middlewares = [ "sts-headers" "cringe-404" ];
          tls.certResolver = "le";
          service = "simpleHttpPublic";
        };
        services.simpleHttpPublic = port 5021;
      };
    };
  };
}
