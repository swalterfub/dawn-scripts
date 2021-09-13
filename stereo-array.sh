#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -l virtual_free=10G
#$ -l h_vmem=11G
#$ -m n
#$ -p 0
#$ -pe smp 2
#$ -t 1-3163
#$ -o /home/swalter/dawnfc/out

#psfile=$1
psfile=/home/swalter/dawnfc/StereoProcessing_Remaining_2001-5164.txt

#module load Anaconda3/2020.02
#. /trinity/shared/easybuild/software/Anaconda3/2020.02/etc/profile.d/conda.sh

source /share/apps/anaconda3/etc/profile.d/conda.sh

conda activate asp

if [ ! $?SGE_TASK_ID ] ; then
  SGE_TASK_ID=2
  echo $SGE_TASK_ID
fi

line=`sed -n ${SGE_TASK_ID}p $psfile`

left=`echo $line|awk '{print $2}'`
right=`echo $line|awk '{print $3}'`
target=`echo $line|awk '{print $4}'`
orbitdir=`echo $target|awk -F/ '{print $1}'`
pair=`echo $target|awk -F/ '{print $2}'`

scratch=/scratch/swalter/${pair}
dest=/home/swalter/dawnfc/DTM/${orbitdir}
mkdir -pv $scratch ${dest}
pushd $scratch

for img in $left $right ; do
cp -pv /share/hrsc-mos/Occator_F1_LAMO_lev2c/$img .
editlab from=$img options=modkey grpname=Kernels keyword=ShapeModel value=/home/swalter/dawnfc/CE_HAMO_G_00N_180E_EQU_DTM_SpiceReady.cub
editlab from=$img options=modkey grpname=Kernels keyword=Extra value=/home/swalter/dawnfc/dawn_ceres_SPG20160107.tpc
editlab from=$img options=modkey grpname=Kernels keyword=Instrument value=/home/swalter/dawnfc/dawn_fc_v10.ti
done

#mkdir -p $orbit

time stereo --threads 2 $left $right ${pair} -s /home/swalter/dawnfc/stereo_21.map
rm -rfv $left $right
mv -v * ${dest}

popd
rm -rf $scratch

