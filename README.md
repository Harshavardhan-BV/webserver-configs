# beevee.ga-configs

This repository is to serve as a documentation/tutorial/blog of how I set up a self-hosted home server. This repo will also contain docker-compose files and some config files. 

## DISCLAIMER: 
- A basic understanding of Linux is assumed by this README. Don't just copy-paste the commands, read and understand them first.
- This is my learning experience and I may have made some mistakes, so feel free to open an issue on Github or contact me if you find any. 
- I'm not responsible for any loss that may happen from following my guide. Please refer to other guides and documentation (preferably 1st party) as well to be sure. 
- I've given away information for educational purposes only. Please don't run any attacks on my server using this information. Thanks.
---

## Device
### Hardware
Item | Cost | Needs Replacement?
---|---|---
Raspberry Pi 4 Model B 8GB RAM | ₹ 6,799.00 | New
Raspberry Pi 15.3W Type-C Power Supply | ₹ 708.00 | New
Samsung EVO Plus 64GB microSDXC | ₹699.00 | New
40mm brass canister | ₹0.00 | Yes
Seagate 2TB Backup Plus Slim | ₹5,099.00 | Yes

[RaspberryPi](https://www.raspberrypi.org/) is a very small and cheap single-board computer that has pretty good performance for a low power device. I could've used some old laptop for this, but it would have loud fans, produce a lot of heat and would be difficult to hide. 

This RPi is enough for me as I don't expect more than 10 instances to be connected at a single time. I've gone went with 8GB of RAM since I'm running quite a few heavy services. If you plan to use it for production work, a dedicated server or a cluster of Pi's with load balancing might be better, depending on your needs. Additionally, RPi uses ARM architecture so some applications may not be supported. The requirement of heatsinks or fans is dependent on the climate of your location and your workloads.

The Seagate hard disk is currently only for testing purposes as a bulk storage device. It had stopped working previously and currently has bad sectors for almost 1TB. Only a 1TB space in the middle had no bad sectors and is used currently. It needs replacement as soon as possible.

### Software
#### [Ubuntu Server 20.04 LTS](https://ubuntu.com/download/raspberry-pi)
The official Raspberry Pi OS only has a 32-bit stable release. ARM32 would have lower performance (on RPi4) and ARM64 is supported by more applications, so, I  wanted a 64 bit OS. I personally prefer Debian more as a server OS, however, Ubuntu is also not a bad OS. It is also officially supported by RPi. Although, I've uninstalled snaps by following this [guide](https://techwiser.com/remove-snap-ubuntu/) xD.

Installing the OS is different from regular linux, where the filesystem is directly flashed to the microsd. I used the [rpi-imager](https://www.raspberrypi.org/software/) for this.

Additionally, I created a new user account "bv" with sudo privileges and switched to login only via public-key for ssh. 

#### [Docker](https://docs.docker.com/engine/)
Docker is a containerization technology, a really cool concept. In a vague sense, these containers are like virtual machines, however, they use OS-level virtualization to have minimal overhead. Docker is [not inherently secure as VM](https://opensource.com/business/14/7/docker-security-selinux) and proper configuration and updates are necessary for security. I'm running all my web services using these containers.

I installed docker using the following commands as per the [installation guide](https://docs.docker.com/engine/install/ubuntu/):
```bash
# Install pre-requisites
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
 # Add docker's gpg key to keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Add docker repo as additional source for apt
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Refresh repositories and install docker
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose
```

---
## Domain
I got my domain from [Freenom](https://www.freenom.com). They provide free domains like example.tld where tld ∈ {tk,ml,ga,cf,gq}. Note: Add the .tld of your choice when searching, else, it would say "not available" when clicking "get it now".

However, freenom has been known to be [scammy](https://hostingpill.com/domain-registrar/freenom/) and I strongly suggest against using freenom for any site that'll get heavy traffic or buying from them.

### DNS Configuration
I have a dynamic IP (not shared). I want the domain to point to my new IP whenever it changes, so I'm using [freenom-script](https://github.com/mkorthof/freenom-script) for this. I set it up with the following steps:
```bash
# Download and Install the script
git clone https://github.com/mkorthof/freenom-script.git &&
cd freenom-script && sudo make install
# Edit the configuration file
# Add `freenom_email` and `freenom_passwd` with the email and password used while registering the domain and comment out MTA (email service not configured)
sudo vim /usr/local/etc/freenom.conf
# Enable auto-updating IP entry
sudo systemctl enable --now freenom-update@beevee.ga.timer
# [Optional] Enable auto-renew (not tested yet as renewal time hasn't come)
sudo systemctl enable --now freenom-renew@beevee.ga.timer
```

I used the [freenom client area](https://my.freenom.com/clientarea.php?managedns=beevee.ga&domainid=<redacted>) to add the following entries.

Name | Type | TTL | Target
---|---|---|---
<empty> | A | 3600 | ~~IP~~ (handled by script)
BITWARDEN | CNAME | 3600 | beevee.ga
COLLABORA | CNAME | 3600 | beevee.ga
JELLYFIN | CNAME | 3600 | beevee.ga
NEXTCLOUD | CNAME | 3600 | beevee.ga
PHOTOPRISM | CNAME | 3600 | beevee.ga
TEST | CNAME | 3600 | beevee.ga
WWW | CNAME | 3600 | beevee.ga

What the columns mean in simple terms are as follows. [Detailed version here](https://www.cloudflare.com/learning/dns/dns-records/). 
- Name: Points to subdomains of your domain, empty just points to your domain
- Type: 
    - A : This points to an IPv4 address
    - AAAA: This points to an IPv6 address (if yours is)
    - CNAME: This points to other domain/subdomain (here it points to my own domain)
- TTL: How long to cache the DNS entry (I used the default of 1hr)
- Target: Where the entry should point to

---
## Networking
The RPi is connected via ethernet to my router. I set up a static LAN IP of 192.168.0.101 on my router for the RPi. On the Pi, I created a custom docker bridge network for the web apps with 
```bash
sudo docker network create webserver
```

### Port Forwarding
I set up the following port forwarding on my router as well as my modem. My modem doesn't support bridged networking and setting the router in DMZ doesn't work either. This setting is usually called virtual servers/applications.  

Name | Interface | Protocol | Private | Public
--- | --- | --- | --- | ---
WebsiteHTTP	| All | TCP | IP: 192.168.0.101 Port: 80 | IP: Port: 80  
WebsiteHTTPS | All | TCP | IP: 192.168.0.101 Port: 443 | IP: Port: 443
Transmission | All | TCP/UDP | IP: 192.168.0.101 Port: 51413 |IP: Port: 51413
Wireguard | All | UDP | IP: 192.168.0.101 Port: 51820 | IP: Port: 51820

### Firewall
It is recommended to use a firewall even when not exposed to the internet. I used ufw with the default state set to deny incoming. The following entries were added using the commands below that. [Full manual here](https://manpages.ubuntu.com/manpages/focal/en/man8/ufw.8.html).

To | Action | From | Comments(not part of ufw)
-- | ------ | ---- | ---
22/tcp | LIMIT | Anywhere | for SSH
53 | ALLOW | 192.168.0.0/24 | for DNS (PiHole) in LAN
80/tcp | ALLOW |Anywhere | for HTTP redirect (SWAG)
443/tcp | ALLOW | Anywhere | for HTTPS (SWAG)
51413 | ALLOW | Anywhere | for Transmission
51820/udp | ALLOW | Anywhere | for Wireguard
22/tcp (v6) | LIMIT | Anywhere (v6) | same as before, in IPv6
80/tcp (v6) | ALLOW | Anywhere (v6) | "
443/tcp (v6) | ALLOW | Anywhere (v6) | "
51413 (v6) | ALLOW | Anywhere (v6) | "
51820/udp (v6) | ALLOW | Anywhere (v6) | "
```bash
sudo ufw default deny # block all incoming by default
sudo ufw limit 22/tcp # for rate limiting ssh
sudo ufw allow <port>/<tcp/udp/any> # allow connections to this port
sudo ufw allow 192.168.0.0/24 to <tcp/udp/any> port <port> # allow connection only from LAN to this port
sudo ufw enable # enable the firewall
```

---
## Services
Writeup in progress do not use the compose files without instructions yet
### Exposed
#### SWAG
#### Nextcloud
#### Collabora
#### Jellyfin 
#### Vaultwarden
#### Photoprism
#### Wireguard

### Internal
#### PiHole
#### Transmission
 
---
## Meme
<img src="meme.png" alt="meme" width="200"/>

---
## To-do
- [ ] Finish writing README
- [x] Sanitise compose files of sensitive information
- [ ] Upload docker-compose and config files
