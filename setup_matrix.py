"""
setup_matrix.py
"""

from distutils.core import setup, Extension
from Cython.Build import cythonize

ext = Extension("cmatrix",
                ["cmatrix.pyx"])

setup(name="cmatrix",
      ext_modules=cythonize(ext))
