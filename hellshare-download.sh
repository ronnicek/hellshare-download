#!/bin/bash
#
# script for downloading from Hellshare (premium only)
#
# by ronnicek
#
# for nice progress bar, thanks to http://fitnr.com/showing-file-download-progress-using-wget.html

if [ -z $1 ]; then
 echo "script for downloading from Hellshare (premium only)"
 echo "At first, you need to create a cookie, then you can download from Hellshare."
 echo ""
 echo "USAGE:"
 echo "--create-cookie"
 echo "--download URL"
 echo "--list LIST"
 exit
fi

# download function
function download {
        url=$1
        downloadUrl=`wget -q --load-cookie ~/.hellshare.cookie ${url}?do=fileDownloadButton-showDownloadWindow -O - | grep "http://data" | grep Download | cut -d "'" -f 2`
        filename=`wget -q --load-cookie ~/.hellshare.cookie ${url}?do=fileDownloadButton-showDownloadWindow -O - | grep "filename" | grep "class" | cut -d ">" -f 2 | cut -d "<" -f 1`
        echo -n "Downloading $filename:"
        echo -n "    "
        wget --load-cookies ~/.hellshare.cookie --progress=dot $downloadUrl -O $filename 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
        echo -ne "\b\b\b\b"
        echo " DONE"    
}


# parameters..

if [ "$1" = "--create-cookie" ]; then
        echo -n "Username: "
        read username
        echo -n "Password: "
        read -s password
        echo ""
        echo "Creating cookie under ~/.hellshare.cookie"
        wget --save-cookies ~/.hellshare.cookie --post-data "username=${username}&password=${password}&perm_login=1" -O - "http://www.hellshare.com/?do=login-loginBoxForm-submit" &> /dev/null
        check=`wget -q --load-cookies ~/.hellshare.cookie http://hellshare.com/ -O - | grep $username| wc -l`
        if [ $check = "1" ]; then
                echo "Cookie created."
        else
                echo "Something went wrong.."
        fi
fi

if [ "$1" = "--download" ]; then
        download $2
fi

if [ "$1" = "--list" ]; then
        cat $2 | grep -v '^#' | while read line
        do
                download $line
                sedline=${line//\//\\/}
                sed -i "s/$sedline/\#DONE: $sedline/g" $2
        done
fi

