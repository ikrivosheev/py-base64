import os
import shutil
import subprocess

from setuptools import setup, Extension, Command

from Cython.Build import build_ext

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
BUILD_DIR = os.path.join(BASE_DIR, 'vendor', 'build')
VENDOR_DIR = os.path.join(BASE_DIR, 'vendor', 'base64')
INSTALL_DIR = os.path.join(BASE_DIR, 'vendor', 'install')
LIBRARY_DIR = os.path.join(INSTALL_DIR, 'static')
INCLUDE_DIR = os.path.join(INSTALL_DIR, 'include')


class build_cmake(Command):
    user_options = []

    def initialize_options(self):
        self.args = []
        self.build_dir = None
        self.install_dir = None
        self.library_dir = None
    
    def finalize_options(self):
        if os.path.exists(self.build_dir):
            shutil.rmtree(self.build_dir)
        os.mkdir(self.build_dir)
        self.args.append('-DCMAKE_INSTALL_PREFIX={}'.format(self.install_dir))
    
    def build_lib(self):
        subprocess.run(['cmake'] + self.args + [self.library_dir], cwd=self.build_dir, check=True)
        subprocess.run(['cmake', '--build', '.', '--target', 'install'], cwd=self.build_dir, check=True)

    def run(self):
        self.build_lib()


extensions = [
    Extension(
        'b64_stream._b64_stream',
        ['b64_stream/_b64_stream.pyx'],
        libraries=['b64_stream'],
        library_dirs=[LIBRARY_DIR],
        include_dirs=[INCLUDE_DIR],
        language='c',
    ),
]

setup(
    name='b64-stream',
    version='0.0.2',
    description='Base64 stream encode/decode library',
    url='https://github.com/ikrivosheev/py-base64',
    license='Apache 2',
    author='Ivan Krivosheev',
    author_email='py.krivosheev@gmail.com',
    packages=['b64_stream'],
    python_requires=">=3.5",
    include_package_data=True,
    ext_modules=extensions,
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],
    cmdclass={
        'build_cmake': build_cmake,
        'build_ext': build_ext,
    },
    options={
        'build_cmake': {
            'build_dir': BUILD_DIR,
            'library_dir': VENDOR_DIR, 
            'install_dir': INSTALL_DIR,
            'args': ['-DCMAKE_BUILD_TYPE=Release', '-DB64_STREAM_BUILD_TESTS=OFF', '-DB64_STREAM_BUILD_EXE=OFF', '-DCMAKE_POSITION_INDEPENDENT_CODE=ON']

        },
    },
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',
        'License :: OSI Approved :: Apache Software License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
    ]
)
