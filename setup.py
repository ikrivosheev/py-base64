import os
import shutil
import subprocess

from setuptools import setup, Extension, Command
from setuptools.command.sdist import sdist as sdist
from setuptools.command.build_ext import build_ext as build_ext


BASE_DIR = os.path.abspath(os.path.dirname(__file__))
BUILD_DIR = os.path.join(BASE_DIR, 'vendor', 'build')
VENDOR_DIR = os.path.join(BASE_DIR, 'vendor', 'base64')
INSTALL_DIR = os.path.join(BASE_DIR, 'vendor', 'install')
LIBRARY_DIR = os.path.join(INSTALL_DIR, 'static')
INCLUDE_DIR = os.path.join(INSTALL_DIR, 'include')
CMAKE_OPTIONS = [
    '-DCMAKE_BUILD_TYPE=Release', 
    '-DB64_STREAM_BUILD_TESTS=OFF', 
    '-DB64_STREAM_BUILD_EXE=OFF', 
    '-DCMAKE_POSITION_INDEPENDENT_CODE=ON',
]


class b64_stream_build_ext(build_ext):
    user_options = build_ext.user_options + [
        ('cython-force', None, 'run cythonize() force'),
    ]

    boolean_options = build_ext.boolean_options + ['cython-force']

    def initialize_options(self):
        super().initialize_options()
        self.cython_force = False
        self._cmake_options = []
    
    def finalize_options(self):
        need_cythonize = self.cython_force
        cfiles = {}
        
        for extension in self.distribution.ext_modules:
            for i, sfile in enumerate(extension.sources):
                if sfile.endswith('.pyx'):
                    prefix, ext = os.path.splitext(sfile)
                    cfile = prefix + '.c'

                    if os.path.exists(cfile) and not self.cython_force:
                        extension.sources[i] = cfile
                    else:
                        if os.path.exists(cfile):
                            cfiles[cfile] = os.path.getmtime(cfile)
                        else:
                            cfiles[cfile] = 0
                        need_cythonize = True
        
        if need_cythonize:
            try:
                import Cython
                from distutils.version import LooseVersion
            except ImportError:
                raise RuntimeError(
                    'please install Cython to compile uvloop from source')

            if LooseVersion(Cython.__version__) < LooseVersion('0.28'):
                raise RuntimeError(
                    'uvloop requires Cython version 0.28 or greater')

            from Cython.Build import cythonize

            self.distribution.ext_modules[:] = cythonize(self.distribution.ext_modules)
    
        super().finalize_options()

    def _build_lib(self):
        if os.path.exists(INSTALL_DIR):
            shutil.rmtree(INSTALL_DIR)
        if os.path.exists(BUILD_DIR):
            shutil.rmtree(BUILD_DIR)
        os.mkdir(BUILD_DIR)
        cmake_options = ['-DCMAKE_INSTALL_PREFIX={}'.format(INSTALL_DIR)]
        subprocess.run(['cmake'] + cmake_options + CMAKE_OPTIONS + [VENDOR_DIR], cwd=BUILD_DIR, check=True)
        subprocess.run(['cmake', '--build', '.', '--target', 'install'], cwd=BUILD_DIR, check=True)
    
    def build_extensions(self):
        self._build_lib()
        super().build_extensions()


class b64_stream_sdist(sdist):
    pass


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
    version='0.0.3',
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
        'sdist': b64_stream_sdist,
        'build_ext': b64_stream_build_ext,
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
