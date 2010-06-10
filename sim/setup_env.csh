# Setup paths for simulation
setenv SIM_DIR /u1/rherbst/sim/
#source /afs/slac.stanford.edu/g/reseng/synopsys/vcs-mx/B-2008.12/settings.csh
#source /afs/slac.stanford.edu/g/reseng/synopsys/ns/B-2008.09-SP1/settings.csh
source /afs/slac.stanford.edu/g/reseng/synopsys/vcs-mx/C-2009.06/settings.csh
source /afs/slac.stanford.edu/g/reseng/synopsys/ns/C-2009.06/settings.csh
source /afs/slac.stanford.edu/g/reseng/synopsys/CosmosScope/C-2009.06/settings.csh
source /u/ey/rherbst/projects/w_si/src/local/setup_env.csh
source $HOME/.env/prompt.csh w_si_sim
limit stacksize 60000
setenv LD_LIBRARY_PATH ${SIM_DIR}:${LD_LIBRARY_PATH}
