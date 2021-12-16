#!/bin/bash

# GitHub repo SSH: git@github.com:SrAlch/conteroDaniel_os_CA.git
# GitHub repo HTTPS: https://github.com/SrAlch/conteroDaniel_os_CA.git

checkAndCreateFile() {
    # Checks if the given file or folder exists. If it doesn't will create a
    # file from the given path with zero lenght (assuming that no non existing
    # path is a folder) 

    local file_path
    file_path=$1
    if ! [ -f "$file_path" ]
    then
        echo -e "       File couldn't be found, creating it with zero-lenght  $file_path"
        #mkdir -p -- "${file_path%/*}" && touch -- "$file_path"
        
    else
        echo -e "       This file already exist  $file_path"
    fi
}

fileCopy() {
    # With the given path for /tmp/backup tries to validate with regEx the 
    # versioning of the file on that path (filename.'version_number'). Can 
    # capture files with or without extension. Once validated copies the new 
    #formed path with the corresponding version, without changing /home/<user>

    local final_dir file_name name_part version_part num_files final_path

    if [ -f "$final_dir/$file_name" ]
    then
        if [[ "$file_name" =~ .+\.[0-9]+ ]]
        then
            name_part="$(echo "$file_name" | grep -P '.*(?=\.)' -o)"
            version_part="$(echo "$file_name" | grep -P '(?<=\.)[0-9]+' -o)"
            num_files=$(find "$final_dir" -name "$name_part*" | wc -l)
            num_files=$((++num_files))
            if (( num_files > version_part ))
            then
                final_path="$final_dir/$name_part.$num_files"
            fi
        else
            final_path="$final_dir/$file_name.1"
        fi
    else
        if [[ "$file_name" =~ .+\.[0-9]+ ]]
        then
            final_path="$final_dir/$file_name"
        else
            final_path="$final_dir/$file_name.1"
        fi
    fi
    #cp "$file_path" "$final_path"
    echo "$file_path copied to $final_path"
    
}

fileComparing() {
    # Checks if the <user> tmp folder exists, otherwise creates it
    # Compares the content of the current "/home/<user>" with the content on
    # "/tmp/backup/<user>" and increste to last version in case of existing files 

    local file_path file_dir file_name final_dir  
    local num_files final_path inside_file user_name
    file_path="$1"
    user_name="$2"
    if [ -f "$file_path" ]
    then
        file_dir=$(dirname "$file_path")
        file_name=$(basename "$file_path")
        final_dir="$EXTRACT_PATH/$user_name/${file_dir:2}"
        #[ ! -e "$final_dir" ] && mkdir -p "$final_dir" && echo "Created $final_dir"
        fileCopy 
    elif [ -d "$file_path" ]
    then
        file_dir="$file_path"
        final_dir="$EXTRACT_PATH/$user_name/${file_dir:2}"
        #[ ! -e "$final_dir" ] && mkdir -p "$final_dir" && echo "Created $final_dir"
        for inside_file in "$file_path"/*
        do
            fileComparing "$inside_file" "$user_name"
        done
    else
        echo "There is an error with $file_path"
    fi
}

readBackupFile() {
    # Checks if ".backup" file exists for the given user if not, creates file 
    # with zero lenght. If the file exists reads each line inside it cleaning
    # paths.

    local user_path user_name file_name file_path raw_path
    user_path=$1
    user_name=$2
    file_name=".backup"
    file_path="${user_path}${file_name}"
    if [ -f "$file_path" ]
    then
        echo -e "   $file_name file found in $file_path"
        cd "$user_path" || exit
        while IFS= read -r line || [ -n "$line" ]
        do 
            [ -z "$line" ] && continue
            if [ "${line:0:1}" == "." ]
            then
                raw_path="$line"
            elif [ "${line:0:1}" == "~" ]
            then
                raw_path=".${line:2}"
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

    local user_name user_path
    user_name=$1
    user_path="/home/${user_name}/"
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
    echo "File $BACKUP_PATH is being compressed"
}

backupExtract() {
    # Checks if "/tmp/backup" exists (extraction path given) and creates the path
    # if doesn't exist. Then checks if "/var/backup.tar.gz" exists, extracting 
    # it on the given location, otherwise promnts msg couldnt be found.

    if ! [ -d "$EXTRACT_PATH" ]
    then
        #mkdir "$extract_path"
        echo "$EXTRACT_PATH Path created"
    fi

    if [ -f "$BACKUP_PATH" ]
    then
        #tar -zxf "$backup_path" -C "$extract_path"
        echo "$BACKUP_PATH is being extracted in $EXTRACT_PATH"
    else
        echo "$BACKUP_PATH couldn't be found"
    fi
}

BACKUP_PATH="/var/backup.tar.gz"
EXTRACT_PATH="/tmp/backup"
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