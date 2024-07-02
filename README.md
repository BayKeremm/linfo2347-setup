# linfo2347-setup

## 1. VirtualBox
### 1.1 Importing the VM
- Download the `.ova` file from MS
- In VirtualBox, click `File>Import Appliance`
- Select the downloaded `.ova` file and click "Next"
- Select MAC Address Policy as "Generate new MAC addresses for all network adapters"
- Click "Finish"

>The VM already comes with all software pre-installed.
>The script that installed all the software can be found in `~/install_linfo2347.sh`
### 1.2 Username/password
- username: linfo2347-student
- password: student123
### 1.3 Setting up port forwarding
For the DNS lab we need to set up port forwarding.
- Select a port number that is not used by any other process on your computer
	- e.g., `1234`
- Go to: `VM Settings>Network>`
	- Find the NAT adapter, should be the "Adapter 2"
	- Click "Advanced" and then "Port Forwarding"
	- Click on the plus sign to the right of the pop-up.
		- Name: `DNS`
		- Protocol: `UDP`
		- Host IP: your computer's IP address from the router (run ifconfig to see)
			- This is the IP address other computer's in the same subnet can use to communicate with you
		- Guest IP: Leave it empty
		- Guest Port: Selected port (e.g., `1234`)
	- Click "OK"

Once the DNS server is setup in the VM, you can verify the port forwarding works with the following:
```
nslookup -port=<SELECTED_PORT> bindserver.cherry.example <HOST_IP>
```

## 2. Multipass (Apple Silicon)
### 2.1 Prerequisites
- Homebrew
	- `https://brew.sh/`
- multipass
	- `brew install multipass`
### 2.2 VM setup
First create a multipass instance:
```
multipass launch lts --cpus 4 --disk 30G --memory 8G --name linfo2347-vm
```

> - `lts` is the alias for Ubuntu 24.04 LTS
>	- If there is a problem with it, you can find the correct alias for ubuntu 24.04 with the following command:
>		- `multipass find` 
>		- and look for the 24.04 image alias


Then, goto: `https://tools.netsa.cert.org/yaf2/download.html` and download "yaf 2.15.0" on your host machine.
With the following command transfer the downloaded file to the VM:
```
multipass transfer ./yaf-2.15.0.tar.gz linfo2347-vm:./
```

Open the shell with the following command:
```
multipass shell linfo2347-vm
```

Then get the setup script for the course inside the vm:
```
wget https://raw.githubusercontent.com/BayKeremm/linfo2347-setup/main/install_linfo2347.sh
```
And then run the script and follow the prompts.
```
sudo bash install_linfo2347.sh
```


>Make sure `yaf-2.15.0.tar.gz` is in the same directory as `install_linfo2347.sh`



### 2.3 Port forwarding workaround
For the DNS lab we need to be able to port forward requests made to the host computer to the vm. On Mac OS we propose the following workaround:
- A python proxy forwarding requests from host to vm and vice versa

Get the code:
```
wget https://raw.githubusercontent.com/BayKeremm/linfo2347-setup/main/udp_forwarder.py
```
**Changes to be made in the code:**
- line 4: Change the `HOST_IP` to your computer's IP address
- line 5: Change the `VM_IP` to your VM instance's IP address
- line 6: `HOST_PORT` You can leave the default `1234` but you can also select whichever port you want to listen to.
- line 7: `VM_PORT`, this is by default 53 for DNS, but change it to 443 for DoH and 853 for DoT.

Then run the code:
```
python3 udp_forwarder.py
```

