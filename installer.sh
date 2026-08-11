#!/usr/bin/env bash
#
# Simple installer for protonvpn-random
#
# To install protonvpn-random:
#	   curl https://raw.githubusercontent.com/tuiroot/protonvpn-random/main/installer.sh | bash
#

set -uo pipefail

readonly REPOSITORY='tuiroot'
readonly BRANCH='main'
readonly PACKAGE_FILE='protonvpn-random'
#readonly CONFIG_FILE='protonvpn-random.conf' # Uncomment if config file is implemented, don't forget to add key and value to $DOWNLOADED_FILES array
readonly LICENSE_FILE='LICENSE'
readonly README_FILE='README.md'
readonly USAGE_FILE='USAGE.md'
readonly DIR_EXE='/usr/local/bin'
#readonly DIR_ETC='/usr/local/etc||~/.config' # Uncomment if config file is implemented and select directory
readonly DIR_DOC="/usr/share/doc/$PACKAGE_FILE"
readonly DOWNLOAD_REPOSITORY="https://raw.githubusercontent.com/$REPOSITORY/$PACKAGE_FILE/$BRANCH"
readonly -A DOWNLOADED_FILES=(["$PACKAGE_FILE"]="$DIR_EXE" ["$LICENSE_FILE"]="$DIR_DOC" ["$README_FILE"]="$DIR_DOC" ["$USAGE_FILE"]="$DIR_DOC")
readonly TMP_DIR=$(mktemp -d)

function cleanup() {
    local exitStatus="$?"
    cd "$OLDPWD"
    rmdir "$TMP_DIR" &>/dev/null
    if [[ "$exitStatus" -ne 0 ]]; then
        echo "Installation of $PACKAGE_FILE failed with rc $exitStatus"
    else
        echo "$PACKAGE_FILE successfully installed"
        echo '---------------------------------------------------------'
        echo -e 'Script location:        /usr/local/sbin/protonvpn-random'
        # echo -e 'Config file locattion: /usr/local/etc/protonvpn-random.conf||~/.config/protonvpn-random.conf' # Choose directory if implementing
        echo -e 'README location:        /usr/share/doc/protonvpn-random/README.md'
        echo -e 'LICENSE location:       /usr/share/doc/protonvpn-random/LICENSE'
        echo 'For help: protonvpn-random -h'
        echo 'Thank you for using protonvpn-random!'
    fi
    exit $exitStatus
}

trap "cleanup" SIGINT SIGTERM EXIT
cd $TMP_DIR

# Use sudo to ask for password before starting installation
sudo echo "Installing ${PACKAGE_FILE}..."

for file in "${!DOWNLOADED_FILES[@]}"; do

    sourceFile="$file"
    targetDir="${DOWNLOADED_FILES[$file]}"

    echo "Downloading $sourceFile from ${DOWNLOAD_REPOSITORY}/${sourceFile}..."
    http_code=$(curl -w "%{http_code}" -L -s ${DOWNLOAD_REPOSITORY}/$sourceFile -o $sourceFile)
    (( $? )) && { echo "Curl failed"; exit 1; }
    [[ $http_code != 200 ]] && { echo "http request failed with $http_code"; exit 1; }

    echo "Installing $sourceFile into ${targetDir}..."

    # Existing execution bit in github is not reflected by curl
    if [[ "$sourceFile" == "$PACKAGE_FILE" ]]; then
        chmod +x "$sourceFile"
        (( $? )) && { echo "chmod of $sourceFile failed"; exit 1; }
        # You can use below if you want to have different paths for things in the script depending of installation method since curl will install in specified directories
        # Add variable INSTALL_METHOD in protonvpn-random, this will change the value of that variable to 'curl'
        # sudo sed --follow-symlinks -i -E "s/^(INSTALL_METHOD)=.+$/\1=\'curl\'/" "$sourceFile"
        # (( $? )) && { echo "sed of $sourceFile failed"; exit 1; }
        sudo mv "$sourceFile" "$targetDir"
        (( $? )) && { echo "mv of $sourceFile failed"; exit 1; }

    # Files in document directory
    elif [[ "$sourceFile" == "$LICENSE_FILE" || "$sourceFile" == "$README_FILE" || "$sourceFile" == "$USAGE_FILE" ]]; then
        if [[ ! -d "$DIR_DOC" ]]; then
            sudo mkdir -p "$DIR_DOC"
            (( $? )) && { echo "mkdir of $DIR_DOC failed"; exit 1; }
        fi
        sudo mv "$sourceFile" "$targetDir"
        (( $? )) && { echo "mv of $sourceFile failed"; exit 1; }

    # Config file
    # Uncomment if config file is implemented, don't forget to add key and value to $DOWNLOADED_FILES array
    # elif [[ "$sourceFile" == "$CONFIG_FILE" ]]; then
    #     if [ -f ${DIR_ETC}/$CONFIG_FILE ]; then
    #         echo 'WARNING!'
    #         echo "${DIR_ETC}/$CONFIG_FILE already exists!"
    #         while true; do
    #             read -n 1 -r -p '!! Do you want to overwrite? [y/n] ' input < /dev/tty
    #             case $input in
    #                 [Yy]) echo -e '\nOverwriting config file...'; mv "$sourceFile" "$targetDir"; break;;
    #                 [Nn]) echo -e '\nKeeping old config file...'; rm "$sourceFile"; break;;
    #                 *) echo -e "\nERROR! Please enter 'y/Y' or 'n/N'";;
    #             esac
    #         done
    #     else
    #         mv "$sourceFile" "$targetDir"
    #         (( $? )) && { echo "mv of $sourceFile failed"; exit 1; }
    #     fi
    fi
done

exit 0
