#!/bin/bash

# we assume that the binaries are in the same folder as the script
DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

I=${1:-""}
F=${2:-1}
L=${3:-1}
O=${4:-""}
S=${5:-1}

for i in `seq $F $L`;
do
	$DIR/dctdenoising $S `printf $I $i` `printf $O $i` -n 1; 
done
