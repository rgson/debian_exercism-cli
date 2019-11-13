#!/usr/bin/zsh
set -e

orig=(exercism-cli_*.orig.tar.gz)
if [ -z $orig ]; then
	./download-latest.pl
	orig=(exercism-cli_*.orig.tar.gz)
else
	echo "Found $orig - skipping download"
fi

version=${${orig#exercism-cli_}%.orig.tar.gz}
echo "Version: $version"

mkdir "exercism-cli-$version"
cd "exercism-cli-$version"
tar xvzf ../$orig
cp -r ../debian .

debuild -us -uc
