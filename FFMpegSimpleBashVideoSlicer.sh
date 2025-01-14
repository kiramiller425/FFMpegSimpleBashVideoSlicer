#!/bin/bash
# ***********************
# Author: Kira Miller
# https://github.com/kiramiller425/FFMpegSimpleBashVideoSlicer
# Run this in bash. It will make cuts at the given slicePoint times in the original video. The general format is:
# ./FFMpegSimpleBashVideoSlicer.sh originalVideoFileLocation totalTimeOfOriginalVideo slicePoint1 [... slicePoint10]
# Here is a sample call:
# ./FFMpegSimpleBashVideoSlicer.sh /home/myVid.mpg 10:00:00.0 5:04:00.0 3:09:00.0 
# The output files will be .mp4 types.
# ***********************
totalNumberOfArguments=$#
if [ $totalNumberOfArguments -lt 3 ]; then
  echo "Not enough arguments given"
  exit 0
fi

totalNumberOfSlicePoints=$(($totalNumberOfArguments-2))
totalNumberOfSubVideos=$(($totalNumberOfArguments-1))
originalVideoFileLocation=$1
totalTimeOfOriginalVideo=$2
typeOfOriginalFile=${originalVideoFileLocation: -3}
nextVideoFileName="${originalVideoFileLocation}1.mp4"
mp4Type="mp4"
mpgType="mpg"
currentSourceVideoFileLocation=$1

echo "****************"
echo "Begin Program:"
echo "****************"
echo "$totalNumberOfSlicePoints slice points given"
echo "$totalNumberOfSubVideos sliced videos to create"
echo "original = $originalVideoFileLocation and time = $totalTimeOfOriginalVideo to create this = $nextVideoFileName"

if [[ "$typeOfOriginalFile" == "$mpgType" ]]; then
  # If the input file is a .mpg then convert to mp4 first:
  echo "Original file is MPG type: $typeOfOriginalFile converting to mp4:"
  currentSourceVideoFileLocation="$originalVideoFileLocation.mp4"
  ffmpeg -ss 00:00:00.0 -i $originalVideoFileLocation -c:v copy -c:a copy -fflags +genpts -t $totalTimeOfOriginalVideo -f dvd $currentSourceVideoFileLocation
elif [[ "$typeOfOriginalFile" == "$mp4Type" ]]; then
  echo "Original file is MP4 type: $typeOfOriginalFile"
else
  echo "Unknown file type: $typeOfOriginalFile. Cannot continue."
  exit 0
fi

# Add all the slice points to array:
arrayOfSlicePoints=()
for var in "$@"
do
  if [[ "$originalVideoFileLocation" != "$var" ]] && [[ "$totalTimeOfOriginalVideo" != "$var" ]]; then
    echo "$var"
    arrayOfSlicePoints+=("$var")
  fi
done

# This will hold the names of the temp files, which will allow for easy clean up later:
tempFilesToDeleteList=()

# Start at the last slice point. Then work our way back to the first slice point:
for ((i=$totalNumberOfSlicePoints-1; i>=0; i--)); do

  # Set the name of the new sliced video:
  videoNumber=$(($i+1))
  sliceVideoFileName="$originalVideoFileLocation.slice$videoNumber.mp4"
  
  # Copy the last slice of this video into it's own video:
  ffmpeg -ss ${arrayOfSlicePoints[i]} -i $currentSourceVideoFileLocation -c:v copy -c:a copy $sliceVideoFileName

  # Create the new source video's filename:
  newSourceFileLocation="$currentSourceVideoFileLocation.$i.mp4"
  
  # Add it to the clean up list if it is not the last one:
  if [[ "$i" != "0" ]]; then
    tempFilesToDeleteList+=("$newSourceFileLocation")
  fi

  # Slice off the last part, keeping the beginning, and copy it into a new video to use as the new source:
  ffmpeg -ss 00:00:00.0 -i $currentSourceVideoFileLocation -c:v copy -c:a copy -t ${arrayOfSlicePoints[i]} $newSourceFileLocation
  
  # Set next source file's name:
  currentSourceVideoFileLocation=$newSourceFileLocation
  
done

# Rename the current source file as the first slice:
mv $currentSourceVideoFileLocation "$originalVideoFileLocation.slice0.mp4"

# Delete and cleanup most of the temp files:
for ((i=0; i<=$totalNumberOfSlicePoints-2; i++)); do
  rm -f ${tempFilesToDeleteList[i]}
done
