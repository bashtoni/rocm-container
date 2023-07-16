# text-generation-webui navi31 ROCm container

After trying and failing to get all the various ROCm bits configured on my Fedora 38 system,
I decided to build a container that will let me do it instead.

## Build

```bash
podman build -t arch-rocm .
```

## Use

```bash
export MODELS_DIR=${HOME}/models # directory where you have downloaded all your models
podman run \
        --rm \
        -v ${MODELS_DIR}:/app/text-generation-webui/models:Z \
        -p 7860:7860 \
        -it \
        --privileged \
        --device=/dev/kfd \
        --device=/dev/dri \
        --group-add video \
        arch-rocm
```

Connect to http://localhost:7860/


## Test machine

 - Radeon 7900XT
 - Fedora 38

## Models tried

 - alpaca-13b-lora-int4
 - vicuna-7b-1.1
 - WizardLM-33B-V1.0-Uncensored-GPTQ

## Includes

 - [ROCm specific bitsandbytes library](https://github.com/agrocylo/bitsandbytes-rocm)
 - [ROCm modified GPTQ-for-LLaMa](https://github.com/WapaMario63/GPTQ-for-LLaMa-ROCm)
 - exllama
