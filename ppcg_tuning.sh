#!/bin/bash

#set -x

PPCG_COMPILER=~/src/ppcgs/ppcg-gforge-pet-tree/ppcg 
BENCH_ROOT=~/src/pencil_codes/CARP-Benchmarks/
OPENCL_PREFIX=/opt/AMDAPP/

#Kings_Cross_Western_Concourse_-_central_position_-_2012-05-02.75.jpg

PPCG_EXTRA_OPTIONS="--target=opencl --opencl-print-kernels-time-measurements -D__PENCIL__" 

# TUNE_WORKGROUP_AND_BLOCK_SIZES is forced to 0 when DEFAULT is used in DIMENSIONS
TUNE_WORKGROUP_AND_BLOCK_SIZES=1
COMPILE_WITH_PPCG=1
AUTOTUNE=1

LIST_OF_KERNELS="resize dilate cvt_color warpAffine filter2D gaussian"
DIMENSIONS="1D-2D 1D-2D 1D-2D 1D-2D 1D-2D 1D-2D"

#LIST_OF_KERNELS="resize dilate cvt_color warpAffine filter2D gaussian"
#DIMENSIONS="1D 1D 2D 2D DEFAULT DEFAULT"

NB_TESTS=10
PEROFRM_ONLY_ONE_TEST=1
OUTPUT_TIME_FILE="output_time"
TEMP_OUTPUT_FILE=temp_output_file
TEMP_TIME_FILE_1=temp_time_file_1
TEMP_TIME_FILE_2=temp_time_file_2
LOG_FILE=log
DELIMITER="/"
WAIT_TIME=180
######################################################################"
# Tuning options

# General options
#TUNING_FUSION[0]=""

TUNING_FUSION[0]="--isl-schedule-fuse=max --no-isl-schedule-separate-components"
TUNING_FUSION[1]="--isl-schedule-fuse=min"

# GPU options
TUNING_SHARED_MEM[0]=""
TUNING_SHARED_MEM[1]="--no-shared-memory"
#TUNING_PRIVATE_MEM[0]=""
#TUNING_PRIVATE_MEM[1]="--no-private-memory"
TUNING_PRIVATE_MEM[0]="--no-private-memory"

#Block sizes
TUNING_TILE_SIZES[0]="64 128 256" #8 128 256
TUNING_TILE_SIZES[1]="16,16 32,8 8,32"  #16,16  32,32  64,64
TUNING_TILE_SIZES[2]="64 128 256 16,16 32,8 8,32"

TUNING_GRID_SIZES[0]="6255072 256" #64 512 1024 128
TUNING_GRID_SIZES[1]="3712,1696 16,16" #32,32
TUNING_GRID_SIZES[2]="6255072 256 3712,1696 16,16"

#Tile sizes
TUNING_BLOCK_SIZES[0]="1 16 32" #4 16 32 64 #8 128 256
TUNING_BLOCK_SIZES[1]="1,1 8,8 16,16" #2,4  4,2  4,4  8,8  16,16  #4,8  8,4  16,16  32,32  8,1  1,8
TUNING_BLOCK_SIZES[2]="16 32 8,8 16,16"

#OpenCL options
# The following option may be contradictory with the same option set in the PPCG_OMP_BASIC_OPTIONS.
TUNING_OPENCL_COMPILER_OPTIONS[0]=""
#TUNING_OPENCL_COMPILER_OPTIONS[0]="--opencl-compiler-options=-cl-fast-relaxed-math"
#TUNING_OPENCL_COMPILER_OPTIONS[1]="--opencl-compiler-options=-cl-strict-aliasing"

######################################################################"
DEFINES=""
if [ $PEROFRM_ONLY_ONE_TEST = 1 ]; then
	DEFINES="$DEFINES -DRUN_ONLY_ONE_EXPERIMENT"
fi

for dim in $DIMENSIONS; do
        DIMENSION_ARRAY[$id]=$dim
        id=`expr $id + 1`
done
######################################################################"

# INPUT: a boolean.
# Print success if input=0 (represents successful execution), else print error.
# USAGE: "success $?"
success()
{
  if [ $1 = 0 ]; then
    echo -e "\e[32m    .Success\e[0m"
  else
    echo -e "\e[31m    .Error\e[0m"
    ERROR_SOME_WHERE=1
  fi
}


# compile the kernel ($1) with ppcg and then with g++
compile()
{
  KERNEL=$1
  ppcg_options=$2
  echo
  echo "[$KERNEL]"
  echo "[$KERNEL]" >> $LOG_FILE

  if [ $COMPILE_WITH_PPCG = 1 ]; then
    echo "    .ppcg $ppcg_options"
    echo "    .ppcg $PPCG_EXTRA_OPTIONS $ppcg_options $KERNEL.pencil.c" >> $LOG_FILE
    $PPCG_COMPILER $PPCG_EXTRA_OPTIONS $ppcg_options -I$BENCH_ROOT/$KERNEL $BENCH_ROOT/$KERNEL/$KERNEL.pencil.c &>> $LOG_FILE
    success $?
  fi

  echo "    .compiling ${KERNEL}.pencil_host.c and test_${KERNEL}.cpp (g++)"
  g++ -x c -c -O3 -DNDEBUG -march=native -fomit-frame-pointer -fPIC -ffast-math -Wall -std=c99 -Iinclude -Ibuild -I$OPENCL_PREFIX/include/ -I$BENCH_ROOT/$KERNEL ${KERNEL}.pencil_host.c -o $KERNEL.pencil_host.o &>> $LOG_FILE
  EXIT_STATUS_COMPILATION_1=$?

  g++ -shared -O3 -o lib${KERNEL}_ppcg.so $BENCH_ROOT/build/ocl_utilities.o $KERNEL.pencil_host.o -L$OPENCL_PREFIX/lib/x86_64/ -lOpenCL -L/usr/local/lib/ -lopencv_core -lopencv_imgproc -lopencv_ocl -lopencv_highgui -L/usr/lib/ -ltbb -ltbbmalloc -Lbuild -lboost_date_time -lboost_filesystem -lboost_iostreams -lboost_program_options -lboost_serialization -lboost_system -lboost_chrono &>> $LOG_FILE
  EXIT_STATUS_COMPILATION_2=$?

  g++ -O3 $DEFINES -DNDEBUG -march=native -fomit-frame-pointer -fPIC -ffast-math -Wall -std=c++0x -Iinclude -Ibuild -I$OPENCL_PREFIX/include/ -I/usr/local/include/ -I/usr/include/ -I$BENCH_ROOT/include/ -Wl,-rpath=RIGIN:/usr/local/lib/ -I$BENCH_ROOT/build/ $BENCH_ROOT/$KERNEL/test_${KERNEL}.cpp -o ppcg_test_${KERNEL} -L$OPENCL_PREFIX/lib/x86_64/ -lOpenCL -L/usr/local/lib/ -lopencv_core -lopencv_imgproc -lopencv_ocl -lopencv_highgui -L/usr/lib/ -ltbb -ltbbmalloc -Lbuild -lboost_date_time -lboost_filesystem -lboost_iostreams -lboost_program_options -lboost_serialization -lboost_system -lboost_chrono -L. -l${KERNEL}_ppcg &>> $LOG_FILE
  EXIT_STATUS_COMPILATION_3=$?

  EXIT_STATUS_COMPILATION=`expr $EXIT_STATUS_COMPILATION_1 + $EXIT_STATUS_COMPILATION_2 + $EXIT_STATUS_COMPILATION_3`
  success $EXIT_STATUS_COMPILATION
}


run()
{
  KERNEL=$1

  rm -rf $TEMP_TIME_FILE_1 $TEMP_TIME_FILE_2 $TEMP_OUTPUT_FILE

  if [ -f $BENCH_ROOT/stop ]; then
	echo -n "    .Waiting $WAIT_TIME seconds: "
	for ((t=0;t<$WAIT_TIME;t++)); do
		sleep 1
		echo -n "$t "
	done
  	rm $BENCH_ROOT/stop
	echo
  fi

  echo -n "    .running ./ppcg_test_${KERNEL}: "
 
  for ((i=0; i < $NB_TESTS; i++)); do
	  echo -n "$i/$NB_TESTS "
	  ./ppcg_test_${KERNEL} 1>>$TEMP_OUTPUT_FILE 2>>$LOG_FILE
	  ppcg_exit_status=$?
  done
  echo

  success $ppcg_exit_status
  if [ $ppcg_exit_status = 0 ]; then
          cat $TEMP_OUTPUT_FILE | grep -F "Total GPU time (inc copy):" | awk '{print $NF;}' 1> $TEMP_TIME_FILE_2
	  echo -n `$BENCH_ROOT/get_median_first_column.sh $TEMP_TIME_FILE_2` >>  ${OUTPUT_TIME_FILE}.${KERNEL}.csv
	  echo -n "$DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
	  cat $TEMP_OUTPUT_FILE | grep -F "[PPCG] Kernel execution time in seconds (with data copy but without kernel compilation time) :" | awk '{print $NF;}' 1> $TEMP_TIME_FILE_1
	  echo -n `$BENCH_ROOT/get_median_first_column.sh $TEMP_TIME_FILE_1` >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
	  echo -n "$DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
  else
	  echo " ERROR in ./ppcg_test_${KERNEL}" >> $LOG_FILE
	  echo -n "9999 $DELIMITER 9999 $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
  fi

  echo "--------------------------------------------------" >> $LOG_FILE
}

####################################################################################"

PREPARE_OUTPUT_FILE()
{
	KERNEL=$1

	rm -rf ${OUTPUT_TIME_FILE}.${KERNEL}.csv

	echo -n "PPCG options $DELIMITER" > ${OUTPUT_TIME_FILE}.${KERNEL}.csv

	echo -n "${KERNEL}-OpenCV $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
	echo -n "${KERNEL}-PPCG $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv 

	echo "" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv

}

##########################

AUTO_TUNE()
{
KERNEL=$1
DIMENSION=$2

	if [ $DIMENSION = "1D" ]; then
		DIM=0
	else
		if [ $DIMENSION = "2D" ]; then
			DIM=1
		else if [ $DIMENSION = "1D-2D" ]; then
				DIM=2
		     else
			     if [ $DIMENSION = "DEFAULT" ]; then
			     	TUNE_WORKGROUP_AND_BLOCK_SIZES=0
	               	     fi
	             fi	     
	       fi
	fi

	NB_TEST_1=`echo ${TUNING_BLOCK_SIZES[$DIM]} | wc -w`
	NB_TEST_2=`echo ${TUNING_TILE_SIZES[$DIM]}| wc -w`
	NB_TEST_3=`echo ${TUNING_GRID_SIZES[$DIM]} | wc -w`

	if [ $TUNE_WORKGROUP_AND_BLOCK_SIZES = 1 ]; then
		TOTAL_NUMBER_OF_TESTS=`expr ${#TUNING_FUSION[@]} \* ${#TUNING_SHARED_MEM[@]} \* ${#TUNING_PRIVATE_MEM[@]} \* ${#TUNING_OPENCL_COMPILER_OPTIONS[@]} + ${#TUNING_FUSION[@]} \* ${#TUNING_SHARED_MEM[@]} \* ${#TUNING_PRIVATE_MEM[@]} \* ${#TUNING_OPENCL_COMPILER_OPTIONS[@]} \* $NB_TEST_1 \* $NB_TEST_2 \* $NB_TEST_3`
	else
		TOTAL_NUMBER_OF_TESTS=`expr ${#TUNING_FUSION[@]} \* ${#TUNING_SHARED_MEM[@]} \* ${#TUNING_PRIVATE_MEM[@]} \* ${#TUNING_OPENCL_COMPILER_OPTIONS[@]}`
	fi

	option_0=""
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_counter=0

	if [ $AUTOTUNE = 0 ]; then
		      echo -n "$PPCG_EXTRA_OPTIONS $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
		      compile $KERNEL "$options";
		      run $KERNEL;

		      echo "" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
	else # $AUTOTUNE == 1
	  for i0 in ${!TUNING_FUSION[*]}; do
	    for i1 in ${!TUNING_SHARED_MEM[*]}; do
	      for i2 in ${!TUNING_PRIVATE_MEM[*]}; do
		for i6 in ${!TUNING_OPENCL_COMPILER_OPTIONS[*]}; do

		      # Do not generate the different combinations for --sizes '{...}'
		      option_counter=`expr $option_counter + 1`
		      option_0=${TUNING_FUSION[$i0]}
		      option_1=${TUNING_SHARED_MEM[$i1]}
		      option_2=${TUNING_PRIVATE_MEM[$i2]}
		      option_4=${TUNING_OPENCL_COMPILER_OPTIONS[$i6]}
		      options="$option_0 $option_1 $option_2 $option_4"
		      echo
		      echo "Options [$option_counter/$TOTAL_NUMBER_OF_TESTS]: $options"

		      echo -n "$PPCG_EXTRA_OPTIONS $options $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
		      compile $KERNEL "$options";
		      run $KERNEL;

		      echo "" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
		      
		      if [ $TUNE_WORKGROUP_AND_BLOCK_SIZES = 1 ]; then
			# Generate the different combinations for --sizes '{...}'
			for i5 in ${TUNING_BLOCK_SIZES[$DIM]}; do
			  for i3 in ${TUNING_TILE_SIZES[$DIM]}; do
			    for i4 in ${TUNING_GRID_SIZES[$DIM]}; do
			      option_counter=`expr $option_counter + 1`
			      option_0=${TUNING_FUSION[$i0]}
			      option_1=${TUNING_SHARED_MEM[$i1]}
			      option_2=${TUNING_PRIVATE_MEM[$i2]}
			      option_4=${TUNING_OPENCL_COMPILER_OPTIONS[$i6]}
			      option_3="--sizes={kernel[i]->tile[$i3];kernel[i]->grid[$i4];kernel[i]->block[$i5]}"
			      options="$option_0 $option_1 $option_2 $option_3 $option_4"
			      echo
			      echo "Options [$option_counter/$TOTAL_NUMBER_OF_TESTS]: $options"
			      echo -n "$PPCG_EXTRA_OPTIONS $options $DELIMITER" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
			      
			      compile $KERNEL "$options";
		              run $KERNEL;

			      echo "" >> ${OUTPUT_TIME_FILE}.${KERNEL}.csv
			    done
			  done
			done
		      fi # $TUNE_WORKGROUP_AND_BLOCK_SIZES = 1
		done
	      done
	    done
	  done
	fi

	echo "--------------------------------------------------"
}

cd build
rm -rf $LOG_FILE

id=0;
for ker in ${LIST_OF_KERNELS}; do
	PREPARE_OUTPUT_FILE $ker;
	AUTO_TUNE $ker ${DIMENSION_ARRAY[$id]}
	id=`expr $id + 1`
done

cd ..
