FROM andrewseidl/nvidia-cuda:10.1-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 1. Fix NVIDIA GPG keys and install system dependencies
RUN apt-get update || true && \
    apt-get install -y wget && \
    # Overwrite the old key with the new one
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.8 python3.8-dev python3-pip python3-setuptools \
    build-essential cmake git curl vim tmux \
    libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 libxrender1 \
    libassimp-dev libtiff5-dev libjpeg8-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    tcl8.6-dev tk8.6-dev freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Set Python 3.8 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && python -m pip install --upgrade pip

# 3. Install Heavyweights (Pinned for 2020 compatibility)
RUN pip install --no-cache-dir \
    torch==1.6.0+cu101 torchvision==0.7.0+cu101 \
    -f https://download.pytorch.org/whl/torch_stable.html

# 4. Install Jupyter Stack & Interactive Tools
RUN pip install --no-cache-dir \
    jupyterlab==2.2.9 \
    ipykernel \
    ipywidgets==7.5.1

# 5. Install CV and Rendering stack
RUN pip install --no-cache-dir \
    numpy==1.18.1 \
    opencv-python==4.2.0.32 \
    scipy==1.4.1 \
    matplotlib==3.2.1 \
    pillow==7.1.1 \
    scikit-image==0.16.2 \
    trimesh==3.6.34 \
    pyrender==0.1.39 \
    pyopengl==3.1.0 \
    transforms3d==0.3.1

# 6. Install Remaining Dependencies
RUN pip install --no-cache-dir \
    cython pandas==1.0.3 \
    scikit-learn==0.22.2.post1 \
    tqdm networkx cffi \
    tensorboard==2.2.0 tensorboardX==2.0 \
    visdom==0.1.8.9 \
    requests ujson tabulate \
    pyquaternion pyassimp==4.1.4 \
    structlog pywavelets

# 7. Manual Build for PyOpenGL Accelerate
RUN pip install --no-cache-dir PyOpenGL-accelerate==3.1.5 || \
    (git clone https://github.com/mcfletch/pyopengl.git /tmp/pyopengl && \
     cd /tmp/pyopengl/accelerate && \
     sed -i 's/long(/int(/g' src/vbo.pyx && \
     python setup.py install) || true

WORKDIR /app/neurend
COPY . /app/neurend

# Fixed ENV syntax
ENV PYTHONPATH="/app/neurend:${PYTHONPATH}"
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}"

EXPOSE 8888

# CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]