# Device Configuration in NetOps Portal
 Ability to view Spectrum NCM captured configs in the NetOps Portal

## Getting Started
 These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### High Level Architecture
Logo: ![High Level Architecture](/arch.png "High Level Architecture")

### Prerequisites
* Spectrum system running on Linux
* Spectrum system has inotify tools installed (see Built With below)
* NCM successfully capturing configurations
* NCM configured to export configurations

### Installing
Note: These directions assume CentOS 7 or RHEL 7

Install NFS Utilities if not present.  Do this on the Spectrum system and the NetOps Portal system.
```
yum -y install nf-utils
```
Configure NFS to start at boot.  Start NFS services
```
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
```
Spectrum system: Export the directory that the Spectrum configurations are being saved to with NFS.
```
vi /etc/exports
```
Ensure you use the correct Spectrum export directory and the IP address of the NetOps Portal for your installation
```
/opt/ca/spectrum/NCM_Exports 10.74.130.68(rw,sync,no_root_squash,no_all_squash)
```
Spectrum system: Restart NFS
```
systemctl restart nfs-server
```
Spectrum system: Create directories
```
mkdir /opt/ca/spectrum/NCM_Exports/bin
mkdir /opt/ca/spectrum/NCM_Exports/format
mkdir /opt/ca/spectrum/NCM_Exports/backup
```

Spectrum system: Install inotify Tools.  Depending on the OS, you may have or my not have inotifywait installed or available via package.  Use your package manager to install, or build from source (see Built With below).
Man Page: [inotifywait] (https://linux.die.net/man/1/inotifywait)
Build Tutorial: [inotifywait] (http://jensd.be/248/linux/use-inotify-tools-on-centos-7-or-rhel-7-to-watch-files-and-directories-for-events)

NetOps Portal system: Mount NFS Volume from Spectrum system

Make the directories on the NetOps Portal system
```
mkdir -p /opt/CA/PerformanceCenter/PC/webapps/pc/apps/user/NCM/configs/
```
Edit the fstab file
```
vi /etc/fstab
```
Ensure you use the correct Spectrum IP address and path; the path should match your /etc/exports on the Spectrum system
```
10.74.130.67:/opt/ca/spectrum/NCM_Exports /opt/CA/PerformanceCenter/PC/webapps/pc/apps/user/NCM/configs/ nfs defaults 0 0
```
Copy the scripts from this distro to the appropriate directories on the Spectrum system
```
cp watch_it.sh /opt/ca/spectrum/NCM_Exports/bin
cp format_it.sh /opt/ca/spectrum/NCM_Exports/bin
cp append_html  /opt/ca/spectrum/NCM_Exports/format
cp prepend_html /opt/ca/spectrum/NCM_Exports/format
```
Spectrum system: Change scripts to execute permission
```
chmod u+x /opt/ca/spectrum/NCM_Exports/bin/*.sh
```
Spectrum system: Start the watcher script (note that nohup.out will be in the current directory you run the command from)
```
nohup /opt/ca/spectrum/NCM_Exports/bin/watch_it.sh &
```
Setup Browser View
Go to a router device in Performance Center
Click one of the cog wheels in the tabs, and select Add Tab.  Give it a name such as “Router Configuration”.
Select a single pane format for the view, and add the “Browser View” to that single pane.  Configure the browser view with a title “Router Configuration” and URL:
```
http://ip_address_of_your_netops_portal:8181/pc/apps/user/NCM/index.{ItemName}.html
```
When entering the URL, you can use the URL parameter pull down list to get the {ItemName} and click “Append To URL” in the appropriate part of the URL.

I used a height of 1000 lines for my monitor; adjust accordingly.

## Test
Anytime the global sync task runs, or a new configuration is pushed to a router and manually captured (or captured when a change trap comes in) a file will be created in the export directory.  It will be processed, formatted and moved.  Because we used the variables in the browser view, each browser view will look for a unique file name.
To test you can manually run the global sync task.  This will also (on first run) pre-populate all of the html and configurations for your routers.

## Built With
[inotifywait] (https://linux.die.net/man/1/inotifywait) - tool to leverage the kernel to monitor the directory for new files (and a ton of other stuff)

## Author
* **Brian Jackson** - *Initial Work* - [email me](mailto://brian.jackson@broadcom.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
