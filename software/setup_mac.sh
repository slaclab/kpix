export ROGUE_DIR=${PWD}/rogue/
export KPIX_DIR=${PWD}/
export SURF_DIR=${PWD}/../firmware/submodules/surf/
       

export PYTHONPATH=${ROGUE_DIR}/python:${KPIX_DIR}/python:${SURF_DIR}/python:${PYTHONPATH}
export LD_LIBRARY_PATH=${ROGUE_DIR}/lib:${LD_LIBRARY_PATH}
