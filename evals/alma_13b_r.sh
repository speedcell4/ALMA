OUTPUT_DIR=${1:-"./outputs-alma-13b-r/"}
TEST_PAIRS=${2:-"de-en,cs-en,is-en,zh-en,ru-en,en-de,en-cs,en-is,en-zh,en-ru"}
export HF_DATASETS_CACHE=".cache/huggingface_cache/datasets"
export TRANSFORMERS_CACHE=".cache/models/"
# random port between 30000 and 50000
port=$((RANDOM % (50000 - 30000 + 1) + 30000))

python \
  run_llmmt.py \
  --model_name_or_path haoranxu/ALMA-13B-R \
  --do_predict \
  --low_cpu_mem_usage \
  --language_pairs ${TEST_PAIRS} \
  --mmt_data_path ./human_written_data/ \
  --per_device_eval_batch_size 4 \
  --output_dir ${OUTPUT_DIR} \
  --predict_with_generate \
  --max_new_tokens 256 \
  --max_source_length 256 \
  --bf16 \
  --seed 42 \
  --num_beams 5 \
  --overwrite_cache \
  --overwrite_output_dir \
  --multi_gpu_one_model

if [[ ${TEST_PAIRS} == *zh-en* ]]; then
  python \
    run_llmmt.py \
    --model_name_or_path haoranxu/ALMA-13B-R \
    --do_predict \
    --low_cpu_mem_usage \
    --language_pairs zh-en \
    --mmt_data_path ./human_written_data/ \
    --per_device_eval_batch_size 4 \
    --output_dir ${OUTPUT_DIR} \
    --predict_with_generate \
    --max_new_tokens 256 \
    --max_source_length 512 \
    --bf16 \
    --seed 42 \
    --num_beams 5 \
    --overwrite_cache \
    --overwrite_output_dir \
    --multi_gpu_one_model
fi

## Evaluation (BLEU, COMET)
bash ./evals/eval_generation.sh ${OUTPUT_DIR} ${TEST_PAIRS}
