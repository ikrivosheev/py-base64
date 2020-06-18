#!/bin/bash

set -e

wheelhouse="/tmp/wheel/"

pip install twine wheel
pip wheel . --wheel-dir "$wheelhouse"

# Bundle external shared libraries into the wheels.
for whl in "$wheelhouse"/*; do
    auditwheel repair --plat="manylinux2014_x86_64" $whl -w "$wheelhouse"
    rm "$wheelhouse"/*-linux_*.whl
done

python setup.py sdist
twine upload upload dist/*.whl dist/*.tar.*
