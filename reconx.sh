#!/bin/bash
# coded by 0ximtiaz (https://github.com/0ximtiaz)
# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
BRed='\033[1;31m'         # Red B
NC='\033[0m'              # No Color
domain=$1                 # Domain

function banner(){
clear
     echo -e "${BRed}                            "
     echo -e "   ________  _________  ____  _  __"
     echo -e "  / ___/ _ \/ ___/ __ \/ __ \| |/_/"
     echo -e " / /  /  __/ /__/ /_/ / / / />  <  "
     echo -e "/_/   \___/\___/\____/_/ /_/_/|_| v1.2 by 0ximtiaz"
     echo -e "                              ${NC}"
}
banner

     echo -e "${Blue}[-] Running Enumerating Subdomains For${Purple} $domain ${NC}"
    
####################################### API_KEY ###############################################
export CHAOS_KEY=
GITHUB_TOKEN=""
########################################API_KEY##########################################

CreateDirectory() {
    echo -e "${Green}[-] Running Create Directory ${NC}"
    mkdir -p $domain $domain/subdomain $domain/subdomain/.passive $domain/subdomain/.active $domain/subdomain/.tmp $domain/osint $domain/nuclei
}
CreateDirectory

############################################################ Subdomain Enumeration ############################################################
Passive() {
    echo -e "${Green}[-] Running Passive Enumeration ${NC}"
    curl -s -k "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sed '/^\./d' | anew -q $domain/subdomain/.passive/anubis.txt
    curl -s -k "https://dns.bufferover.run/dns?q=.$domain" | jq -r '.FDNS_A'[],'.RDNS'[] 2>/dev/null | cut -d ',' -f2 | grep -F ".$domain" | anew -q $domain/subdomain/.passive/bufferover.txt
    curl -s -k "https://tls.bufferover.run/dns?q=.$domain" | jq -r .Results[] 2>/dev/null | cut -d ',' -f3 | grep -F ".$domain" | anew -q $domain/subdomain/.passive/tlsbufferover.txt
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u | grep -o "\w.*$domain" | anew -q $domain/subdomain/.passive/crt.txt
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | grep -o "\w.*$domain" | anew -q $domain/subdomain/.passive/hackertarget.txt
    curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep -o "\w.*$domain" | anew -q $domain/subdomain/.passive/riddler.txt
    curl -s "https://securitytrails.com/list/apex_domain/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$domain" | sort -u | anew -q $domain/subdomain/.passive/securitytrails.txt
    github-subdomains -d $domain -t $GITHUB_TOKEN -o $domain/subdomain/.passive/github_sub1.txt &> /dev/null
    github-subdomains -d $domain -k -q -t $GITHUB_TOKEN -o $domain/subdomain/.passive/github_sub2.txt &> /dev/null
    crobat -s $domain | anew -q $domain/subdomain/.passive/crobat_psub.txt
    gauplus -random-agent -subs $domain | unfurl -u domains | anew -q $domain/subdomain/.passive/gau_psub.txt
    waybackurls $domain | unfurl -u domains | anew -q $domain/subdomain/.passive/wayback_psub.txt
    python3 ~/tools/ctfr/ctfr.py -d $domain -o $domain/subdomain/.passive/crtsh_sub.txt &> /dev/null
    chaos -d $domain -silent | anew -q $domain/subdomain/.passive/chaos.txt
    subfinder -d $domain -all -o $domain/subdomain/.passive/subfinder.txt &> /dev/null
    assetfinder -subs-only $domain | anew -q $domain/subdomain/.passive/assetfinder.txt
    amass enum -passive -d $domain -o $domain/subdomain/.passive/amass.txt &> /dev/null
    ~/tools/findomain-linux -t $domain -u $domain/subdomain/.passive/findomain.txt &> /dev/null
    python3 ~/tools/SubDomainizer/SubDomainizer.py -u $domain -o $domain/subdomain/.passive/SubDomainizer.txt &> /dev/null
    python3 ~/tools/Sublist3r/sublist3r.py -d $domain -o $domain/subdomain/.passive/Sublist3r.txt &> /dev/null
    cat $domain/subdomain/.passive/*.txt | grep -F ".$domain" | sort -u > $domain/subdomain/passive.txt
}
Passive


Active() {
    echo -e "${Green}[-] Running Active Enumeration ${NC}"
    puredns bruteforce ~/tools/dns-all.txt $domain -r ~/tools/resolvers.txt -q | anew -q $domain/subdomain/.active/puredns.txt
    cat $domain/subdomain/.active/*.txt | grep -F ".$domain" | sed "s/*.//" > $domain/subdomain/active.txt
}
Active


ActPsv() {
    echo -e "${Green}[-] Running Active & Passive Enum Result ${NC}"
    cat $domain/subdomain/active.txt $domain/subdomain/passive.txt | grep -F ".$domain" | sort -u | shuffledns -d $domain -r ~/tools/resolvers.txt -o $domain/subdomain/ActivePassive.txt &> /dev/null
}
ActPsv


Permute() {
    echo -e "${Green}[-] Running Dual Permute Enumeration ${NC}"
    dnsgen $domain/subdomain/ActivePassive.txt | shuffledns -d $domain -r ~/tools/resolvers.txt -o $domain/subdomain/permute1_tmp.txt &>/dev/null
    cat $domain/subdomain/permute1_tmp.txt | grep -F ".$domain" > $domain/subdomain/permute1.txt 
    dnsgen $domain/subdomain/permute1.txt | shuffledns -d $domain -r ~/tools/resolvers.txt -o $domain/subdomain/permute2_tmp.txt &>/dev/null
    cat $domain/subdomain/permute2_tmp.txt | grep -F ".$domain" > $domain/subdomain/permute2.txt
    cat $domain/subdomain/permute1.txt $domain/subdomain/permute2.txt | grep -F ".$domain" | sort -u > $domain/subdomain/permute.txt
    rm $domain/subdomain/permute1.txt $domain/subdomain/permute1_tmp.txt $domain/subdomain/permute2.txt $domain/subdomain/permute2_tmp.txt
}
Permute


SubFinal() {
    echo -e "${Green}[-] Running Enumerated Final Result ${NC}"
    cat $domain/subdomain/active.txt $domain/subdomain/passive.txt $domain/subdomain/ActivePassive.txt $domain/subdomain/permute.txt 2>/dev/null | grep -F ".$domain" | sort -u > $domain/subdomain/all.txt
}
SubFinal


Filter() {
    echo -e "${Green}[-] Running Filter Dead Records ${NC}"
    cat $domain/subdomain/all.txt | dnsx -silent -o $domain/subdomain/dnsx.txt &> /dev/null
}
Filter


HttpProbe() {
    echo -e "${Green}[-] Running Http Probe ${NC}"
    httpx -l $domain/subdomain/dnsx.txt -silent -timeout 20 -o $domain/subdomain/sub.httpx &>/dev/null
    httpx -l $domain/subdomain/dnsx.txt -csp-probe -silent -timeout 20 | grep -F ".$domain" | anew $domain/subdomain/sub.httpx &>/dev/null
    httpx -l $domain/subdomain/dnsx.txt -tls-probe -silent -timeout 20 | grep -F ".$domain" | anew $domain/subdomain/sub.httpx &>/dev/null
}
HttpProbe


Output() {
    mv $domain/subdomain/active.txt $domain/subdomain/passive.txt $domain/subdomain/ActivePassive.txt $domain/subdomain/permute.txt $domain/subdomain/all.txt $domain/subdomain/dnsx.txt $domain/subdomain/.tmp 2>/dev/null
}
Output
############################################################ Subdomain Enumeration ############################################################


Scanner() {
    echo -e "${Green}[-] Running Port Scan ${NC}"
    naabu -iL $domain/subdomain/.tmp/dnsx.txt -silent -p - -o $domain/subdomain/ports.txt &> /dev/null
    echo -e "${Green}[-] Running CNAME Racord ${NC}"
    cat $domain/subdomain/sub.httpx | dnsx -silent -cname -resp | anew $domain/subdomain/CNAME.txt &> /dev/null
    echo -e "${Green}[-] Running DNS Probe ${NC}"
    cat $domain/subdomain/sub.httpx | dnsx -silent -rcode NOERROR,NXDOMAIN,SERVFAIL,REFUSED | anew $domain/subdomain/DNS.txt &> /dev/null
    echo -e "${Green}[-] Running Subdomain Takeover ${NC}"
    cat $domain/subdomain/sub.httpx | nuclei -silent -t ~/nuclei-templates/takeovers/ -o $domain/subdomain/SubdomainTakeover.txt &> /dev/null
    echo -e "${Green}[-] Running Nuclei Scan ${NC}"
    nuclei update-templates &> /dev/null
    cat $domain/subdomain/sub.httpx | nuclei -silent -t ~/nuclei-templates -o $domain/nuclei/nuclei.txt &> /dev/null
}
Scanner


OSINT() {
    echo -e "${Green}[-] Running OSINT ${NC}"
    lynx -dump "https://domainbigdata.com/${domain}" | tail -n +19 > $domain/osint/domain_info_general.txt
}
OSINT


# Results Count
    echo -e "${Yellow}[-] Total Subdomain Found:$(cat $domain/subdomain/sub.httpx | wc -l) ${NC}"
    echo -e "${Yellow}[-] Total Open Port Found:$(cat $domain/subdomain/ports.txt | wc -l) ${NC}"
    echo -e "${Yellow}[-] Total Subdomain Takeover:$(cat $domain/subdomain/SubdomainTakeover.txt | wc -l) ${NC}"
    
