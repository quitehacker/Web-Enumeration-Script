#!/bin/bash

url=$1


#################### Creating Directories ####################

if [ ! -d "url" ];then
	mkdir $url
fi

if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi

if [ ! -d "$url/recon/httprobe" ];then
	mkdir $url/recon/httprobe
fi

if [ ! -f "$url/recon/httprobe/alive.txt" ];then
	touch $url/recon/httprobe/alive.txt
fi

if [ ! -d "$url/recon/potential_takeovers" ];then
	mkdir $url/recon/potential_takeovers
fi

if [ ! -f "$url/reon/final.txt" ];then
	touch $url/recon/final.txt
fi

if [ ! -d "$url/recon/wayback" ];then
	mkdir $url/recon/wayback
fi

if [ ! -d "$url/recon/wayback/params" ];then
	mkdir $url/recon/wayback/params
fi

if [ ! -d "$url/recon/wayback/extensions" ];then
	mkdir $url/recon/wayback/extensions
fi

if [ ! -d "$url/recon/scans" ];then
	mkdir $url/recon/scans
fi

if [ ! -d '$url/recon/gowitness' ];then
	mkdir $url/recon/gowitness
fi


#################### Running Commands ####################


echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/final.txt
rm $url/recon/assets.txt


# Uncomment this part for Double checking of domains.
# echo "[+] Double checking for subdomains with amass..."
# amass enum -d $url >> $url/recon/f.txt
# sort -u $url/recon/f.txt >> $url/recon/final.txt
# rm $url/recon/f.txt


echo "[+] Probing for alive domains..."
cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' | tee -a $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt


echo "[+] Checking for possible subdomains takeover..."
if [ ! -f "$url/recon/potential_takeovers/potential_takeovers.txt" ];then
	touch $url/recon/potential_takeovers/potential_takeovers.txt
fi

subjack -w $url/recon/final.txt -t 100 -timeout 30 -ssl -c /usr/share/subjack/fingerprints.json -v 3 -o $url/recon/potential_takeovers/potential_takeovers.txt


echo "[+] Scanning for open ports..."
nmap -iL $url/recon/httprobe/alive.txt -oA $url/recon/scans/scanned.txt


echo "[+] Scrapping wayback data..."
cat $url/recon/final.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt

echo "[+] Pulling and compilling all possible params found in wayback data..."
cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
for line in $(cat $url/recon/wayback/params/wayback_params.txt);do echo $line'=';done

echo "[+] Pulling and compilling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat $url/recon/wayback/wayback_output.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/recon/wayback/extensions/js1.txt
		sort -u $url/recon/wayback/extensions/js1.txt >> $url/recon/wayback/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> $url/recon/wayback/extensions/jsp1.txt
		sort -u $url/recon/wayback/extensions/jsp1.txt >> $url/recon/wayback/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> $url/recon/wayback/extensions/json1.txt
		sort -u $url/recon/wayback/extensions/json1.txt >> $url/recon/wayback/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> $url/recon/wayback/extensions/php1.txt
		sort -u $url/recon/wayback/extensions/php1.txt >> $url/recon/wayback/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> $url/recon/wayback/extensions/aspx1.txt
		sort -u $url/recon/wayback/extensions/aspx1.txt >> $url/recon/wayback/extensions/aspx.txt
	fi
done

rm $url/recon/wayback/extensions/js1.txt
rm $url/recon/wayback/extensions/jsp1.txt
rm $url/recon/wayback/extensions/json1.txt
rm $url/recon/wayback/extensions/php1.txt
rm $url/recon/wayback/extensions/aspx1.txt


echo "[+] Running gowitness against all compiled domains ..."
gowitness file -f $url/recon/httprobe/alive.txt --screenshot-path $url/recon/gowitness/screenshots --db-path $url/recon/gowitness/gowitness.sqlite3
