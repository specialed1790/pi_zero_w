#!/bin/bash
#
# Setting VBUS current limit to "no limit" while keeping VHOLD at 4.8V
#

echo "Unlimited USB input current"
i2cset -y -f 0 0x34 0x30 0x63
