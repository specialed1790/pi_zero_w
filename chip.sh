# Copyright (c) 2016 Joseph D Poirier
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "********* CHIP setup... **********"
echo "************************************"
echo "${WHITE}"


##############################################################
## Setup power management script
##############################################################
echo
echo "${YELLOW}setup power management service...${WHITE}"

chmod 755 ${SCRIPTDIR}/chip-power.sh
cp ${SCRIPTDIR}/chip-power.sh /etc/init.d/chip-power.sh
update-rc.d chip-power.sh defaults 100

echo "${GREEN}...done${WHITE}"
