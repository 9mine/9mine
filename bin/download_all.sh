#!/bin/sh

bin/nodes_by_country_flow.sh | sed -r 's/ \([0-9]+\)//' | grep -v 'n/a' | xargs -tI% bin/download_flag.sh %
