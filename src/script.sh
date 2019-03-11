#!/bin/bash
input=$1
first=$2
last=$3
sigma=$4
out=$5

#TODO add this parameters to the list of possible parameters
wx=15
px=8
np=64
rank=16
a=0.9
occ=2.3

# we assume that the binaries are in the same folder as the script
DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

mkdir -p $out

# Generate the noisy data
$DIR/nlkalman -i $input -nisy $out/nisy-%04d.tiff -f $first -l $last -sigma $sigma -px 0 

# Compute the optical flow (using the noisy data)
$DIR/tvl1flow.sh $out/nisy-%04d.tiff $first $last $out/fflo-%04d.flo

# Apply NL-Kalman
$DIR/nlkalman -i $out/nisy-%04d.tiff -f $first -l $last -sigma $sigma \
	-of $out/fflo-%04d.flo -wx $wx -px $px -np $np -r $rank -a $a -occ $occ -add_noise false \
	-deno $out/deno-%04d.tiff -sub $out/dsub-%04d.tiff 

# Apply DCTdenoising as post-processing on the regular and the subpixelic results
$DIR/dct.sh $out/deno-%04d.tiff $first $last $out/dct-deno-%04d.tiff 3 
$DIR/dct.sh $out/dsub-%04d.tiff $first $last $out/dct-dsub-%04d.tiff 3 

# deno : frame-by-frame psnr {{{1
for i in $(seq $first $last);
do
	echo psnr.sh $(printf $input $i) $(printf $out/"deno-%04d.tiff" $i) m 0 2>/dev/null
	MM[$i]=$(psnr.sh $(printf $input $i) $(printf $out/"deno-%04d.tiff" $i) m 0 2>/dev/null)
	MM[$i]=$(plambda -c "${MM[$i]} sqrt" 2>/dev/null)
	PP[$i]=$(plambda -c "255 ${MM[$i]} / log10 20 *" 2>/dev/null)
done

echo "DENO Frame RMSE " ${MM[*]}  > $out/measures
echo "DENO Frame PSNR " ${PP[*]} >> $out/measures

SS=0
n=0
for i in $(seq $((first+0)) $last);
do
	SS=$(plambda -c "${MM[$i]} 2 ^ $n $SS * + $((n+1)) /" 2>/dev/null)
	n=$((n+1))
done

MSE=$SS
RMSE=$(plambda -c "$SS sqrt" 2>/dev/null)
PSNR=$(plambda -c "255 $RMSE / log10 20 *" 2>/dev/null)
echo "DENO Total RMSE $RMSE" >> $out/measures
echo "DENO Total PSNR $PSNR" >> $out/measures

# dct-deno : frame-by-frame psnr {{{1
for i in $(seq $first $last);
do
	MM[$i]=$(psnr.sh $(printf $input $i) $(printf $out/"dct-deno-%04d.tiff" $i) m 0 2>/dev/null)
	MM[$i]=$(plambda -c "${MM[$i]} sqrt" 2>/dev/null)
	PP[$i]=$(plambda -c "255 ${MM[$i]} / log10 20 *" 2>/dev/null)
done

echo "DCTDENO Frame RMSE " ${MM[*]} >> $out/measures
echo "DCTDENO Frame PSNR " ${PP[*]} >> $out/measures

SS=0
n=0
for i in $(seq $((first+0)) $last);
do
	SS=$(plambda -c "${MM[$i]} 2 ^ $n $SS * + $((n+1)) /" 2>/dev/null)
	n=$((n+1))
done

MSE=$SS
RMSE=$(plambda -c "$SS sqrt" 2>/dev/null)
PSNR=$(plambda -c "255 $RMSE / log10 20 *" 2>/dev/null)
echo "DCTDENO Total RMSE $RMSE" >> $out/measures
echo "DCTDENO Total PSNR $PSNR" >> $out/measures

# dsub : frame-by-frame psnr {{{1
for i in $(seq $first $last);
do
	MM[$i]=$(psnr.sh $(printf $input $i) $(printf $out/"dsub-%04d.tiff" $i) m 0 2>/dev/null)
	MM[$i]=$(plambda -c "${MM[$i]} sqrt" 2>/dev/null)
	PP[$i]=$(plambda -c "255 ${MM[$i]} / log10 20 *" 2>/dev/null)
done

echo "DSUB Frame RMSE " ${MM[*]} >> $out/measures
echo "DSUB Frame PSNR " ${PP[*]} >> $out/measures

SS=0
n=0
for i in $(seq $((first+0)) $last);
do
	SS=$(plambda -c "${MM[$i]} 2 ^ $n $SS * + $((n+1)) /" 2>/dev/null)
	n=$((n+1))
done

MSE=$SS
RMSE=$(plambda -c "$SS sqrt" 2>/dev/null)
PSNR=$(plambda -c "255 $RMSE / log10 20 *" 2>/dev/null)
echo "DSUB Total RMSE $RMSE" >> $out/measures
echo "DSUB Total PSNR $PSNR" >> $out/measures

# dct-dsub : frame-by-frame psnr {{{1
for i in $(seq $first $last);
do
	MM[$i]=$(psnr.sh $(printf $input $i) $(printf $out/"dct-dsub-%04d.tiff" $i) m 0 2>/dev/null)
	MM[$i]=$(plambda -c "${MM[$i]} sqrt" 2>/dev/null)
	PP[$i]=$(plambda -c "255 ${MM[$i]} / log10 20 *" 2>/dev/null)
done

echo "DCTDSUB Frame RMSE " ${MM[*]} >> $out/measures
echo "DCTDSUB Frame PSNR " ${PP[*]} >> $out/measures

SS=0
n=0
for i in $(seq $((first+0)) $last);
do
	SS=$(plambda -c "${MM[$i]} 2 ^ $n $SS * + $((n+1)) /" 2>/dev/null)
	n=$((n+1))
done

MSE=$SS
RMSE=$(plambda -c "$SS sqrt" 2>/dev/null)
PSNR=$(plambda -c "255 $RMSE / log10 20 *" 2>/dev/null)
echo "DCTDSUB Total RMSE $RMSE" >> $out/measures
echo "DCTDSUB Total PSNR $PSNR" >> $out/measures

# vim:set foldmethod=marker:
