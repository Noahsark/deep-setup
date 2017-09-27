#! /bin/bash


cd ~/Downloads

# essential
sudo apt-get install -y build-essential python python-pip




# install cuda 8.0 & caffe
# https://github.com/BVLC/caffe/wiki/Caffe-installing-script-for-ubuntu-16.04---support-Cuda-8

wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y opencl-headers build-essential protobuf-compiler \
    libprotoc-dev libboost-all-dev libleveldb-dev hdf5-tools libhdf5-serial-dev \
    libopencv-core-dev  libopencv-highgui-dev libsnappy-dev \
    libatlas-base-dev cmake libstdc++6-4.8-dbg libgoogle-glog0v5 libgoogle-glog-dev \
    libgflags-dev liblmdb-dev git python-pip gfortran libopencv-dev
sudo apt-get clean

sudo apt-get install -y cuda

# CUDNN

# download cudnn library from regestraction. 
sudo dpkg -i libcudnn6_6.0.21-1+cuda8.0_amd64.deb

# Get caffe, and install python requirements
mkdir ~/workspace && cd ~/workspace
git clone https://github.com/BVLC/caffe.git
cd caffe
cd python
for req in $(cat requirements.txt); do sudo pip install $req; done

# Prepare Makefile.config so that it can build on aws
cd ../
cp Makefile.config.example Makefile.config
if [ -f "../cudnn-8.0-linux-x64-v6.0.tgz" ] ; then
  sed -i '/^# USE_CUDNN := 1/s/^# //' Makefile.config
fi
sed -i '/^# WITH_PYTHON_LAYER := 1/s/^# //' Makefile.config
sed -i 's/\/usr\/local\/cuda/\/usr\/local\/cuda-8.0/g' Makefile.config
sed -i 's/\/usr\/local\/include/\/usr\/local\/include \/usr\/include\/hdf5\/serial/g' Makefile.config
sed -i '/^PYTHON_INCLUDE/a    /usr/local/lib/python2.7/dist-packages/numpy/core/include/ \\' Makefile.config

sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial.so.10.1.0 /usr/lib/x86_64-linux-gnu/libhdf5.so
sudo ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial_hl.so.10.0.2 /usr/lib/x86_64-linux-gnu/libhdf5_hl.so

# And finally build!
make -j 8 all py

make -j 8 test
make runtest

echo "export PYTHONPATH=/opt/cat-dogs/repo/caffe/python:$PYTHONPATH" >> ~/.bashrc
