# Python extension types with Cython

We can create extenion types for python using cython's `cdef class` statement. Practically, a `cdef` class has fast C-level access to all methods and data. By-passing the python layer in this way makes working with extension types fast.

## Creating an extension type

For example, convert

```
class Particle:
    """Simple Particle type."""

    def __init__(self, m, p, v):
        self.mass = m
        self.position = p
        self.velocity = v

    def get_momentum(self):
        return self.mass * self.velocity
```

into

```
cdef class Particle:
    """Simple Particle type."""

    cdef mass, position, velocity

    def __init__(self, m, p, v):
        self.mass = m
        self.position = p
        self.velocity = v

    def get_momentum(self):
        return self.mass * self.velocity
```

Note how we `cdef`ined the mass, position, and velocity attributes. In spite of appearances, these are not class-level attributes; rather, they are C-level instance attributes. We would get a runtime exception if we tried to assign to any of these attributes without first declaring them.

Note that we are not able to access any of the extension type's attributes when we have an instance of it, nor can we add new attributes! When an extension type is instantiated, a C struct is allocated and initialized; however, this requires that the struct's fields and their size are known at compile time. In contract, when a python class is instantiated, a dynamic python dictionary is created to hold the instance's attributes.

## Type attributes and access control

When we access an instance's attribute, like `self.mass`, in a normal python class, the interpreter goes through a general lookup process to determine that this attribute is and where it is defined. For example, is it an attribute or a method? Is it defined in this class, or in a parent? This indirection comes at a performance penalty.

Methods defined in `cdef class` extension types, on the other hand, have low-level access to C-struct fields, which allows them to bypass indirection lookups.

When we want to be able to inspect these attributes, we can use the declaration statement `cdef readonly mass`. If we want to make an attribute both readable and writeable from python, we can use the statement `cdef public double position, velocity`.

## C-level initialization and finalization

When python calls `__init__`, the `self` argument is required to be a valid instance of that (extension) type. At the C-level, before `__init__` is called, the instance's struct must be allocated. Cython adds a special method, `__cinit__`, whose responsibility is to perform C-level allocation and initialization.

It is fine to use `__init__` for our simple Particle extension, but we want to avoid a situation where `__init__` may be called multiple times. This can happen, for example, when we have alternative constructors or class children. So, Cython guarantees that `__cinit__` is called only once per instance, and that it is called before `__init__`, `__new__`, or alternative python constructors.

Suppose we have an extension type that, as part of its initialization, needs to dynamically allocate some memory on the heap.

```
from libc.stdlib cimport malloc, free

cdef class Matrix:

    cdef:
        unsigned int nrows, ncols
        double *_matrix

    def __cinit__(self, nr, nc):
        self.nrows = nr
        self.ncols = nc
        self._matrix = <double*>malloc(nr * nc * sizeof(double))
        if self._matrix == NULL:
            raise MemoryError()
```

Now Cython guarantees that memory for a Matrix instance is allocated always and exactly once, preventing segmentation faults and memory leaks.

To finalize, usually to free memory, we define the `__dealloc__` method:

```
def __dealloc__(self):
    if self._matrix != NULL:
        free(self._matrix)
```

## cdef and cpdef methods

* We cannot use `cdef` and `cpdef` methods on non-`cdef` classes.
* `cdef` methods have C calling semantics, just as `cdef` functions do. This means that all arguments are passed in as-is without any type mapping from python to C. Therefore, a `cdef` method is only accessible from other Cython code and cannot be called from Python.

A `cpdef` method is particularly useful when we want to call it from both external Python code and from other Cython code. When called from Cython, no conversion between Python and C "objects" is needed. However, the argument and return types have to be automatically convertible to and from Python objects, respectively, which restrict the allowed types somewhat. Importantly, this means we cannot use pointer types.

For example, we can declare the `get_momentum` method as:

`cpdef double get_momentum(self)`

### Adding type information

Consider two versions of momentum adders:

```
def add_momentums(particles):
    """Return the sum of particles' momentums."""
    total_mom = 0.
    for particle in particles:
        total_mom += particle.get_momentum()
    return total_mom

def add_momentums_typed(list particles):
    """Typed momentum summer."""
    cdef:
        double total_mom = 0.
        Particle particle
    for particle in particles:
        total_mom += particle.get_momentum()
    return total_mom
```

For 1,000 particles, the first takes 65us; the second takes 5.5us. In the latter case, no Python objects are involved. We can further squeeze some time out of the momentum adder by making `get_momentum` a `cdef`-only method, rather than `cpdef` method.

