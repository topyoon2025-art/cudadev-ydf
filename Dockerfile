FROM nvidia/cuda:12.9.1-devel-ubuntu24.04

#Create Dev Directory
ENV CUDA_PATH=/root/cudadev
RUN mkdir $CUDA_PATH

#Install necessary packages/libraries
RUN apt-get update
#RUN apt-get install apt-utils
RUN apt-get install openssh-server -y
RUN apt-get install net-tools
RUN apt-get install nano
RUN apt-get install git -y
RUN apt-get install cmake -y
RUN apt-get install pip -y
RUN apt-get install python3.12-venv -y
RUN apt-get install clang llvm lcov default-jdk zip -y
RUN apt-get install curl
RUN apt-get install wget
RUN apt-get install libclang-rt-dev

#Clone sameple folders and create working folders 
RUN git clone https://github.com/NVIDIA/cuda-samples $CUDA_PATH/cuda-samples
RUN mkdir $CUDA_PATH/cuda-samples/Samples/9_POC
RUN mkdir $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CUDA
RUN mkdir $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CUDA/build
RUN mkdir $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CPP
RUN mkdir $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CPP/build
RUN git clone https://github.com/google/yggdrasil-decision-forests.git $CUDA_PATH/yggdrasil-decision-forests
RUN git clone https://github.com/ariellubonja/yggdrasil-oblique-forests.git $CUDA_PATH/yggdrasil-oblique-forests


#Copy the necessary files into the container
COPY test.py $CUDA_PATH
COPY authorized_keys /root/.ssh
COPY entrypoint.sh $CUDA_PATH
RUN chmod +x $CUDA_PATH/entrypoint.sh
COPY CMakeLists.txt $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CUDA/
COPY poc_cuda.cu $CUDA_PATH/cuda-samples/Samples/9_POC/POC_CUDA/
COPY workspace.bzl $CUDA_PATH/yggdrasil-oblique-forests/third_party/eigen3/
COPY cc_toolchain_config.bzl $CUDA_PATH/yggdrasil-oblique-forests/toolchains/

#Configure root login for remote SSH connection
RUN echo "root:passwd" | chpasswd
RUN echo "PermitRootLogin Yes" >> /etc/ssh/sshd_config

#Configure vitual environment for python pandas and ydf 
RUN python3 -m venv $CUDA_PATH
RUN . /root/cudadev/bin/activate && pip install pandas && pip install ydf && deactivate

#Set env pah in .bashrc for CUDA toolkit
RUN echo "export PATH=/usr/local/cuda-12.9/bin${PATH:+:${PATH}}" >> /root/.bashrc
RUN echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.9/lib64{LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> /root/.bashrc

#Bazel installation
RUN curl -L https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 -o /usr/local/bin/bazel
RUN chmod +x /usr/local/bin/bazel

#ICX GPG Key / Installation 
RUN wget -qO /etc/apt/trusted.gpg.d/intel-oneapi.asc https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
RUN echo "deb https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/intel-oneapi.list
RUN apt update
RUN apt install -y intel-oneapi-compiler-dpcpp-cpp
RUN echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' | tee -a /etc/profile.d/intel-oneapi.sh
RUN . /etc/profile

#Restart SSH server
ENTRYPOINT ["/root/cudadev/entrypoint.sh"]

EXPOSE 22

WORKDIR $CUDA_PATH
CMD ["/bin/bash"]
