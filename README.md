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
