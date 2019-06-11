#!/bin/bash
set -e

# To use a newer neo-cli version, just update this variable:
NEO_CLI_VERSION="2.10.2"
NEO_PLUGINS_VERSION="2.10.2"

DOCKER_ORG=axlabs
DOCKER_IMAGE_NAME=neo-privatenet

function usage {
    echo "Usage: $0 [--no-cache] [--neo-cli <zip-fn>]"
}

while [[ "$#" > 0 ]]; do case $1 in
    -h)
        usage
        exit 0
        ;;
    --no-cache)
        DISABLE_CACHE=1
        shift
        ;;
    --neo-cli)
        # Custom neo-cli zip filename
        NEO_CLI_CUSTOM_ZIPFN=$2
        if [[ -z $NEO_CLI_CUSTOM_ZIPFN ]]; then
            echo "Error: Please specify a neo-cli zip file"
            usage
            exit 1
        fi
        echo "Custom neo-cli zip: $NEO_CLI_CUSTOM_ZIPFN"
        shift; shift
        ;;
    *)
        usage
        exit 1
        ;;
  esac;
done

# Definition of standard neo-cli filenames and URL based on the version
NEO_CLI_ZIPFN="neo-release-${NEO_CLI_VERSION}.zip"
NEO_CLI_URL="https://github.com/neo-project/neo-cli/releases/download/v${NEO_CLI_VERSION}/neo-cli-linux-x64.zip"
NEO_PLUGIN_ZIPFN="SimplePolicy.zip"
NEO_PLUGIN_URL="https://github.com/neo-project/neo-plugins/releases/download/v${NEO_PLUGINS_VERSION}/SimplePolicy.zip"
NEO_APPLOG_ZIPFN="ApplicationLogs.zip"
NEO_APPLOG_URL="https://github.com/neo-project/neo-plugins/releases/download/v${NEO_PLUGINS_VERSION}/ApplicationLogs.zip"
NEO_RPCSYSASSETTRACKER_ZIPFN="RpcSystemAssetTracker.zip"
NEO_RPCSYSASSETTRACKER_URL="https://github.com/neo-project/neo-plugins/releases/download/v${NEO_PLUGINS_VERSION}/RpcSystemAssetTracker.zip"

if [ -z "$NEO_CLI_CUSTOM_ZIPFN" ]; then
    echo "Using downloaded neo-cli v${NEO_CLI_VERSION}"

    if [ -e "${NEO_CLI_ZIPFN}" ] && [ -z "$DISABLE_CACHE" ]
    then
        echo "- release already downloaded: ${NEO_CLI_ZIPFN}"
    else
        echo "- downloading ${NEO_CLI_URL}..."
        curl -L --output $NEO_CLI_ZIPFN $NEO_CLI_URL || (rm -f $NEO_CLI_ZIPFN && exit 1)
        curl -L --output $NEO_PLUGIN_ZIPFN $NEO_PLUGIN_URL || (rm -f $NEO_PLUGIN_ZIPFN && exit 1)
        curl -L --output $NEO_APPLOG_ZIPFN $NEO_APPLOG_URL || (rm -f $NEO_APPLOG_ZIPFN && exit 1)
	curl -L --output $NEO_RPCSYSASSETTRACKER_ZIPFN $NEO_RPCSYSASSETTRACKER_URL || (rm -f $NEO_RPCSYSASSETTRACKER_ZIPFN && exit 1)
    fi
    cp $NEO_CLI_ZIPFN ./neo-cli.zip
else
    echo "Using custom neo-cli.zip: $NEO_CLI_CUSTOM_ZIPFN"
    cp $NEO_CLI_CUSTOM_ZIPFN ./neo-cli.zip
fi

if [ -z "$DISABLE_CACHE" ]; then
  docker build -t $DOCKER_ORG/$DOCKER_IMAGE_NAME .
else
  echo "docker build no cache"
  docker build --no-cache -t $DOCKER_ORG/$DOCKER_IMAGE_NAME .
fi
