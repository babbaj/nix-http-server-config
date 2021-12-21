let
    me = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCwZnp/BQPN51mLsMyOdGoZ9fEWRsqc/2xo2ZlktHTwiLVUk4R9xeCVUMWUxeTMfYg/DBRjL7TU7o3ItRJwgR6x1bXQHv2czCBDPzohE53AUd+4RdEFRA18/CzRyDRH8nU0NDNFOIWbGsqA+0kQJe7IiftLSwyLcSaL5uXHsDEOj4yBQXVfSOMuP4JqlBpiWDko39LM/+EtKBAaDHEzLqMDGljGb+9YhyxpZAoRMXM1gxayh0l1k924prqB9WXxDQTg3azf3Is3v0fSp2Lk9DygAd9RhVzs1tmv3nmQ5xgiPJXWJPNUwnAapamGCeimzC3GXcWGo7g4x1iBPAzzpWJM1EJt3SyBCAPb8Jlj7YahtAXAzl9oekAWG1Vdx2bTMPWJUnll2UqD8ss6UQcR77w2111IEtI+j+SQskE72DAR8Ai5AUs4kzS6OJXfmJx0nljKJFzZqDs9U2muimF4NhRInkj4KkOqxGj91H6E9KNqVCl2EBZfgO3G6CKCmgcR2fh0/MBI0C/sUwWdvCjWTN1s36wLVs6+gsc5npLkrfhA7mGRyY0PdMleXG78s728HQJjPJg6sG6UL4OW0glGlQAy2rInBfnaCZSH6RulfPEXCY/Q99dwlOtuaFpWxOOj4Jwt/Ua9lQX5+qLIagM9DhIpYPZ/ZIYmdR5CKgmI80iDLQ== babbaj45@gmail.com";
    ovh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILE5DkOljQGiWxqO+xXRYoRPJkX22PzZlOAlPv8L9iUp root@vps-6a721a7c";
    hetzner = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM67+Jb7ZHbPo/1oB+zsBxIMaoG6lNwCgjI/RoE/seaz root@nixos";
    servers = [ ovh hetzner ];
in
{
    "httpAuth.age".publicKeys = [ me ] ++ servers;
    "wgKey.age".publicKeys = [ me ] ++ servers;
    "dnsToken.age".publicKeys = [ me ] ++ servers;
    "piaLoginEnv.age".publicKeys = [ me ] ++ servers;
    "nitwitIp.age".publicKeys = [ me ] ++ servers;
    "skyAuth.age".publicKeys = [ me ] ++ servers;
}
