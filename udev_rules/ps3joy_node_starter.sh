#!/bin/bash

# this file is listed in /etc/rc.local to be executed on boot as user root


if [ "$(whoami)" != "root" ]; then
        echo "Run me as super user!"
        exit 1
fi

echo "Note that we run as root with user config files so some warning outputs are to be expected."

# we source this because of ROS_IP etc:

# but as ~-relative paths from that won't work as we are root,
# so we make sure we have ros sourced:
source /opt/ros/indigo/setup.bash

# the above line would suffice if we'd use the joystick_drivers from
# source, but as we have modified them from source we need the catkin_ws

while true; do #after roscore shutdown try again
echo "waiting for roscore being started.."
while ! rostopic list > /dev/null; do
	sleep 1
done
echo "roscore ready"


echo "Checking whether any ps3joy(_node) is already running.."
# pgrep: 0 on match, 1 on no match
# grep: 0 on match, 1 on no match
if pgrep ps3joy.py > /dev/null || 
   pgrep ps3joy_node.py > /dev/null ||
   # this test is needed because python scripts are executed under the
   # generic process name 'python' so we have to test for ps3joy as a 
   # ros node.
   rosnode list | grep "/ps3joy" ; then
	echo "Error!? ps3joy(_node) is already running! Quitting starter"
	#exit 1
else
	echo "Starting ps3joy_node..."
	/opt/ros/indigo/lib/ps3joy/ps3joy_node.py --inactivity-timeout=300  > /var/log/rc_local-ps3joy_node.log 2>&1  &

	#exit 0
fi
sleep 5
done
