#!/bin/bash

FG_RED=$(tput setaf 160)
FG_GREEN=$(tput setaf 29)
FG_BLUE=$(tput setaf 33)
FG_BOLD=$(tput bold)
FG_DEFAULT=$(tput sgr0)

log_OK(){
    echo -e "[ ${FG_GREEN}OK${FG_DEFAULT} ]  $1"
}
log_NOK(){
    echo -e "[ ${FG_RED}NOK${FG_DEFAULT} ] $1"
}
print_step(){
    echo -e "\n${FG_BOLD}${FG_BLUE}$1${FG_DEFAULT}"
}

print_step "STEP 1: Update OS"
if apt update > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt autoremove -y > /dev/null 2>&1; then
    log_OK "Update OS"
else
    log_NOK "Update OS"
    exit 1
fi

print_step "STEP 2: Install packages"
for package in "tree" "vim" "python3-pip" "htop" "build-essential" "vlc" "tldr" "libreoffice-common"; do
    if apt install -y $package > /dev/null 2>&1; then
        log_OK "Install: $package"
    else
        log_NOK "Install: $package"
    fi
done

print_step "STEP 3: Ensure that python3-pip module is installed"
if dpkg -l | grep python3-pip > /dev/null 2>&1; then
    log_OK "pip modue installed"
else
    log_NOK "pip modue installed"
    exit 3
fi

print_step "STEP 4: Install ansible via pip"
if python3 -m pip install ansible > /dev/null 2>&1; then
    log_OK "Install: ansible"
else
    log_NOK "Install: ansible"
    exit 4
fi

print_step "STEP 5: Check ansible version as $(whoami)"
if ansible --version > /dev/null 2>&1; then
    ver=$(ansible --version | head -n1 | cut -d [ -f 2 | tr -d ])
    log_OK "ansible version: $ver"
else
    log_NOK "Could not get ansible version"
    exit 5
fi

print_step "STEP 6: Install ansible module"
if ansible-galaxy collection install community.general > /dev/null 2>&1; then
    log_OK "install ansible module: community.general"
else
    log_NOK "install ansible module: community.general"
    exit 6
fi
