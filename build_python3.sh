set -e
called_file=${BASH_SOURCE[0]}
file_abs_path=`readlink -f $called_file`
_DIR=`dirname $file_abs_path`
echo "========= ROOTDIR: $_DIR =========="

ROOT_DIR=$_DIR

#### 
unset LD_LIBRARY_PATH

# source download 
#python_download_path=https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
python_download_path=https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
setuptools_download_path=https://github.com/pypa/setuptools/archive/master.zip
pip_download_path=https://github.com/pypa/pip/archive/master.zip

# 
download_dir=$ROOT_DIR/download
install_dir=$ROOT_DIR/install
PYTHON_INSTALL_DIR=$ROOT_DIR/install/Python3
LIBFFI_INSTALL_DIR=$ROOT_DIR/install/libffi
OPENSSL_INSTALL_DIR=$ROOT_DIR/install/openssl
#LIBFFI_INSTALL_DIR=$ROOT_DIR/install/Python3
#OPENSSL_INSTALL_DIR=$ROOT_DIR/install/Python3

mkdir -p ${download_dir}
mkdir -p ${install_dir}


function install_openssl() {
    # =============== openssl for python _ssl pip =====================
    cd ${download_dir}
    if [ ! -f "openssl-1.1.1a.tar.gz" ]; then
        wget https://www.openssl.org/source/openssl-1.1.1a.tar.gz
    fi
    tar -zxvf openssl-1.1.1a.tar.gz
    cd openssl-1.1.1a
    ./config --prefix=${OPENSSL_INSTALL_DIR}
    make
    make install

}

function install_libffi() {
    # =============== libffi for python _ctype =====================
    cd ${download_dir}
    if [ ! -f "libffi-3.2.1.tar.gz"]; then
        wget ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz
    fi
    tar xzf libffi-3.2.1.tar.gz
    cd libffi-3.2.1
    ./configure --disable-docs --prefix=$LIBFFI_INSTALL_DIR
    make
    make install

}

export LD_LIBRARY_PATH=${PYTHON_INSTALL_DIR}/lib:$LIBFFI_INSTALL_DIR/lib64:$LD_LIBRARY_PATH
function install_python() {
    # ==================== python ===========================
    # download
    cd ${download_dir}
    python_pkg=`basename ${python_download_path}`
    if [ ! -f ${python_pkg} ]; then
        curl -O ${python_download_path}
    fi
    tar -xvf ${python_pkg}
    
    # install
    cd ${python_pkg%.*}
    #./configure --prefix="${PYTHON_INSTALL_DIR}" --enable-unicode=ucs4
    #./configure --with-openssl=${OPENSSL_INSTALL_DIR} --enable-optimizations --prefix=$PYTHON_INSTALL_DIR --with-ensurepip=install LDFLAGS="-L${LIBFFI_INSTALL_DIR}/lib64" CPPFLAGS="-I ${LIBFFI_INSTALL_DIR}/include"

    mkdir -p $PYTHON_INSTALL_DIR/lib
    cp -r ${OPENSSL_INSTALL_DIR}/lib $PYTHON_INSTALL_DIR
    cp -r ${LIBFFI_INSTALL_DIR}/lib64 $PYTHON_INSTALL_DIR

    # PKG_CONFIG_PATH will affect LIBFFI_INCLUDEDIR(see config.log after ./configure runing)
    # _ctype build need libffi
    PKG_CONFIG_PATH=${LIBFFI_INSTALL_DIR}/lib/pkgconfig ./configure \
        --prefix=${PYTHON_INSTALL_DIR} \
        --with-openssl=${OPENSSL_INSTALL_DIR} \
        LDFLAGS="-L${LIBFFI_INSTALL_DIR}/lib64"
    make -j 20
    make install
}

install_openssl
install_libffi
install_python



### tensorflow, sklearn, scipy
##${PYTHON_INSTALL_DIR}/bin/pip3 install tensorflow
##${PYTHON_INSTALL_DIR}/bin/pip3 install sklearn
##${PYTHON_INSTALL_DIR}/bin/pip3 install scipy
##${PYTHON_INSTALL_DIR}/bin/pip3 install jupyterlab
##
### ============= package Python ===============
##cd "${PYTHON_INSTALL_DIR}" 
##zip -r Python3.zip *
##mv Python3.zip $ROOT_DIR
#
## upload to hdfs
##hdfs dfs -put Python.zip /user/hero/python/ 
#
