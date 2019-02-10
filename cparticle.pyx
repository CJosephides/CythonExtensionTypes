"""
cparticle.pyx
"""

cdef class Particle:
    """Simple Particle type."""

    cdef readonly mass
    cdef public position, velocity

    def __init__(self, m, p, v):
        self.mass = m
        self.position = p
        self.velocity = v

    def get_momentum(self):
        return self.mass * self.velocity
