# dpa-docker
Dockerized SolarWinds Database Performance Analyzer

### Dockerfile
The dockerfile used to build and deploy Solarwinds DPA within a container. It downloads and verifies the signatures of the DPA archives given a version. Then it builds and runs through, accepts the EULA, and sets the target for the the default installation parameters. Finally, it copies over the startup script which will copy the default installation onto the mounted volume to ensure persistence is maintained.

### install.expect
This is the TCL expect script used to interact with the install bash script provided by Solarwinds. It requires user interactiong vis a vis traversing and accepting a license, asking for confirmations, and setting the installation directory. While this does seem to work fairly well, I do occasionally get some unexplained failures about 5% of the time usually due to slightly aggressive timeouts.

### solarwinds.pem
The official public key provided by Solarwinds which signs all 2023.2 or above:
https://documentation.solarwinds.com/en/success_center/dpa/content/install-dpa-on-linux.htm

### start.sh
The default entry point for the program which will clone the default installation to the target production directory if it doesn't exist, create the log file, start the DPA script, and monitor the log file perpetually.