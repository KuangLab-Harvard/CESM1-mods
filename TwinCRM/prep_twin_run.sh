#!/bin/bash
# make a list of dates to make cases 
#module load nco automatically loaded now

REFDATE="0001-10-03" 
#REFDATE="$1"
CASENAME="test_twin"
#CASENAME="twin_restart_${REFDATE}"
REFCASE="twin_control"

echo "${CASENAME}"
~/create_new_build.sh ${CASENAME} f19_f19 F_2000_SPCAM_sam1mom 64

# once the build is created
echo "case created"

# move all the restart files to correct folder
echo "moving restart files to run folder"
DATE="${REFDATE}-00000"
OLDPATH="/n/holylfs04/LABS/kuang_lab/Lab/sweidman/cesm_output/${REFCASE}/run/"
NEWPATH="/n/holylfs04/LABS/kuang_lab/Lab/sweidman/cesm_output/${CASENAME}/run/"
ENDING=".nc"
OLDDATE="0003-01-01-00000"

declare -a RESTNAMES=(".cam.h1." ".cam.r." ".cam.rh0." ".cam.rs." ".cam.i." ".cice.r." ".clm2.r." ".clm2.rh0." ".cpl.r.")

for rest in ${RESTNAMES[@]}; do
    cp $OLDPATH$REFCASE$rest$DATE$ENDING $NEWPATH
done

# move rpointer files and change the reference date.
cp ${OLDPATH}rpointer* $NEWPATH
sed -i "s/00[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-00000/$DATE/" ${NEWPATH}rpointer*

# run adapt_buffer_dims.sh with correct params
echo "adjusting restart buffer"
BUFFERFILE="${NEWPATH}/${REFCASE}.cam.r.${REFDATE}-00000.nc"

# remove extra CRM dimension from CRM buffer variables. 
# 1,,2 specifies taking every other buffer index, starting on the second CRM.
ncks -d pbuf_01536,1,,2 ${BUFFERFILE} ${NEWPATH}temp.nc
ncrename -d pbuf_01536,pbuf_00768 ${NEWPATH}temp.nc
ncks -d pbuf_00052,1,,2 ${NEWPATH}temp.nc ${NEWPATH}temp2.nc
ncks -O --no_tmp_fl -x -v pbuf_00052,CLDO ${NEWPATH}temp2.nc ${BUFFERFILE}
ncks -O --no_tmp_fl -C -v CLDO ${NEWPATH}temp2.nc ${NEWPATH}temp3.nc
ncrename -d pbuf_00052,pbuf_00026 ${NEWPATH}temp3.nc
ncks -A --no_tmp_fl ${NEWPATH}temp3.nc ${BUFFERFILE}

rm ${NEWPATH}temp.nc
rm ${NEWPATH}temp2.nc
rm ${NEWPATH}temp3.nc

# change run parameters
echo "changing run parameters"
cd ~/cesm_caseroot/${CASENAME}

./xmlchange RUN_TYPE="branch"
./xmlchange RUN_STARTDATE="${REFDATE}"
./xmlchange RUN_REFDATE="${REFDATE}"
./xmlchange RUN_REFCASE="${REFCASE}"
./xmlchange STOP_OPTION="ndays"
./xmlchange STOP_N="60"
./xmlchange REST_OPTION="nmonths"

# change the runtime of the model to one day
sed -i "s/-t 999999/-t 1440/" ${CASENAME}.run
# line in question: #SBATCH -t 999999  # minutes
# change mpi run command
sed -i '/srun --mpi=pmi2/s/^/#/g' ${CASENAME}.run
sed -i '/mpirun -np/s/^#//g' ${CASENAME}.run
sed -i 's/huce_ice/huce_cascade/' ${CASENAME}.run
#sed -i '57 als /n/holystore01/INTERNAL_REPOS' ${CASENAME}.run
#sed -i "s/--contiguous/-contiguous/" ${CASENAME}.run
#sed -i "s/--use-min-nodes/-use-min-nodes/" ${CASENAME}.run

# copy over right user_nl_cam file
cp ~/cesm_caseroot/twin_restart_scratch/user_nl_cam ~/cesm_caseroot/${CASENAME}/

./preview_namelists

./${CASENAME}.submit
