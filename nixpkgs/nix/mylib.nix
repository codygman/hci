{pkgs}:
{
  loadPrivatePersonalOrWorkEnv =
    let

      myEnv = builtins.getEnv "MYENV";
        lib = pkgs.lib;
    in
      if myEnv != ""
      then if myEnv == "personal" then
        lib.info "loading PERSONAL home manager environment"
          [ ~/Sync/nix-home-manager-config/personal-private.nix ]
           else
             if myEnv == "work" then
               lib.info "loading WORK home manager environment"
                 [ ~/Sync/nix-home-manager-config/work-private.nix ]
             else
               lib.warn "MYENV is not one of 'personal' or 'work', ONLY core home environment will be available!" []
      else
        lib.warn "MYENV not specified, ONLY core home environment will be available!" [];
}
