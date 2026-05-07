# 使用しているGPUドライバに対応するpytorchイメージを使用
FROM pytorch/pytorch:2.11.0-cuda13.0-cudnn9-runtime

# 作業ディレクトリ設定
WORKDIR /app

# 必要なモジュールをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  && rm -rf /var/lib/apt/lists/*

# comfyインストール
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir  -r requirements.txt

# ユーザー設定
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8188

# comfy起動
ENTRYPOINT ["python", "main.py", "--listen", "0.0.0.0"] 
