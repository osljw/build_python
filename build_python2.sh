set -e
called_file=${BASH_SOURCE[0]}
file_abs_path=`readlink -f $called_file`
_DIR=`dirname $file_abs_path`
echo "========= ROOTDIR: $_DIR =========="

ROOT_DIR=$_DIR

# source download 
python_download_path=https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
setuptools_download_path=https://github.com/pypa/setuptools/archive/master.zip
pip_download_path=https://github.com/pypa/pip/archive/master.zip

# 
download_dir=$ROOT_DIR/download
install_dir=$ROOT_DIR/install
PYTHON_INSTALL_DIR=$ROOT_DIR/install/Python



mkdir -p ${download_dir}
mkdir -p ${install_dir}

## ==================== python ===========================
## download
#cd ${download_dir}
#python_pkg=`basename ${python_download_path}`
#curl -O ${python_download_path}
#tar -xvf ${python_pkg}
#
## install
#cd ${python_pkg%.*}
#./configure --prefix="${PYTHON_INSTALL_DIR}" --enable-unicode=ucs4
#make 
#make install
#
#
# ================== setuptools ==========================
# download
cd ${download_dir}
wget ${setuptools_download_path}
mv master.zip setuptools.zip
unzip setuptools.zip

# install
cd setuptools-master
${PYTHON_INSTALL_DIR}/bin/python bootstrap.py
${PYTHON_INSTALL_DIR}/bin/python setup.py install

# ================= pip ===================
# download
cd ${download_dir}
wget ${pip_download_path}
mv master.zip pip.zip
unzip pip.zip

# install
cd pip-master
${PYTHON_INSTALL_DIR}/bin/python setup.py install


# tensorflow, sklearn, scipy
${PYTHON_INSTALL_DIR}/bin/pip install tensorflow
${PYTHON_INSTALL_DIR}/bin/pip install sklearn
${PYTHON_INSTALL_DIR}/bin/pip install scipy

# ============= package Python ===============
cd "${PYTHON_INSTALL_DIR}" 
zip -r Python.zip *
mv Python.zip $ROOT_DIR

# upload to hdfs
#hdfs dfs -put Python.zip /user/hero/python/ 
