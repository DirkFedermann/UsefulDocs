The Problem with using WSL2 for local web development is, that the IP Address of the WSL2 Instance is changing with every Windows Boot. With having to rely on the Windows hosts file to get the ability to use local domains (for example test.local.dev) for your Webapp, this a problem.

There are ways to get a WSL2 using a fixed IP Address, but as in time of writing, this is very complicated.
There are tutorials out there that are using the Hyper-V virtual switches or something other that feels really sketchy. And may not work (anymore) or are not working on Windows 10.

This tutorial and script will simply get the current assigned IP Address from the defined WSL2 Instance and replaces the IP Address in the Windows hosts file, of your defined local development domain.

First we need to save this Powershell Script in a convenient location (for example C:\Scripts):

# C:\Scripts\update_wsl_ip_to_hosts.ps1

$hostName = "local.dev" # replace with the host name or domain you want to update
$newIP = (wsl -d Ubuntu hostname -I).trim() # replace the distribution name with your development distribution

$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
$lines = Get-Content $hostsFile


$newLines = foreach ($line in $lines) {
    if ($line -match "^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+((\w+\.)*)$hostName\b") {
        $line -replace "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", $newIP
    } else {
        $line
    }
}

Set-Content $hostsFile -Value $newLines


This script reads every line in the hosts file, looks if it has an IPv4, one or more spaces and then the under $hostname defined host name.
If this is true, then it replaces the IPv4 in that line, with the new IP reported by the WSL2 Instance in $newIP.
This includes all subdomains like test.local.dev .
All lines that don't match the host name are left unchanged.

Because the IP of the WSL2 Instance are only changed, when the Windows Machine is booted up, we can now use the Windows Task Scheduler to automatically execute this script on boot.

For this we open up the Task Scheduler in Windows and add a task.
Name it something like Update hosts file for WSL IP .
Select that it only gets executed, when the user is logged in and let it execute with the highest privileges.

In the Trigger-Tab we add a new trigger and select that is starts at sign in for every user, with a delay of 30 Sekunden. And activate it.
The rest of the settings can be left as they are by default.

In the Actions-Tab we add a new action and select that it should start a program and type in the field for the program/script the path of the powershell.exe:

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe


and in the optional arguments we type this:

-ExecutionPolicy Bypass -File "C:\scripts\update_wsl_ip_to_domain.ps1"


where the last part is the path of the Powershell script we made above.
Click on OK.

The rest of the options of the task can be left alone.

We can execute the task now manually by right-clicking the task in the task library and selecting execute.
That will pop up a Powershell window that should close again after a few seconds.

If we now look in our hosts file in Windows, the IP Address of the hostnames that have local.dev (or what ever you defined in the $hostname in the Powershell script, should have the new IP Address of the WSL2 Instance.

