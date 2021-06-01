#!/bin/sh

help()
{
	echo "for mets analysis"
	echo ""
	echo ""
	echo "Usage:: >> sh mets_stats.sh <options>"
	echo ""
	echo "Input Argument Options"
	echo ""
	echo "(1) -m filename.nii.gz"
	echo "		: (compulsory) Binary mets mask file (NIfTI file format)"
	echo "(2) -o <string>"
	echo "		: (optional)It will be the prefix of the outputs generated in this process"
	echo "(3) -r filename.nii.gz"
	echo "		: (optional) ROI file (NIfTI file format). When \$roi file is specified, all the outputs (volume, and counting) were estimated in the ROI "
	echo ""
	echo ""
}
if [ $# -eq 0 ]; then help ; exit 1 ; fi
###===Input Argument Setting===###
optconfig="m:o:r:"
while getopts "$optconfig" opt ;do
	case $opt in
		m) mets=${OPTARG};;
		o) prefix=${OPTARG};;
		r) roi=${OPTARG};;
		*)
			echo "Unknown option argument : "$OPTARG; help
			exit 1
		;;
	esac
done
###===Default Initialization===###
if [ -z ${mets} ] ;then help ; exit 1 ;fi
if [ -z ${prefix} ] ;then prefix=$(remove_ext ${mets}) ;fi
if [ -z ${roi} ] ;then 
	roitag="no"
else 
	roitag="yes"
fi

##== centerization ==##
# output will be saved as : ${pwd}/${prefix}_centroids.nii.gz
python3 extract_cog.py $mets $prefix
center=`ls -1 ${prefix}_centroids.nii.gz`

##== counting, volume ==##
# considering the whole brain mets
if [ $roitag = "no" ];then
	# 1. counting 
	tmp=`fslstats $center -V` 
	tmp=($tmp) ; num_mets=${tmp[0]}
	
	# 2. volume
	tmp=`fslstats $mets -V` 
	tmp=($tmp) ; vox_mets=${tmp[0]} ; vol_mets=${tmp[1]}
	
# for mets where in the specified ROI
elif [ $roitag = "yes" ];then
	# 1. counting 
	tmp=`fslstats $center -k $roi -V` 
	tmp=($tmp) ; num_mets=${tmp[0]}
	
	# 2. volume
	tmp=`fslstats $mets -k $roi -V` 
	tmp=($tmp) ; vox_mets=${tmp[0]} ; vol_mets=${tmp[1]}

fi

echo "#ofMets	#ofVoxels	volume(mm3)" > ${prefix}_stats.txt
echo -n $num_mets"	"${vox_mets}"	"${vol_mets} >> ${prefix}_stats.txt

