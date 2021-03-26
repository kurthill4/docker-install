# docker-install
## Installs docker and sets up local regisistry

Automates the installation of docker.  Also updates Git to the 
latest version (installs the Git repository) and installs some
additional packages (cifs) to enable the local registry to use
a network share for the volume that the local registry uses.

Currently, this script also alters fstab to add a share to the
mnt/docker-registry folder, and the docker registry will mount
that folder as the registry volume with the config file.
