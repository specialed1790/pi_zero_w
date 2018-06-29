*** Note, currently outdated and not in sync with the latest Stratux code ***

An alternative method for installing Stratux on your board's Linux OS.

The script is currently in beta development.

Both 1090ES and 978UAT SDR dongles have been tested on an RPi2 and RPi3
(for both Raspbian Jessie and Jessie Lite an image resize is required),
and an Odroid-C2 running Ubuntu64-16.04lts-mate. All three boards worked
with both an Edimax EW-7811Un and an Odroid Module 0 (Ralink RT5370) Wifi
USB adapter, no extra configuration required. But virtually any natively
supported Wifi USB adapter should work. The network config defaults to
wlan0 and it is not re-configurable at this time.

Note, it's possible to bootstrap an install from one board to another
when the two boards share similar processors and/or hardware. E.g. it's
possible to use the setup script to install stratux on an RPi2 board then
use the SD card from the RPi2 with an RPi0.

Download Raspbian strech lite
<code>
<p>https://www.raspberrypi.org/downloads/raspbian/<p>
</code>
<p>
unzip the file 2018-04-18-raspbian-stretch-lite.zip to 
2018-04-18-raspbian-stretch-lite.img
<p>
Isert into sdcard reader then copy to disk. use lsblk to locate correct device see details here
<p>
https://www.raspberrypi.org/documentation/installation/installing-images/linux.md
<p>
On linux use lsblk to find the correct device sdcard interface
<code><p>
dd bs=4M if=2018-04-18-raspbian-stretch-lite.img of=/dev/sdX conv=fsync status=progress
</code>
when copy is complete add the following files
<code><p>
sudo touch /media/username/boot/ssh<p>
sudo nano /media/username/boot/wpa_supplicant.conf<p>
</code>
edit wpa_supplicant.conf with youre wifi config

country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="NETWORK-NAME"
    psk="NETWORK-PASSWORD"
}
<p>
go here for details 
<p>
login from term window
<p>
ssh-keygen -R raspberrypi.local
<p>
ssh pi@raspberrypi.local
the default username is pi. The password is "raspberry"
this is the default password. Change to something else with<p>
->passwd

run <p>
sudo raspi-config<p>
select 7 advance options<p>
select A1 <p>
Expand filesystem<p>
do and update and add git<p>




sudo apt-get update
sudo apt-get -y install git
sudo git clone https://github.com/specialed1790/pi_zero_w.git
cd pi_zero_w
sudo bash stratux-setup.sh
sudo shutdown -r now



Commands to run the setup script:

    [login via command line]

    # sudo su -

    [Raspberry Pi boards]

    # raspi-config
        select option 1 - expand filesystem
        reboot


    [Odroid-C4]

    # apt-get update
    # apt-get install -y git

    [All]

    # cd /root

    # git clone https://github.com/jpoirier/stratux-setup
    # cd stratux-setup

    # bash stratux-setup.sh
        - currently detected boards: RPi2, RPi3, RPi0, and Odroid-C2
        - note, the setup script performs a dist-upgrade, if it's the
        first time the setup may take a considerable amount of time

    # reboot


Q: How do I update stratux when a new version is released?

A: If the stratux-setup folder still exists, login in as root and
cd to the stratux-setup folder, run "git pull" then "bash stratux-setup"
and reboot, otherwsie follow the standard install instructions listed above.

Raspberry Pi 2/3 users also have the option of updating via the web ui.
From your device connect to the internet and go to github.com/cyoung/stratux/releases
and download the desired update *.sh file. Connect to the stratux network,
open the web ui in a browser (192.168.10.1) and go to the Settings page and
select "Click to select System Update file" under the Commands section and follow
the instructions to select the update file you downloaded from the internet.

Non Raspberry Pi users - if your processor is an arm7l you should be
able to use the web ui updater. Odroid-C4 users can update via the web ui
but keep in mind that the updater installs arm7l 32bit binaries where as the
stratux-setup builds arm8l 64 bit binaries.


Q: What version of stratux does the setup script download and install?

A: The setup script checks out and builds the latest release from the official
stratux git repository.

Note, you can check out and install any version of the stratux source code by
opening a command line prompt in /root/stratux, issuing a "git checkout some-rev"
command, where some-rev can be either a sha1 hash or tag, and running
"make all" then "make install" and reboot. To see what revisions are available for
checkout issue a "git branch" command.


Q: Why use a setup script to manually install stratux as opposed to using the official image?

A: For most, the official stratux image is what you should use.
With that said, the setup script does offer the ability to use stratux on
many other boards that run Linux with a fairly straightforward approach to
adding support for Linux boards beyond RPi2 and RPi3.


Q: How does the stratux-setup script it work?

A: The stratux-setup script downloads, builds, and installs source code from the
official stratux git repository and it sets up the necessary dhcp server using
the same isc-dhcp-server binary as on the stratux image.


Q: Does the stratux setup script differ from the installation provided by the official image?

A: No. The stratux-setup script makes no modifications and for all intents and purposes
the stratux-setup installation is identical to that of the official image.


Q: Are there any parts that don't work if I use an unsupported board, eg an Odroid-C2?

A: Yes. Those parts that connect via GPIO are unsupported at this time,
therefore, you're restricted to those USB devices you'd use with the official image,
e.g. SDR and/or GPS USB devices.


Q: How do I check that the stratux and wifi services are running if I run in to a problem?

A: Login as root and run the command "service --status-all" in a shell window and check
if the stratux, hostapd, and isc-dhcp-server services are shown to be running in the output.


Q: In general, what's involved in setting up stratux on a Linux board?

A: The setup can be broken down in to two basic parts, 1) the stratux software,
to include it's various components and services, and 2) the dhcp wifi network.

Wifi is the delivery method used to get various messages to clients, i.e. to an
EFB. The stratux board is setup as a dhcp server, similar to your home
wifi router, with the SSID (service set identifier) "stratux." Once a device
connects to the stratux network applications can start receiving the messages
being sent by stratux.

The stratux software is made up of several components that interface with various
external peripherals and middleware software. All the various pieces of software
must be compiled and installed.

See figure 1 below for a high level overview.


Requirements:

    - Linux compatible board
    - Linux OS
    - apt-get
    - ethernet connection
    - wifi
    - keyboard
    - a little command line fu


Add a hardware hook for your board:

    - create a bash file containing your hardware specific settings
      (eg see the rpi.sh file) then add a detection mechanism to the
      "Platform and hardware specific items" section in the
      stratux-setup.sh file (eg see the "Revision numbers").


WiFi config settings hook:

    - for the majority of systems the current wifi setup should
      work but for those cases where it doesn't it should be a
      simple matter to add a modified version of the wifi script
      and use the same detection mechanism to import the necessary
      file.


A 35,750 foot view of stratux:

    +--------------------------------+
    | Board (eg RPi2, Odroid-C2)     |
    | +----------------------------+ |
    | |         Linux              | |
    | +----------------------------+ |
    | ||   Stratux Middleware     || |
    | ||                          || |    +-------------+   \/
    | || +---+ Process 1090 data  || |<---+1090ES Dongle|----   (optional)
    | || |                        || |    +-------------+
    | || |                        || |    +-------------+   \/
    | || +---+ Process 978 data   || |<---+978UAT Dongle|----   (optional)
    | || |                        || |    +-------------+
    | || |                        || |              +---+   \/
    | || +---+ Process GPS info   || |<-------------+GPS|----   (optional)
    | || |                        || |              +---+
    | || |                        || |             +----+   \/
    | || +---+ Process AHRS info  || |<------------+AHRS|----   (optional)
    | || |                        || |             +----+
    | || Build outgoing message/s || |
    | || |                        || |           +------+   \/
    | || +---> Send messages ---> || |<----------> Wifi |----
    | ||                          || |           +------+
    | |----------------------------| |
    | +----------------------------+ |
    +--------------------------------+

               Figure 1
