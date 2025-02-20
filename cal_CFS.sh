#!/bin/bash
######Compile programs###################################
cd ../CFSsrc/src
make
make clean
cp CoulombStressAnalysis  ../../grid
#
cd ../computeCFS
make
make clean
cp computeCFS ../../grid
cd ../../grid
#
source_fault=$1
sampling_file=$2
strike_receiver=$3
dip_receiver=$4
rake_receiver=$5
friction=$6
Skempton=$7
meridian=$8
output_dir=$9

# 创建输出目录
mkdir -p "$output_dir"

cp $sampling_file samplingpoints.in
echo -e "\033[31m----processing ...---\033[0m"
naltermode_receiver=0
#note when naltermode_receiver=1 the following receiver fault is merely used for compatable reading format of the 'CoulombAnalysis' program. The real receiver fault will be read from the sampling file that is saved in the filefolder 'grid'.
cp  $source_fault  slipmodel.in
./CoulombStressAnalysis ${naltermode_receiver} ${strike_receiver} ${dip_receiver} ${rake_receiver} ${friction} ${Skempton} ${meridian}
mv stress.out "${output_dir}"
mv coulomb.out  "${output_dir}/coulomb.out"
rm -rf slipmodel.in samplingpoints.in