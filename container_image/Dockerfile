# 使用しているGPUドライバに対応するpytorchイメージを使用
FROM pytorch/pytorch:2.11.0-cuda13.0-cudnn9-runtime

# 作業ディレクトリ設定
WORKDIR /app

# 必要なモジュールをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  git python3.12-venv\
  && rm -rf /var/lib/apt/lists/*

# python仮想環境作成(PEP 668)
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# comfyインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir  -r requirements.txt

# comfyuiのカスタムノードをインストール
WORKDIR /app/ComfyUI/custom_nodes

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack comfyui-impact-pack && \
    cd comfyui-impact-pack && \
    pip install -r requirements.txt
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    cd ComfyUI-Impact-Subpack && \
    pip install -r requirements.txt
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use && \
    cd ComfyUI-Easy-Use && \
    pip install -r requirements.txt
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale
RUN git clone https://github.com/rgthree/rgthree-comfy.git
RUN git clone https://github.com/alexopus/ComfyUI-Image-Saver.git && \
    cd ComfyUI-Image-Saver && \
    pip install -r requirements.txt
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    pip install -r requirements.txt
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
RUN git clone https://github.com/Miosp/ComfyUI-FBCNN.git
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux && \
    cd comfyui_controlnet_aux && \
    pip install -r requirements.txt

# ユーザー設定
RUN groupadd -g 1050 appuser && \
    useradd -m -u 1050 -g 1050 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8188

# comfy起動
ENTRYPOINT ["python", "main.py", "--listen", "0.0.0.0"] 
