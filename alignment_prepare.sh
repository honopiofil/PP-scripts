#!/bin/bash
if [ $# -ne 2 ] ; then
  echo "This script prepares dirs and files for alignment."
  echo "It should be executed from inside of the set's alignment dir."
  echo "Usage alignment_prepare.sh [path to audio dir] [path to data zip]"
  exit 1;
fi

audio=$1
datazip=$2
dir=pwd

datadir=$(basename $datazip | tr -d '.zip')
echo "Set name:" $datadir

datafiles=kaldi/data/$datadir

echo "Copying kaldi tools..."
cp -r /exp/Exported/kaldi_dir_ready_to_use kaldi

echo "Linking audio files..."
ln -sf $audio audio

echo "Extracting data files from $datazip..."
unzip $datazip

mkdir audio_mono
echo "Spliting audio stereo into mono files..."
split_audio.sh audio audio_mono

# TODO check if audio_mono and datadir have corresponding files

mkdir $datafiles
echo "Executing cleanup_export.py..."
cleanup_export.py $datadir audio_mono $datafiles

export LC_ALL=C
cp $datadir/utt2role $datafiles/
kaldi/utils/utt2spk_to_spk2utt.pl $datafiles/utt2spk > $datafiles/spk2utt

echo ""
echo "Done alignment preparation for $datadir"

echo ""
echo "************************** BEGIN EVALUATION *******************************"

echo ""
audiono=$(ls audio | wc -l)
monono=$(ls audio_mono | wc -l)
wavscpno=$(cat $datafiles/wav.scp | wc -l)
echo "Total number of:"
echo "  stereo files / mono files / files in wav.scp:"
echo "       $audiono     /     $monono    /       $wavscpno    "

echo ""
nowono=$(grep "[^a-zA-ZąĄćĆęĘłŁńŃóÓśŚżŻźŹ'.,_:\;~?\!-]" $datafiles/word.list | wc -l)
echo "Total number of no-words in word.list: $nowono - for example:"
grep "[^a-zA-ZąĄćĆęĘłŁńŃóÓśŚżŻźŹ'.,_:\;~?\!-]" $datafiles/word.list | head

echo ""
echo "Total number of speakers with UNK role: $(grep UNK $datafiles/utt2role | cut -d' ' -f1 | sort | uniq | wc -l)"

echo ""

# TODO segments evaluation

echo "*************************** END EVALUATION ********************************"
echo ""
exit 0;
