SELF=$(dirname "$(realpath $0)")
PRETRAIN="$SELF/../pretrain_model"
CKPT="$SELF/../checkpoints"
VLBERT_CKPT="$CKPT/vl-bert"
DATA="$SELF/../data"

mkdir -p "$VLBERT_CKPT"
docker run --gpus all \
    -v "$SELF":/src \
    dsfhe49854/vl-bert \
    sh /src/scripts/init.sh

MODEL_NAME_LIST=("vl-bert-base-v4" "vl-bert-large-v4" "vl-bert-large-v5-race")
CONFIG_NAME_LIST=("base_4x14G_fp32_k8s_v4" "large_4x14G_fp32_k8s_v4" "large_4x14G_fp32_k8s_v5_race")
CKPT_NAME_LIST=("vl-bert_base_res101_cls_test_ckpt_MEME.model" "vl-bert_large_res101_cls_test_ckpt_MEME.model" "vl-bert_large_res101_cls_test_ckpt_MEME.model")

for index in ${!MODEL_NAME_LIST[*]}; do 
    MODEL_NAME="${MODEL_NAME_LIST[$index]}"
    CONFIG_NAME="${CONFIG_NAME_LIST[$index]}"
    CKPT_NAME="${CKPT_NAME_LIST[$index]}"
    echo "[$MODEL_NAME] & [$CONFIG_NAME] --> [$CKPT_NAME]"

    if [ -e "$VLBERT_CKPT/$MODEL_NAME/$CKPT_NAME" ]; then
        echo "************  [TEST] $MODEL_NAME  ************"
        docker run --gpus all \
            --shm-size 4G \
            -v $SELF:/src \
            -v $PRETRAIN:/pretrain_model \
            -v $VLBERT_CKPT:/checkpoints \
            -v $DATA:/data \
            dsfhe49854/vl-bert \
            python3 /src/cls/test.py \
            --cfg "/src/cfgs/cls/$CONFIG_NAME.yaml" \
            --ckpt "/checkpoints/$MODEL_NAME/$CKPT_NAME" \
            --result-path "/checkpoints/$MODEL_NAME"
    else
        echo "Checkpoint not found: $VLBERT_CKPT/$MODEL_NAME/$CKPT_NAME"
    fi;

done;