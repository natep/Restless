#!/bin/bash

#  generate.sh
#  WebServiceProtocol
#
#  Created by Nate Petersen on 8/27/15.
#  Copyright (c) 2015 Digital Rickshaw. All rights reserved.

# TODO: this could probably be folded into the Perl script

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

protoRegex="@protocol ([a-zA-Z0-9]*) <DRWebService>"

for i in `find "${SRCROOT}" -name *.h` ; do
	contents=$(<${i})

	if [[ ${contents} =~ $protoRegex ]]; then
		echo "${i} matches"
		echo "Protocol name: ${BASH_REMATCH[1]}"

		perl ${DIR}/proto_parse.pl "${i}" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
	fi
done

echo "Web service generation finished"