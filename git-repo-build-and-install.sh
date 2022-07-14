if [ "$#" -lt 3 ] # bash uses "=" for equality check in conditions, not "=="...
then
	echo "Missing argument! use with <script> package git-repo-url branch"
else
	git clone -b $3 $2 $1-clone
	./build.sh $1-clone/ install
	$1 --version
fi
