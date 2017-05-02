#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
usage="USAGE: $0 <full path to the NuttX directory>"

# Get the single, required command line argument

nuttx_path=$1
if [ -z "${nuttx_path}" ]; then
  echo "ERROR: Missing path to the NuttX directory"
  echo $usage
  exit 1
fi

# Lots of sanity checking so that we do not do anything too stupid

if [ ! -d libxx ]; then
  echo "ERROR: Directory libxx does not exist in this directory"
  echo "       Please CD into the libcxx directory and try again"
  echo $usage
  exit 1
fi

if [ ! -d include ]; then
  echo "ERROR: Directory include does not exist in this directory"
  echo "       Please CD into the libcxx directory and try again"
  echo $usage
  exit 1
fi

if [ ! -d "${nuttx_path}" ]; then
  echo "ERROR: Directory ${nuttx_path} does not exist"
  echo $usage
  exit 1
fi

if [ ! -f "${nuttx_path}/Makefile" ]; then
  echo "ERROR: No Makefile in directory ${nuttx_path}"
  echo $usage
  exit 1
fi

libxx_srcdir=${nuttx_path}/libxx

if [ ! -d "${libxx_srcdir}" ]; then
  echo "ERROR: Directory ${libxx_srcdir} does not exist"
  echo $usage
  exit 1
fi

if [ ! -f "${libxx_srcdir}/Makefile" ]; then
  echo "ERROR: No Makefile in directory ${libxx_srcdir}"
  echo $usage
  exit 1
fi

libcxx_srcdir=${libxx_srcdir}/libcxx

if [ -d "${libcxx_srcdir}" ]; then
  echo "ERROR: Directory ${libcxx_srcdir} already exists"
  echo "       Please remove the  ${libcxx_srcdir} directory and try again"
  echo $usage
  exit 1
fi

nuttx_incdir=${nuttx_path}/include

if [ ! -d "${nuttx_incdir}" ]; then
  echo "ERROR: Directory ${nuttx_incdir} does not exist"
  echo $usage
  exit 1
fi

nuttxcxx_incdir=${nuttx_incdir}/cxx

if [ ! -d "${nuttxcxx_incdir}" ]; then
  echo "ERROR: Directory ${nuttxcxx_incdir} does not exist"
  echo $usage
  exit 1
fi

libcxx_incdir=${nuttx_incdir}/libcxx

if [ -d "${libcxx_incdir}" ]; then
  echo "ERROR: Directory ${libcxx_incdir} already exists"
  echo "       Please remove the  ${libcxx_incdir} directory and try again"
  echo $usage
  exit 1
fi

machine_incdir=${nuttx_incdir}/machine

if [ -d "${machine_incdir}" ]; then
  echo "ERROR: Directory ${machine_incdir} already exists"
  echo "       Please remove the  ${machine_incdir} directory and try again"
  echo $usage
  exit 1
fi

#---------------------------Installation--------------------------------------# 
echo "Installing LLVM/libcxx in the NuttX source tree"


echo "Copying source files into place"
filelist=`find libxx -type f`
for file in $filelist; do
  source_path=$(dirname $file)
  install -d ${nuttx_path}/${source_path} 
  if [ $? -ne 0 ]; then
    echo "Failed to copy over directoy ${nuttx_path}/${source_path}"
    exit 1
  fi
  
  install $file ${nuttx_path}/${file} 
  if [ $? -ne 0 ]; then
    echo "Failed to copy over file ${nuttx_path}/${file}"
    exit 1
  fi
done


echo "Copying include files into place"
mkdir -p ${libcxx_incdir}
filelist=`find include -type f`
for file in $filelist; do
  include_path=$(dirname $file)
  install -d ${nuttx_path}/${include_path} 
  if [ $? -ne 0 ]; then
    echo "Failed to copy over directoy ${nuttx_path}/${include_path}"
    exit 1
  fi
  
  install $file ${nuttx_path}/${file} 
  if [ $? -ne 0 ]; then
    echo "Failed to copy over file ${nuttx_path}/${file}"
    exit 1
  fi
done

echo "Applying necessary patches to NuttX"
patchlist=`find nuttx_patches -type f`
cd ${nuttx_path}
for patch in $patchlist; do
  git apply ${script_dir}/$patch
  if [ $? -ne 0 ]; then
    echo "Failed to apply patch ${script_dir}/${patch}"
    cd ${script_dir}
    exit 1
  fi
done
cd ${script_dir}

#---------------------------Config Installation-------------------------------------# 

echo "Copying configurations into NuttX source tree"

config_list=`find configs -type d -mindepth 2`
for config in $config_list; do
  if [ -d ${nuttx_path}/$config ]; then
    echo "Configuration $config already exists in the NuttX tree, skipping"
  else
    echo "Copying $config into NuttX tree"
    file_list=`find $config -type f`
    for file in $file_list; do
      config_dir=$(dirname $file)
      
      install -d ${nuttx_path}/${config_dir}      
      if [ $? -ne 0 ]; then
        echo "Failed to copy over directoy ${nuttx_path}/${config_dir}"
        exit 1
      fi
  
      install $file ${nuttx_path}/${file} 
      if [ $? -ne 0 ]; then
        echo "Failed to copy over file ${nuttx_path}/${file}"
        exit 1
      fi

    done

  fi

done



echo "Installation suceeded"
echo ""
