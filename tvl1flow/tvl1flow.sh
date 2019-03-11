#!/bin/bash
# Computes tvl1 optical flow for a (noisy) sequence. 

I=${1:-""}
F=${2:-1}
L=${3:-1}
O=${4:-""}

# we assume that the binaries are in the same folder as the script
DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

for i in `seq $F $(($L - 1))`;
do
	$DIR/tvl1flow `printf $I $i` \
        `printf $I $((i+1))` \
		   `printf $O $i` \
		   4 0.25 0.2 0.3 100 2 0.5 5 0.01 0; 
done
