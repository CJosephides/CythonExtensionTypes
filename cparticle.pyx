"""
cparticle.pyx
"""

cdef class Particle:
    """Simple Particle type."""

    cdef readonly double mass
    cdef public double position, velocity

    def __init__(self, m, p, v):
        self.mass = m
        self.position = p
        self.velocity = v

    cpdef double get_momentum(self):
        """Return the particle's momentum."""
        return self.mass * self.velocity

def add_momentums(particles):
    """Return the sum of particles' momentums."""
    total_mom = 0.
    for particle in particles:
        total_mom += particle.get_momentum()
    return total_mom

def add_momentums_typed(list particles):
    """Typed momentum summer."""
    cdef:
        double total_mom = 0.0
        Particle particle
    for particle in particles:
        total_mom += particle.get_momentum()
    return total_mom
