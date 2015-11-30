#!/bin/sh
#
# Scriptname: disk_spindown2.sh
#
# Description:
# Check for idle disks and spin them down.
# Some Harddrives not working to spindwon with hdparm -B oder -S commands.
# But hdparm -y direct work. So that a script for all Harddrives.
# We don't set the firmware in the Drives. We use Linux for that job now!
# Working normally for all hard disks.
#
# You get a /var/log/diskstate.log now.
# In any Terminal you can follow the log by this command (as root, or user in group adm): tail -f /var/log/diskstate.log
# 
# !! Caution: In /etc/hdparm.conf spindown_time  or / and APM do not use! The other you can use as usual in hdparm.conf.
#
#
# Requierd: sudo apt-get install hdparm
#
# Installation:
# Save it to /usr/local/bin/disk_spindown2.sh
# Set the Permissons:
# sudo chmod 744 /usr/local/bin/disk_spindown2.sh
#
# Startup at boot:
# we put a new line in /etc/rc.local
# /usr/local/bin/disk_spindown2.sh & >/dev/null
# exit 0
#
# Now you can reboot the pc, for activate or to activate a change.
# By handy as root: killall disk_spindown2.sh  then   /usr/local/bin/disk_spindown2.sh &
#
# http://linuxwiki.de/hdparm
#
# Western Digital Green Harddrives (mostly not suitable with hdparm -S or -B)
# ---------------------------------------------------------------------------
# Modern Western Digital "Green" Drives include the Intellipark feature that stops the disk when not in use.
# Unfortunately, the default timer setting is not perfect on linux/unix systems, including many NAS,
# and leads to a dramatic increase of the Load Cycle Count value (SMART attribute #193).
# Please deactivat it with http://idle3-tools.sourceforge.net/ (normally in the Distro)
#
# get the Info: idle3ctl -g /dev/sd(x)
# disabling :   idle3ctl -d /dev/sd(x)   (From this Moment the WD Green is more a WD Blue now)
# The idle3 timer seems to be a power on only setting. That means that the drive needs to be powered OFF and then ON to use the new setting.
# I turn off the Computer, plug the power off and push the start button, for a short while the fan go's on. All power it out. 
# Or turn off and unplug the power, for few minutes to take the effect.

## Variables

#Logging enable set to true  (/var/log/diskstate.log)
#do_log=false
do_log=true

# Where is your Ramdrive? 
# Check it out with  df -h or mount command.
# Possible Values Examples: /dev/shm , /run/shm 
ramdrive=/dev/shm

# Cyle time between checks, normally between 60 up to 300 Seconds. Protect the CPU/BUS Load.
time_cyle=60

# The Spindwon Time in Seconds for the harddisk drives, less then the time_cyle will only act on time_cyle.
# 300=5min, 600=10min, 900=15min, 1200=20min etc ..
time_disk_a=120
time_disk_b=120
time_disk_c=120
time_disk_d=120
time_disk_e=120
time_disk_f=120
time_disk_g=120
time_disk_h=120
time_disk_i=120
time_disk_j=120
time_disk_k=120


# Wich harddisk drives are handled to spindown
# No changes required, but if you need/like you can change.
#diskvolumes_spindown="a b c d e f g h i j k"
diskvolumes_spindown="b c d e f g h i j k"

# Wich harddisk drives are handled to send the apm = 255 command. (Disble AutoPowerManager in Firmware of the given Drives) 
# No changes required, but if you need/like you can change.
#diskvolumes_apm_off="a b c d e f g h i j k"
diskvolumes_apm_off="b c d e f g h i j k"

## Script
if [ $do_log = true ];then
 # If you like on every boot a new start of the /var/log/diskstate.log, activat this line.
 #rm /var/log/diskstate.log >/dev/null 2>&1
 rm /var/log/diskstate.log >/dev/null 2>&1

 # Create Log File
 test -f /var/log/diskstate.log || `touch /var/log/diskstate.log; chown root.adm /var/log/diskstate.log`
else
 rm /var/log/diskstate.log >/dev/null 2>&1
fi

# Drives exist?
for disk in $diskvolumes_spindown; do hdparm -B /dev/sd$disk >/dev/null 2>&1; test $? = 0 && drives_spindown=$(printf "$drives_spindown"; printf $disk" "); done

#apm off
if [ $do_log = true ];then
 echo `date` ": $0 started" >> /var/log/diskstate.log
 echo `date` ": APM OFF Routine run once" >> /var/log/diskstate.log
 for disk in $diskvolumes_apm_off; do hdparm -B /dev/sd$disk >/dev/null 2>&1; test $? = 0 && hdparm -B 255 /dev/sd$disk >> /var/log/diskstate.log; done
else
 for disk in $diskvolumes_apm_off; do hdparm -B /dev/sd$disk >/dev/null 2>&1; test $? = 0 && hdparm -B 255 /dev/sd$disk; done 
fi

# Set ones on start time variable time_noise_$(disk), like noise from harddrive
for disk in $diskvolumes_spindown; do eval time_noise_${disk}=$(date +"%s"); done

# Build onece the tempfiles 
if [ ! -f $ramdrive/diskstate1 ]; then touch $ramdrive/diskstate1;fi 
if [ ! -f $ramdrive/diskstate2 ]; then touch $ramdrive/diskstate2;fi

# Here we go... 
while [ true ] ; do
# Wipe big logfiles out
 if [ $do_log = true ];then
  find /var/log/diskstate.log -type f -size +5M -exec rm "{}" \; >/dev/null 2>&1
  test -f /var/log/diskstate.log || `touch /var/log/diskstate.log; chown root.adm /var/log/diskstate.log`
 fi

# cycle it to test for activity 
 mv $ramdrive/diskstate1 $ramdrive/diskstate2 
 cat /proc/diskstats > $ramdrive/diskstate1

# Loop through all array disks and spin down idle disks. 
  for disk in $drives_spindown; do
    if [ "$(diff $ramdrive/diskstate1 $ramdrive/diskstate2 | grep sd$disk )" = "" ]; then
    time_silent=$(date +"%s")
    time_noise=$(eval echo \${time_noise_${disk}})
    time_disk=$(eval echo \${time_disk_${disk}})
    time_idle=$(($time_silent - $time_noise))
     if [ $time_idle -ge $time_disk ]; then hdparm -y /dev/sd$disk >/dev/null 2>&1; fi
   else
    time_idle=non
    eval time_noise_${disk}=$(date +"%s")
   fi
  if [ $do_log = true ];then
   echo `date` ": /dev/sd$disk Idletime: $time_idle sec," `hdparm -C /dev/sd$disk | tail -1` >> /var/log/diskstate.log
  fi
  done 

# Cycle Wait
 sleep $time_cyle
done
exit 0
