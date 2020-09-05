cd ~
sudo apt-get --yes update && sudo apt-get --yes upgrade
sudo apt-get install -y --fix-missing \
	software-properties-common \
	wget \
        g++ \
        wget \
        build-essential \
        git \
        cmake \
        gfortran \
        vim \
        libblas-dev \
        liblapack-dev \
        libeigen3-dev \
        libhdf5-dev \
        libhdf5-serial-dev \
        autoconf \
        libtool \
        hdf5-tools
        
sudo apt install python-is-python3
sudo ln -s /usr/bin/pip3 /usr/bin/pip

pip install --user setuptools numpy scipy cython nose tables matplotlib jinja2 \
	future nbconvert


# MOAB installation
sudo apt-get --yes install libnetcdf-dev libnetcdff-dev

cd $HOME
mkdir -p $HOME/dagmc_bld/MOAB
MOAB_INSTALL_DIR=$HOME/dagmc_bld/MOAB
cd $MOAB_INSTALL_DIR
git clone -b Version5.1.0 https://bitbucket.org/fathomteam/moab/
cd moab
autoreconf -fi
mkdir bld
cd bld
cmake .. \
	-DBUILD_SHARED_LIBS=ON \
	-DENABLE_HDF5=ON -DHDF5_ROOT=/usr/lib/x86_64-linux-gnu/hdf5/serial \
	-DENABLE_NETCDF=ON \
	-DENABLE_PYMOAB=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR

make -j 2
make install
cd $MOAB_INSTALL_DIR
rm -rf moab 

echo 'export PATH=$MOAB_INSTALL_DIR/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$MOAB_INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
PYTHON_VERSION=$(python -c 'import sys; print(sys.version.split('')[0][0:3])')

if [ -z $PYTHONPATH ]; then
  echo "export  PYTHONPATH='$MOAB_INSTALL_DIR/lib/python${PYTHON_VERSION}/site-packages'" >> ~/.bashrc
else
  echo  'export PYTHONPATH=$MOAB_INSTALL_DIR/lib/python${PYTHON_VERSION}/site-packages:$PYTHONPATH' >> ~/.bashrc
fi

# DAGMC Installation
cd ~
mkdir -p $HOME/dagmc_bld/DAGMC
DAGMC_INSTALL_DIR=$HOME/dagmc_bld/DAGMC
cd $DAGMC_INSTALL_DIR
git clone -b develop https://github.com/svalinn/DAGMC.git
cd DAGMC
mkdir bld
cd bld
cmake .. -DMOAB_DIR=$MOAB_INSTALL_DIR -DCMAKE_INSTALL_PREFIX=$DAGMC_INSTALL_DIR

make -j 2
make install

cd ../..
rm -rf DAGMC

echo 'export LD_LIBRARY_PATH=$DAGMC_INSTALL_DIR/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

 
# PyNE installation

mkdir -p ~/opt
cd ~/opt
git clone -b develop --single-branch https://github.com/pyne/pyne.git
cd pyne
python setup.py install --clean \
	--user 
	--moab $MOAB_INSTALL_DIR \
	--dagmc $DAGMC_INSTALL_DIR \

echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/.local/lib:$LD_LIBRARY_PATH'

cd ~
nuc_data_make

cd $HOME/opt/pyne/tests
./travis-run-tests.sh python3
 
