if [ "$#" -gt 0 ] # bash uses "=" for equality check in conditions, not "=="...
then
	echo "(Building from folder: $1)"
	cd $1
fi # now this is just silly.
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cd ..
cmake --build build
if [ "$#" -gt 1 ] && [ $2 = "install" ]
then
	echo "Installing..."
	sudo cmake --install build
fi
