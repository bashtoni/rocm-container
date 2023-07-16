FROM archlinux:base
# Enable testing repositories
RUN sed -i "/\[core-testing\]/,/Include/"'s/^#//' /etc/pacman.conf && \
    sed -i "/\[extra-testing\]/,/Include/"'s/^#//' /etc/pacman.conf && \
    sed -i "/\[community-testing\]/,/Include/"'s/^#//' /etc/pacman.conf && \
    sed -i "/\[multilib-testing\]/,/Include/"'s/^#//' /etc/pacman.conf && \
    pacman -Sy --noconfirm && \
    pacman -S --noconfirm \
      which gcc make git wget \
      python-pip \
      rocm-hip-sdk
# Inspired by https://github.com/Atinoda/text-generation-webui-docker/blob/master/Dockerfile
RUN pacman -S --noconfirm python-virtualenv
RUN virtualenv /venv
ENV VIRTUAL_ENV=/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm5.5
ENV PATH="/opt/rocm/bin:$PATH"
RUN mkdir -p /app/repositories
RUN pip install ninja
# ROCM bits and bytes
RUN git clone https://github.com/agrocylo/bitsandbytes-rocm.git /app/repositories/bitsandbytes-rocm && \
    cd /app/repositories/bitsandbytes-rocm && \
    make hip && \
    python setup.py install
# GPTQ LLaMa
RUN git clone https://github.com/WapaMario63/GPTQ-for-LLaMa-ROCm.git /app/repositories/GPTQ-for-LLaMa && \
    cd /app/repositories/GPTQ-for-LLaMa && \
    python setup_rocm.py install
# exllama
RUN git clone https://github.com/turboderp/exllama /app/repositories/exllama
# text-generation-webui
RUN pip install \
      accelerate==0.20.3 \
      colorama \
      datasets \
      einops \
      fastapi==0.95.2 \
      flexgen==0.1.7 \
      gradio_client==0.2.5 \
      gradio==3.33.1 \
      markdown \
      numpy \
      pandas \
      Pillow>=9.5.0 \
      pyyaml \
      requests \
      safetensors==0.3.1 \
      sentencepiece \
      tqdm \
      scipy \
      tensorboard \
      wandb \
      transformers==4.30.2 \
      git+https://github.com/huggingface/peft@03eb378eb914fbee709ff7c86ba5b1d033b89524
RUN git clone https://github.com/oobabooga/text-generation-webui /app/text-generation-webui
RUN ln -s /app/repositories /app/text-generation-webui/repositories
WORKDIR /app/text-generation-webui
EXPOSE 7860
EXPOSE 5000
EXPOSE 5005
ENV PYTHONUNBUFFERED=1
CMD ["python", "server.py", "--listen", "--trust-remote-code", "--loader", "exllama"]
