import os
import shutil
import subprocess

from setuptools import setup, Extension

from Cython.Build import cythonize
from Cython.Distutils import build_ext as build_ext_orig

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
BUILD_DIR = os.path.join(BASE_DIR, 'build')
LIBRARY_DIR = os.path.join(BASE_DIR, 'vendor', 'base64')

INCLUDE_DIR = os.path.join(BASE_DIR, 'vendor', 'base64', 'include')


class build_ext(build_ext_orig):
    def build_lib(self):
        if os.path.exists(BUILD_DIR):
            shutil.rmtree(BUILD_DIR)
        os.mkdir(BUILD_DIR)
        cmake_args = [
            '-DCMAKE_BUILD_TYPE=Release',
            '-DB64_STREAM_BUILD_TESTS=OFF'
        ]
        subprocess.run(['cmake'] + cmake_args + [LIBRARY_DIR], cwd=BUILD_DIR, check=True)
        subprocess.run(['cmake', '--build', '.'], cwd=BUILD_DIR, check=True)

    def build_extensions(self):
        lib_path = os.path.join(BUILD_DIR, 'libb64_stream.a')
        if not os.path.exists(lib_path):
            self.build_lib()

        self.compiler.add_library('b64_stream')
        self.compiler.add_library_dir(BUILD_DIR)
        self.compiler.add_include_dir(INCLUDE_DIR)

        super().build_extensions()


extensions = [
    Extension('b64_stream.wrapper', ['b64_stream/wrapper.pyx']),
]

setup(
    name='b64_stream',
    description='Base64 stream encode/decode library',
    url='https://github.com/ikrivosheev/py-base64',
    license='Apache 2',
    author='Ivan Krivosheev',
    author_email='py.krivosheev@gmail.com',
    packages=['b64_stream'],
    python_requires=">=3.5",
    include_package_data=True,
    ext_modules=cythonize(extensions),
    cmdclass={
        'build_ext': build_ext,
    }
)
