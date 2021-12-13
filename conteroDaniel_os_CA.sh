#!/bin/bash

# GitHub repo SSH: git@github.com:SrAlch/conteroDaniel_os_CA.git
# GitHub repo HTTPS: https://github.com/SrAlch/conteroDaniel_os_CA.git

checkAndCreateFile() {
    # Checks if the given file or folder exists. If it doesn't will create a
    # file from the given path with zero lenght (assuming that no non existing
    # path is a folder) 

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
    # Checks if the <user> tmp folder exists, otherwise creates it
    # Compares the content of the current "/home/<user>" with the content on
    # "/tmp/backup/<user>" and increste to last version in case of existing files 

    local file_path="$1"
    local file_name=""
    file_name=$(basename "$file_path")
    local tmp_user="$extract_path/$2"
    if ! [ -d "$tmp_user" ]
    then
        #mkdir "$tmp_user"
        echo "test"
    fi

    if [ -f "$tmp_user/$file_name" ]
    then

        echo "test"
    else
        local final_path="$tmp_user/$file_name"
        echo "test"
    fi

    #cp "$file_path" "$final_path"
}

readBackupFile() {
    # Checks if ".backup" file exists for the given user if not, creates file 
    # with zero lenght. If the file exists reads each line inside it cleaning
    # paths.

    local user_path=$1
    local user_name=$2
    local file_name=".backup"
    local file_path="${user_path}${file_name}"
    if [ -f "$file_path" ]
    then
        echo -e "   $file_name file found in $file_path"
        cd "$user_path" || exit
        while IFS= read -r line || [ -n "$line" ]
        do 
            [ -z "$line" ] && continue
            if [ "${line:0:1}" == "." ]
            then
                local raw_path="$line"
            elif [ "${line:0:1}" == "~" ]
            then
                local raw_path="${user_path}${line:2}"
            fi
                checkAndCreateFile "$raw_path"
                fileComparing "$raw_path" "$user_name"         
        done < "$file_path"
    else
        #touch "$file_path"
        echo -e "   $file_name file created in $file_path"
    fi
}

getFileContent() {
    # Checks if given name exists as user, otherwise finish the function with
    # msg that user couldn't be found.

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
    # Compress back the backup.tr.gz file after all the operations are completed

    #tar -zcf "$backup_path" "$extract_path"
    echo "File $backup_path is being compressed"
}

backupExtract() {
    # Checks if "/tmp/backup" exists (extraction path given) and creates the path
    # if doesn't exist. Then checks if "/var/backup.tar.gz" exists, extracting 
    # it on the given location, otherwise promnts msg couldnt be found.

    if ! [ -d "$extract_path" ]
    then
        #mkdir "$extract_path"
        echo "$extract_path Path created"
    fi

    if [ -f "$backup_path" ]
    then
        #tar -zxf "$backup_path" -C "$extract_path"
        echo "$backup_path is being extracted in $extract_path"
    else
        echo "$backup_path couldn't be found"
    fi
}

backup_path="/var/backup.tar.gz"
extract_path="/tmp/backup"
file_input=$1       # Input file as argument
backupExtract
echo -e "\nStarting user packing...\n"

while IFS= read -r line || [ -n "$line" ]
do 
    [ -z "$line" ] && continue
    getFileContent "$line"
done < "$file_input"

compressBackup

echo -e "\nThe backup script is completed"