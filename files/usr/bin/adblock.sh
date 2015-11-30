#!/bin/sh
rm -f /tmp/block.hosts

wget -qO- "http://www.mvps.org/winhelp2002/hosts.txt" | grep "^127.0.0.1" > /tmp/block.build.list
wget -qO- "http://www.malwaredomainlist.com/hostslist/hosts.txt" | grep "^127.0.0.1" >> /tmp/block.build.list
wget -qO- "http://hosts-file.net/.\ad_servers.txt" | grep "^127.0.0.1" >> /tmp/block.build.list
wget -qO- "http://adaway.org/hosts.txt" | grep "^127.0.0.1" >> /tmp/block.build.list
wget -qO- "http://pgl.yoyo.org/as/serverlist.php?showintro=0;hostformat=hosts" | grep "^127.0.0.1" >> /tmp/block.build.list

awk '{$1=$1}{gsub(/\r/,"")}{print }' /tmp/block.build.list|sort|uniq > /tmp/block.build.before
rm -f /tmp/block.build.list

grep -vf /etc/white.list /tmp/block.build.before > /tmp/block.hosts
rm -f /tmp/block.build.before

/etc/init.d/dnsmasq restart

exit 0
