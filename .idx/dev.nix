# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  channel = "stable-23.11"; # "stable-23.11" or "unstable"
  # Use https://search.nixos.org/packages to  find packages
  packages = [
    pkgs.php
    pkgs.unzip
    pkgs.docker-compose
    pkgs.mariadb
  ];
  # Sets environment variables in the workspace
  env = {
  };
  # Enable rootless docker
  services.docker.enable = true;
  # search for the extension on https://open-vsx.org/ and use "publisher.id"
  idx.extensions = [
    # "vscodevim.vim"
  ];
  # set up moodle when workspace is created
  idx.workspace.onCreate = {
    set-up-project = "chmod +x .idx/setup.sh && .idx/setup.sh && echo https://9000-$WEB_HOST";
  };

  idx.workspace.onStart = {
    start-mariadb = "docker start idx-db-1";
  };
  # preview configuration, identical to monospace.json
  idx.previews = {
    enable = true;
    previews = [
      # {
      #   command = ["/usr/bin/php" "-S" "0.0.0.0:$PORT"];
      #   cwd = "www";
      #   manager = "web";
      #   id = "web";
      # }
      {
        # command = ["/usr/bin/docker" "run" "-p" "$PORT:80" "-v" "/home/user/project_idx_wordpress/www:/var/www/html" "--network" "idx_default" "idx-wordpress-php-apache:latest"];
        "command" =  [
        "/bin/bash" "-c"
        "if ! /usr/bin/docker ps | grep -q mariadb; then /usr/bin/docker start idx-db-1; fi; /usr/bin/docker run -p 9002:80 -v /home/user/project_idx_wordpress/www:/var/www/html --network idx_default idx-wordpress-php-apache:latest"
        ];
        cwd = ".";
        manager = "web";
        id = "web";
      }
    ];
  };
}
