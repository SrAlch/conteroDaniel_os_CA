#!/bin/bash

# GitHub repo SSH: git@github.com:SrAlch/conteroDaniel_os_CA.git
# GitHub repo HTTPS: https://github.com/SrAlch/conteroDaniel_os_CA.git

checkAndCreateFile() {
    # Checks if the given file or folder exists. If it doesn't will create a
    # file from the given path with zero lenght (assuming that no non existing
    # path is a folder) 

    local file_path
    file_path=$1
    if ! [ -e "$file_path" ]
    then
        echo -e "\t\tFile couldn't be found, creating it with zero-lenght  $file_path"
        mkdir -p -- "${file_path%/*}" && touch -- "$file_path"
    fi
}

fileCopy() {
    # With the given path for /tmp/backup tries to validate with regEx the 
    # versioning of the file on that path (filename.'version_number'). Can 
    # capture files with or without extension. Once validated copies the new 
    #formed path with the corresponding version, without changing /home/<user>

    local final_dir file_name name_part version_part num_files final_path

    file_name="$1"
    final_dir="$2"
    file_path="$3"

    if [ -e "$final_dir/$file_name" ]
    then
        if [[ "$file_name" =~ .+\.[0-9]+ ]]
        then
            name_part="$(echo "$file_name" | grep -P '.*(?=\.)' -o)"
            version_part="$(echo "$file_name" | grep -P '(?<=\.)[0-9]+' -o)"
            num_files=$(find "$final_dir" -name "$name_part*" | wc -l)
            num_files=$((++num_files))
            if (( num_files < version_part ))
            then
                final_path="$final_dir/$name_part.$version_part"
            else
                final_path="$final_dir/$name_part.$num_files"
            fi
        else
            final_path="$final_dir/$file_name.1"
        fi
        cp -f "$file_path" "$final_path"
        echo -e "\t\t$file_path copied to $final_path"
    else
        if [[ "$file_name" =~ .+\.[0-9]+ ]]
        then
            final_path="$final_dir/$file_name"
            cp -f "$file_path" "$final_path"
            echo -e "\t\t$file_path copied to $final_path"
        else
            fileCopy "$file_name.1" "$final_dir" "$file_path"
        fi
    fi
}

fileComparing() {
    # Checks if the <user> tmp folder exists, otherwise creates it
    # Compares the content of the current "/home/<user>" with the content on
    # "/tmp/backup/<user>" and increste to last version in case of existing files 

    local file_path file_dir file_name final_dir  
    local num_files final_path inside_file user_name
    user_name="$2"
    file_path="$1"

    if [ -f "$file_path" ]
    then
        file_dir=$(dirname "$file_path")
        file_name=$(basename "$file_path")
        final_dir="$EXTRACT_PATH/$user_name/${file_dir:2}"
        [ ! -e "$final_dir" ] && mkdir -p "$final_dir" && echo "Created $final_dir"
        fileCopy "$file_name" "$final_dir" "$file_path"
    elif [ -d "$file_path" ]
    then
        file_dir="$file_path"
        final_dir="$EXTRACT_PATH/$user_name/${file_dir:2}"
        [ ! -e "$final_dir" ] && mkdir -p "$final_dir" && echo "Created $final_dir"
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
            checkAndCreateFile "$user_path${raw_path:2}"
            fileComparing "$raw_path" "$user_name"         
        done < "$file_path"
    else
        touch "$file_path"
        echo -e "\t$file_name file created in $file_path"
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
        echo "Analyzing user: $user_name"
        readBackupFile "$user_path" "$user_name"
    else
        echo "$user_name user could not be found"
    fi
}

compressBackup() {
    # Compress back the backup.tr.gz file after all the operations are completed

    echo "STARTING BACKUP"
    cd "$EXTRACT_PATH" && tar -zcvf "$BACKUP_PATH" . && cd - 
    echo "File $BACKUP_PATH is being compressed"
    rm -r "$EXTRACT_PATH"
    echo "$EXTRACT_PATH is being deleted"
}

backupExtract() {
    # Cleans $EXTRACT_PATH, deleting it and creates the path for a fresh start
    # Then checks if "/var/backup.tar.gz" exists, extracting it on the given
    # location, otherwise promnts msg couldnt be found.

    rm -r "$EXTRACT_PATH"
    mkdir "$EXTRACT_PATH"
    echo "$EXTRACT_PATH Path created"

    if [ -f "$BACKUP_PATH" ]
    then
        tar -zxf "$BACKUP_PATH" -C "$EXTRACT_PATH"
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
    echo -e "\n"
done < "$file_input"

compressBackup

echo -e "\nThe backup script is completed"