if [$# = 1] # bash uses "=" for equality check in conditions, not "=="...
	cd $1
fi # now this is just silly.
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cd ..
cmake --build build