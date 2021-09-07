#!/bin/bash

sudo apt-get install -y python3-pip
sudo apt-get install -y git
sudo apt-get install python-dnspython
sudo apt install jq -y
sudo apt install lynx

mkdir ~/tools
cd ~/tools/

echo "installing massdns"
git clone https://github.com/blechschmidt/massdns.git
cd ~/tools/massdns
make
cd bin
sudo cp -i ~/tools/massdns/bin/massdns /usr/bin/massdns
cd ~/tools/
echo "done"

echo "installing SubDomainizer"
git clone https://github.com/nsonaniya2010/SubDomainizer.git
cd SubDomainizer
pip3 install -r requirements.txt
cd ~/tools/
echo "done"

echo "installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
pip install -r requirements.txt
cd ~/tools/
echo "done"

echo "installing findomain"
wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux
chmod +x findomain-linux
echo "done"

echo "installing ctfr"
git clone https://github.com/UnaPibaGeek/ctfr.git
cd ctfr
pip3 install -r requirements.txt
cd ~/tools/
echo "done"

echo "installing naabu"
sudo apt install -y libpcap-dev
GO111MODULE=on go get -v github.com/projectdiscovery/naabu/v2/cmd/naabu
echo "done"

echo "installing dnsx"
go get -v github.com/projectdiscovery/dnsx/cmd/dnsx
echo "done"

echo "installing nuclei"
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
nuclei update-templates
echo "done"

echo "installing unfurl"
go get -u github.com/tomnomnom/unfurl
echo "done"

echo "installing anew"
go get -u github.com/tomnomnom/anew
echo "done"

echo "installing github-subdomains"
go get -u github.com/gwen001/github-subdomains
echo "done"

echo "installing crobat"
go get github.com/cgboal/sonarsearch/cmd/crobat
echo "done"

echo "installing gauplus"
GO111MODULE=on go get -u -v github.com/bp0lr/gauplus
echo "done"

echo "installing waybackurls"
go get github.com/tomnomnom/waybackurls
echo "done"

echo "installing chaos"
GO111MODULE=on go get -v github.com/projectdiscovery/chaos-client/cmd/chaos
echo "done"

echo "installing puredns-v2"
GO111MODULE=on go get github.com/d3mondev/puredns/v2
echo "done"

echo "installing crlfuzz"
GO111MODULE=on go get -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz
echo "done"

echo "installing dnsgen"
sudo pip3 install dnsgen
echo "done"

echo "installing subfinder"
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
echo "done"

echo "installing assetfinder"
go get -u github.com/tomnomnom/assetfinder
echo "done"

echo "installing shuffledns"
GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
echo "done"

echo "installing httpx"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
echo "done"

echo "installing dnsvalidator"
git clone https://github.com/vortexau/dnsvalidator.git
cd dnsvalidator
pip install -r requirements.txt
sudo python3 setup.py install
dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 20 -o ~/tools/resolvers.txt
cd ~/tools/
echo "done"

echo "installing wordlist"
wget https://github.com/danielmiessler/SecLists/raw/master/Discovery/DNS/dns-Jhaddix.txt
cat dns-Jhaddix.txt | head -n -14 > dns-all.txt
rm dns-Jhaddix.txt
echo "done"
clear

echo "Done! All tools are set up in ~/tools & ~/go/bin"
echo "One last time: don't forget to set up API key in reconx.sh & other tools manually"
