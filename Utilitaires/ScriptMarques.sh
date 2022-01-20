#!/bin/sh
#
#  ScriptMarques.sh
#  ConteneurCloudKit
#
#  Created by Michel on 20/01/2022.
#
set -x
TAGS="TODO:|FIXME:"
ERRORTAG="ERROR:"
#SRCROOT="."

find "${SRCROOT}" \( -name "*.h" -or -name "*.m" -or -name "*.swift" -type f \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($TAGS).*\$|($ERRORTAG).*\$" | perl -p -e "s/($TAGS)/ warning: \$1/" | perl -p -e "s/($ERRORTAG)/ error: \$1/"
