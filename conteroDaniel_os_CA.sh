#!/bin/bash
file_input=$1

backupCheckUp() {
    backup_path="/var/backup.tar.gz"
    extract_path=""
    if [ -f "$backup_path" ]
    then
        tar -xf "$backup_path" -C "$extract_path"
    fi
}

checkAndCreateFile() {
    local file_path=$1
    if ! [ -f "$file_path" ]
    then
        #mkdir -p -- "${file_path%/*}" && touch -- "$file_path"
        echo "Create $file_path"
    fi
}

readBackupFile() {
    local user_path=$1
    local file_name=".backup"
    local file_path="${user_path}${file_name}"
    if [ -f "$file_path" ]
    then
        cd "$user_path" || exit
        while IFS= read -r line || [ -n "$line" ]
        do 
            [ -z "$line" ] && continue 
            if [ "${line:0:1}" == "." ]
            then
                checkAndCreateFile "$line"
            elif [ "${line:0:1}" == "~" ]
            then
                abs_path="${user_path}${line:2}"
                checkAndCreateFile "$abs_path"
            fi           
        done < "$file_path"
        #tar -cvf ./backup.tar.gz -T ./.backup
        #backup exits?
        #movebackup
    else
        echo "Create file"
    fi
}

getFileContent() {
    local user_name=$1
    local user_path="/home/${user_name}/"
    if [ -d "$user_path" ]
    then
        readBackupFile "$user_path"
    else
        echo "$user_name could not be found"
    fi
}

while IFS= read -r line || [ -n "$line" ]
do 
    [ -z "$line" ] && continue
    getFileContent "$line"
done < "$file_input"