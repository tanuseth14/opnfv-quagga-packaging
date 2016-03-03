#! /bin/sh
##
## Copyright (c) Ericsson LMC, 2013.
##
## All Rights Reserved. Reproduction in whole or in part is prohibited
## without the written consent of the copyright owner.
##
## ERICSSON MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
## SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
## BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ERICSSON
## SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A
## RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS
## DERIVATIVES.
##
##


# This script is executed as an installation campaign init action.
# sdp name is passed as first argument
SDP_NAME=$1
LOGFILE=/tmp/javaoam_model_install.log

#-----------------------------------------------------------------
# Function to execute any passed command
#-----------------------------------------------------------------
execute_cmd () {
    if [ $# -eq 0 ]
    then
        echo "Usage: $0 cmd [parameters list] "
        exit 1
    fi

    tmp=`$*`

    if [ $? -ne 0 ]
    then
        echo "Failed to execute: $*" >> $LOGFILE 2>&1
        exit 1
    fi
}

echo "Uninstall IMM: $*" >> $LOGFILE 2>&1

execute_cmd cmw-model-delete ${SDP_NAME} --mt imm
execute_cmd comsa-mim-tool remove ${SDP_NAME}
execute_cmd comsa-mim-tool commit ${SDP_NAME}
execute_cmd comsa-mim-tool com_switchover
execute_cmd cmw-model-done

exit 0
