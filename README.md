# Mantl CICD Setup

This is a project to make it easy to add CICD capabilities onto a [Mantl.io](www.github.com/CiscoCloud/mantl) deployment.

Targeted goals are:

* Deploy a VCS Server to run on the Mantl cluster
  * Currently targeting GitLab as the initial option
* Deploy a CICD Build Server to run on the Mantl cluster
  * Currently targeting Drone as the initial option
* Deploy a container registry to run on the Manlt cluster
  * Need to select an option here
* Automate the integration between the VCS and Build Servers
* Deploy a sample application into the environment where
  * The code is stored in the VCS Server
  * A build job is configured to integrate and act on changes to the repo
  * Artifacts are stored in the container registry
  * A dev and prod instance of the application are deployed onto the Mantl cluster
