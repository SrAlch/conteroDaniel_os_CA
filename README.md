# conteroDaniel_os_CA.sh

Class assignment from DBS (Dublin Business School) for Operating Systems and Networks module.


### Assignment briefing:
> Create a bash script, which takes as an argument, a filename where the file  contains a list of usernames, and backs up the users home directories as follows:
Each home directory contains a file named .backup, with the files to be backed up (relative paths from home directory) one per line. If the file .backup is not present, it should be created as zero-length.
The file /var/backup.tar.gz, if existing, should be extracted to /tmp/backup.
Each relevant file in /home/<user> should be compared with those in the /tmp/backup/<user> directory with the same name, and if different, the previous version must be renamed and replaced. If filename.1 exists, filename should be renamed to filename.2 or 3 etc. and the file copied from the home directory. 
At the end the backup should be zipped up tar with gzip compression to /var/backup.tar.gz

### Tools used:

```sh
Visual Studio Code
Remote - SSH (extension)
ShellCheck (extension)
Azure vmMachine (ubuntu 20.04)
```

### Resources used:

- [StackOverflow](https://stackoverflow.com/)
- [Cyberciti](https://www.cyberciti.biz/)
- [Linuxize](https://linuxize.com/)
- [RegexLand](https://regexland.com/)
- [Microsoft Docs](https://docs.microsoft.com/en-us/)
- [GNU Bash Manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
- [The Linux Documentation Project](https://tldp.org/LDP/Bash-Beginners-Guide/html/index.html)
- [DevConnected](https://devconnected.com/)
- [Ubuntu Stack Exchange](https://askubuntu.com/)
- [TecAdmin](https://tecadmin.net/)
- [LinuxHint](https://linuxhint.com/)
- [Freecodecamp](https://www.freecodecamp.org/)
- [UNIX Stack Exchange](https://unix.stackexchange.com/)
- [Linux Die](https://linux.die.net/)
