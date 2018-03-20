echo "#!/usr/bin/env bash" > ladetector

echo "LADETECTOR_PREFIX=$PREFIX/ladetector/" >> ladetector

echo "python \$LADETECTOR_PREFIX/ladetector.py -prefix \$LADETECTOR_PREFIX \"\$@\"" >> ladetector

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/ladetector

cp -r ladetector $PREFIX/bin
cp -r ./* $PREFIX/ladetector/
chmod +x $PREFIX/bin/ladetector
