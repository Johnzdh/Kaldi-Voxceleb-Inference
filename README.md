# Kaldi-Voxceleb-Inference

This motivation is to help peple get the inference result of speaker verification quickly.



## Pipeline

### step1. Choose you own dataset and upload it

For me, I choose the Peppa-pig dataset and upload it to the directory "datasetPeppa"

### step2. Download pretrained-model of voxceleb

[From here](https://github.com/a-nagrani/VGGVox).

### step3.Generate trails for the preparation of PLDA scoring

The reference script is [here](https://github.com/kaldi-asr/kaldi/blob/master/egs/aishell/v1/local/produce_trials.py). It's very useful.

### step4. Run the inference script which modified from the training script

The script located at "./run.sh"



## License

MIT licensed, as found in the [LICENSE](https://github.com/Johnzdh/Kaldi-Voxceleb-Inference/blob/master/LICENSE) file.