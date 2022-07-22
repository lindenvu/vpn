#!/bin/bash

# Enable or disable the Cisco AnyConnect services


# services
systemService="/Library/LaunchDaemons/com.cisco.anyconnect.vpnagentd.plist"
userGUIService="/Library/LaunchAgents/com.cisco.anyconnect.gui.plist"
userNotificationService="/Library/LaunchAgents/com.cisco.anyconnect.notification.plist"

# Current user
currentUser=$(ls -l /dev/console | awk '{print $3}')

function checkIfPlistsExist () {
    if [[ ! -e "$systemService" ]] ; then
        echo "${systemService} not found"
        exit 1
    fi
    if [[ ! -e "$userGUIService" ]] ; then
        echo "${userGUIService} not found"
        exit 1
    fi
    if [[ ! -e "$userNotificationService" ]] ; then
        echo "${userNotificationService} not found"
        exit 1
    fi
}

function checkSudo () {
    if [[ "$EUID" -ne 0 ]] ; then
        echo "Please run with sudo/root"
        exit
    fi
}


function disableServices () {
    pkill "AnyConnect"
    /usr/bin/sudo -u "$currentUser" /bin/launchctl unload -w "$userNotificationService"
    /usr/bin/sudo -u "$currentUser" /bin/launchctl unload -w "$userGUIService" > /dev/null
    /bin/launchctl unload -w "$systemService"
    pkill "AnyConnect"
}


function enableServices () {
    /bin/launchctl load -w "$systemService"
    /usr/bin/sudo -u "$currentUser" /bin/launchctl load -w "$userNotificationService"
    /usr/bin/sudo -u "$currentUser" /bin/launchctl load -w "$userGUIService"
}

function toggleCheck () {
    if pgrep vpnagentd ; then
        echo "vpnagentd service running."
        read -r -p "Stop service? [y,n]: " userAnswer
        if [[ "$userAnswer" == "y" ]] ; then
            disableServices
        fi
    else
        echo "vpnagentd service not running"
        read -r -p "Start service? [y,n]: " userAnswer
        if [[ "$userAnswer" == "y" ]] ; then
            enableServices
        fi
    fi
}


checkIfPlistsExist
checkSudo
toggleCheck
