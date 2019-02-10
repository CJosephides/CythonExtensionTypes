"""
setup.py
"""

from distutils.core import setup, Extension
from Cython.Build import cythonize

ext = Extension("cparticle",
                ["cparticle.pyx"])

setup(name="cparticle",
      ext_modules=cythonize(ext, annotate=True))
