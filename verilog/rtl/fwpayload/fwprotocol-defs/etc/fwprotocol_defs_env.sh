#****************************************************************************
#* fwprotocol_defs_env.sh
#*
#* Environment setup script for fwprotocol_defs
#****************************************************************************


etc_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd)"
rootdir=`cd $etc_dir/.. ; pwd`


FWPROTOCOL_DEFS=${rootdir}
export FWPROTOCOL_DEFS


# Add a path to the simscripts directory
export PATH=$rootdir/packages/simscripts/bin:$PATH

# Force the PACKAGES_DIR
export PACKAGES_DIR=$rootdir/packages
