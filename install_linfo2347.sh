#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

line_length=60

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

center_text() {
  local text="$1"
  local width="$2"
  local text_length=${#text}
  local padding=$(( (width - text_length) / 2 ))
  
  printf "%*s%s%*s\n" $padding "" "$text" $padding ""
}

package_exists() {
    dpkg -l | grep -qw "$1"
}

install_package_if_needed() {
    local package="$1"
    if package_exists "$package"; then
        echo -e "\e[32m$package is already installed.\e[0m"
    else
        echo -e "\e[31m$package is not installed. Installing $package...\e[0m"
        sudo apt install -y "$package"
    fi
}



echo
echo -e "\e[33m╓────────────────────────────────────────────────────────────╖"
center_text "Welcome to linfo2347 setup!" "$line_length"
echo -e "╙────────────────────────────────────────────────────────────╜\e[0m"
echo


software_message="\e[33mVerifying and installing necessary software...\e[0m"
echo -e "$software_message"

sudo apt update

sudo apt upgrade

# Check if curl is installed
if command_exists curl; then
    echo -e "\e[32mcurl is already installed.\e[0m"
else
    echo -e "\e[31mcurl is not installed. Installing curl...\e[0m"
    sudo apt install -y curl
fi

dvwa_message="\e[33mDVWA installer \e[0m"
echo -e "$dvwa_message"
sudo bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/IamCarron/DVWA-Script/main/Install-DVWA.sh)"

# Check if Python is installed
if command_exists python3; then
    echo -e "\e[32mPython is already installed.\e[0m"
else
    echo -e "\e[31mPython is not installed. Installing Python...\e[0m"
    sudo apt install -y python3
fi

# Check if Java is installed
if command_exists java; then
    echo -e "\e[32mjava is already installed.\e[0m"
else
    echo -e "\e[31mjava is not installed. Installing Java...\e[0m"
    sudo apt install -y default-jre
fi

# Check if Javac is installed
if command_exists javac; then
    echo -e "\e[32mjavac is already installed.\e[0m"
else
    echo -e "\e[31mjavac is not installed. Installing javac...\e[0m"
    sudo apt install -y default-jdk
fi

# Check if pip is installed
if command_exists pip; then
    echo -e "\e[32mpip is already installed.\e[0m"
else
    echo -e "\e[31mpip is not installed. Installing pip...\e[0m"
    sudo apt install -y python3-pip
fi

# Check if scapy is installed
if command_exists scapy; then
    echo -e "\e[32mscapy is already installed.\e[0m"
else
    echo -e "\e[31mscapy is not installed. Installing scapy...\e[0m"
    sudo apt install -y python3-scapy
fi

# Check if snort is installed
if command_exists snort; then
    echo -e "\e[32msnort is already installed.\e[0m"
else
    echo -e "\e[31msnort is not installed. Installing snort...\e[0m"
    sudo apt install -y snort
fi

if command_exists vim; then
    echo -e "\e[32mvim is already installed.\e[0m"
else
    echo -e "\e[31mvim is not installed. Installing vim...\e[0m"
    sudo apt install -y vim
fi

if command_exists ifconfig; then
    echo -e "\e[32mifconfig is already installed.\e[0m"
else
    echo -e "\e[31mifconfig is not installed. Installing ifconfig...\e[0m"
    sudo apt install -y net-tools
fi

# Check if mininet is installed
if command_exists mn; then
    echo -e "\e[32mmininet is already installed.\e[0m"
else
    echo -e "\e[31mmininet is not installed. Installing mininet...\e[0m"
    sudo apt install -y mininet
    sudo apt install -y openvswitch-switch
    # TODO: is this service start necessary ? 
    sudo service openvswitch-switch start
    sudo apt install -y openvswitch-testcontroller
    sudo ln /usr/bin/ovs-testcontroller /usr/bin/controller
fi

if command_exists vsftpd; then
    echo -e "\e[32mvsftpd is already installed.\e[0m"
else
    echo -e "\e[31mvsftpd is not installed. Installing vsftpd...\e[0m"
    sudo apt install -y vsftpd
fi
install_package_if_needed ntp
sudo apt install -y bind9
install_package_if_needed bind9utils
install_package_if_needed openssh-server


# Check if yaf is installed
if command_exists yaf; then
    echo -e "\e[32myaf is already installed.\e[0m"
else
    echo -e "\e[31myaf is not installed. Installing yaf...\e[0m"
    echo -e "\e[33mStarting the setup and installation process...\e[0m"

    # Preliminaries
    echo -e "\e[33mInstalling preliminary packages...\e[0m"
    # Add any preliminary installations here if needed, e.g., sudo apt install some-package

    # Install glib2
    install_package_if_needed libglib2.0-dev

    # Install the IPFIX library
    install_package_if_needed libfixbuf-dev

    # Install the pcap library
    install_package_if_needed libpcap-dev

    # Download and compile YAF
    YAF_VERSION="2.15.0"
    YAF_TARBALL="yaf-${YAF_VERSION}.tar.gz"

    # Check if the tar file is already in the directory
    if [ -f "$YAF_TARBALL" ]; then
        echo -e "\e[33m$YAF_TARBALL already exists in the directory. Skipping download...\e[0m"
    else
        echo -e "\e[33mExiting: Please download YAF version ${YAF_VERSION} and relaunch" 
        echo -e "(user consent is needed on the website goto: https://tools.netsa.cert.org/yaf2/download.html)...\e[0m"
        exit
    fi


    echo -e "\e[33mExtracting YAF...\e[0m"
    tar xfz $YAF_TARBALL

    echo -e "\e[33mCompiling YAF...\e[0m"
    cd "yaf-${YAF_VERSION}"
    ./configure
    make

    echo -e "\e[33mThe binary executables 'yaf' and 'yafscii' are now in the 'src' directory.\e[0m"

    read -p "Do you want to install the YAF tools to your path? (y/n): " install_yaf
    if [ "$install_yaf" = "y" ] || [ "$install_yaf" = "Y" ]; then
        echo -e "\e[33mInstalling YAF tools to your path...\e[0m"
        sudo make install
        sudo ldconfig
    else
        echo -e "\e[33mSkipping installation of YAF tools to your path.\e[0m"
    fi
fi


# Optional: Install additional packages
optional_packages=(
    tcpdump
    tshark
    graphviz
    imagemagick
    python3-gnuplot
    python3-cryptography
    python3-pyx
    python3-ecdsa
    python3-sklearn
    python3-paramiko
    python3-sklearn-lib
)

read -p "Do you want to install the optional packages? (y/n): " install_optional
if [ "$install_optional" = "y" ] || [ "$install_optional" = "Y" ]; then
    echo -e "\e[33mInstalling optional packages...\e[0m"
    for package in "${optional_packages[@]}"; do
        install_package_if_needed "$package"
    done
else
    echo -e "\e[33mSkipping installation of optional packages.\e[0m"
fi

echo -e "\e[92mAll required software has been checked and installed as necessary.\e[0m"

