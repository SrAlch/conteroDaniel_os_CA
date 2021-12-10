#!/bin/bash
# GitHub repo: git@github.com:SrAlch/conteroDaniel_os_CA.git

checkAndCreateFile() {
    local file_path=$1
    if ! [ -f "$file_path" ]
    then
        echo -e "       File couldn't be found, creating it with zero-lenght  $file_path"
        #mkdir -p -- "${file_path%/*}" && touch -- "$file_path"
        
    else
        echo -e "       This file already exist  $file_path"
    fi
}

fileComparing() {
    local file_name=$1
    local tmp_user="$extract_path/$2"

    if [ -f "$tmp_user/" ]
    then
        echo "test"
    else
        echo "test"
    fi
}

readBackupFile() {
    local user_path=$1
    local user_name=$2
    local file_name=".backup"
    local file_path="${user_path}${file_name}"
    if [ -f "$file_path" ]
    then
        echo -e "   $file_name file found $file_path"
        cd "$user_path" || exit
        while IFS= read -r line || [ -n "$line" ]
        do 
            [ -z "$line" ] && continue 
            if [ "${line:0:1}" == "." ]
            then
                checkAndCreateFile "$line"
                fileComparing "$line" "$user_name"
            elif [ "${line:0:1}" == "~" ]
            then
                local abs_path="${user_path}${line:2}"
                checkAndCreateFile "$abs_path"
            fi           
        done < "$file_path"
    else
        #touch "$file_path"
        echo -e "   $file_name file created in $file_path"
    fi
}

getFileContent() {
    local user_name=$1
    local user_path="/home/${user_name}/"
    if [ -d "$user_path" ]
    then
        echo "$user_name"
        readBackupFile "$user_path" "$user_name"
    else
        echo "$user_name user could not be found"
    fi
}

compressBackup() {
    echo "Test"
}

backupExtract() {
    if ! [ -d "$extract_path" ]
    then
        #mkdir "$extract_path"
        echo "$extract_path Path created"
    fi

    if [ -f "$backup_path" ]
    then
        #tar -zxf "$backup_path" -C
        echo "$backup_path is being extracted in $extract_path"
    else
        echo "$backup_path couldn't be found"
    fi
}

backup_path="/var/backup.tar.gz"
extract_path="/tmp/backup"
file_input=$1
backupExtract
echo -e "\nStarting user packing...\n"

while IFS= read -r line || [ -n "$line" ]
do 
    [ -z "$line" ] && continue
    getFileContent "$line"
done < "$file_input"

compressBackup