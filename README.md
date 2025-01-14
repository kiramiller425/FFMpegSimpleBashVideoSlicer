# FFMpegSimpleBashVideoSlicer
A bash script which utilizes FFMPEG to slice up MPG and MP4 videos quickly. 

The output files are always in .MP4 format.
Tested on Linux.

# Instructions

1. Make sure you already have FFMPEG already installed on your machine.
2. Download this tool onto your machine, and open bash in the same directory.
3. Review your video and note the exact times where you would like to make slices/cuts.
4. To run this tool, type in the command in this format:
```
./FFMpegSimpleBashVideoSlicer.sh originalVideoFileLocation totalTimeOfOriginalVideo slicePoint1 \[... slicePoint10\]
```
Here is a sample call with 3 slice points. This will produce 4 new videos:
```
./FFMpegSimpleBashVideoSlicer.sh /home/myVid.mpg 2:30:00.0 0:08:01.0 1:04:10.0 1:49:20.0 
```
