#!/usr/bin/env bash
echo "hello"
SIZES="128"
COUNT=10000
LAT_TESTS="pipe_lat tcp_lat unix_lat mempipe_lat tcp_nodelay_lat"
TESTS="${LAT_TESTS}"

NUM_CORES=$2

ODIR=$1
rm -rf ${ODIR}
mkdir -p ${ODIR}

for SIZE in ${SIZES}; do
for c1 in $(jot ${NUM_CORES} 0); do
  for c2 in $(jot ${NUM_CORES} 0); do
    echo ${c1} to ${c2}
    for t in ${TESTS}; do
      d="${ODIR}/${SIZE}/${c1}-${c2}-${t}"
      mkdir -p ${d}
      if [ ${c1} -eq ${c2} ]; then
        count=100
      else
        count=${COUNT}
      fi
      ./${t} -t -s ${SIZE} -c ${count} -a ${c1} -b ${c2} -o ${d}
    done
  done
done

# post-processing
for t in ${TESTS}; do
ofile=${ODIR}/${t}.csv
for c1 in $(jot ${NUM_CORES} 0); do
  for c2 in $(jot ${NUM_CORES} 0); do
    d="${ODIR}/${SIZE}/${c1}-${c2}-${t}/01-${t}-headline.log"
    speed=`tail -1 ${d} | awk '{print $4}' | sed -e 's/s//g'`
    echo -n "${speed} " >> ${ofile}
#    rm ${ODIR}/${SIZE}/${c1}-${c2}-${t}/01-${t}-raw_tsc.log
  done
  echo "" >> ${ofile}
done
done

done
