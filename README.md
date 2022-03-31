# Web-Enumeration-Script
This Script contains tools like assetfinder, amass, httprobe, subjack, nmap, waybackurls and gowitness.

# To run the Script:
- Syntax:
`./webenumscript.sh [domain]`
- For Example:
`./webenumscript.sh quitehacker.com`

# Installation of Tools used in this Script

- AssetFinder Installation
`sudo apt install assetfinder`

- Amass Installation
`sudo apt install amass`

- HTTProbe Installation
`sudo apt install httprobe`

- SubJack Installation
`sudo apt install subjack`

- Nmap Installation
`sudo apt install nmap`

- Go Programming Language (golang) Installation
`sudo apt install golang-go`

> Edit the Profile
`mousepad ~/.profile`

> Add These Two lines into the end of the profile file
```
export GOPATH="$HOME/go"
PATH="$GOPATH/bin:$PATH"
```
- WayBackURLs Installation
`go install github.com/tomnomnom/waybackurls@latest`
`sudo cp /home/kali/go/bin/waybackurls /usr/bin`

- GoWitness Installation
`go install github.com/sensepost/gowitness@latest`
`sudo cp /home/kali/go/bin/gowitness /usr/bin`
