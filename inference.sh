#!/usr/bin/env bash
# Copyright   2017   Johns Hopkins University (Author: Daniel Garcia-Romero)
#             2017   Johns Hopkins University (Author: Daniel Povey)
#        2017-2018   David Snyder
#             2018   Ewald Enzinger
# Apache 2.0.
#
# See ../README.txt for more info on data required.
# Results (mostly equal error-rates) are inline in comments below.

. ./cmd.sh
. ./path.sh
set -e
mfccdir=`pwd`/mfcc/peppa
vaddir=`pwd`/mfcc/peppa


# The trials file is downloaded by local/make_voxceleb1_v2.pl.
peppa_trials=datasetPeppa/peppa_trials
peppa_root=datasetPeppa
nnet_dir=/home/0007_voxceleb_v2_1a/exp/xvector_nnet_1a

stage=3

if [ $stage -le 0 ]; then
  make_peppa.pl $peppa_root test data/peppa
fi

if [ $stage -le 1 ]; then
  # Make MFCCs and compute the energy-based VAD for each dataset
  for name in peppa; do
    steps/make_mfcc.sh --write-utt2num-frames true --mfcc-config mfcc.conf --nj 4 --cmd "$train_cmd" \
      data/${name} exp/make_mfcc $mfccdir
    utils/fix_data_dir.sh data/${name}
    sid/compute_vad_decision.sh --nj 4 --cmd "$train_cmd" \
      data/${name} exp/make_vad $vaddir
    utils/fix_data_dir.sh data/${name}
  done
fi

if [ $stage -le 2 ]; then
  sid/nnet3/xvector/extract_xvectors.sh --cmd "$train_cmd --mem 4G" --nj 4 \
    $nnet_dir data/peppa\
    $nnet_dir/xvectors_peppa
fi

if [ $stage -le 3 ]; then
  $train_cmd exp/scores/log/peppa_test_scoring.log \
    ivector-plda-scoring --normalize-length=true \
    "ivector-copy-plda --smoothing=0.0 $nnet_dir/xvectors_train/plda - |" \
    "ark:ivector-subtract-global-mean $nnet_dir/xvectors_train/mean.vec scp:$nnet_dir/xvectors_peppa/xvector.scp ark:- | transform-vec $nnet_dir/xvectors_train/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "ark:ivector-subtract-global-mean $nnet_dir/xvectors_train/mean.vec scp:$nnet_dir/xvectors_peppa/xvector.scp ark:- | transform-vec $nnet_dir/xvectors_train/transform.mat ark:- ark:- | ivector-normalize-length ark:- ark:- |" \
    "cat '$peppa_trials' | cut -d\  --fields=1,2 |" exp/scores_peppa_test|| exit 1;
fi



#if [ $stage -le 12 ]; then
#  eer=`compute-eer <(local/prepare_for_eer.py $voxceleb1_trials exp/scores_voxceleb1_test) 2> /dev/null`
#  mindcf1=`sid/compute_min_dcf.py --p-target 0.01 exp/scores_voxceleb1_test $voxceleb1_trials 2> /dev/null`
#  mindcf2=`sid/compute_min_dcf.py --p-target 0.001 exp/scores_voxceleb1_test $voxceleb1_trials 2> /dev/null`
#  echo "EER: $eer%"
#  echo "minDCF(p-target=0.01): $mindcf1"
#  echo "minDCF(p-target=0.001): $mindcf2"
#  # EER: 3.128%
#  # minDCF(p-target=0.01): 0.3258
#  # minDCF(p-target=0.001): 0.5003
#  #
#  # For reference, here's the ivector system from ../v1:
#  # EER: 5.329%
#  # minDCF(p-target=0.01): 0.4933
#  # minDCF(p-target=0.001): 0.6168
#fi
