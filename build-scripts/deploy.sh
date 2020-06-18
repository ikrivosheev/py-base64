#!/bin/bash

set -e

pip install twine wheel auditwheel
python setup.py sdist bdist_wheel

# Bundle external shared libraries into the wheels.
for whl in dist/*.whl; do
    auditwheel repair --plat="manylinux2014_x86_64" $whl -w dist/
    rm dist/*-linux_*.whl
done

twine upload --skip-existing dist/*.whl dist/*.tar.*

