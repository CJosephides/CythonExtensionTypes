# Python extension types with Cython

We can create extenion types for python using cython's `cdef class` statement. Practically, a `cdef` class has fast C-level access to all methods and data. By-passing the python layer in this way makes working with extension types fast.
