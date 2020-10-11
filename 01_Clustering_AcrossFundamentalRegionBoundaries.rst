Artificial grains and their clustering: Part 1
**********************************************
.. _01-Clustering:

This tutorial demonstrates density based clustering of crystal orientations with and without the application of symmetry using simulated data.

.. contents:: Table of Contents
    :depth: 2

Setup your environment
======================

Import orix classes and various dependencies
--------------------------------------------

Import core external
^^^^^^^^^^^^^^^^^^^^
>>> import numpy as np
>>> import matplotlib.pyplot as plt
>>> from sklearn.cluster import DBSCAN

Import orix classes
^^^^^^^^^^^^^^^^^^^
>>> from orix.quaternion.orientation import Orientation, Misorientation
>>> from orix.quaternion.rotation import Rotation
>>> from orix.quaternion.symmetry import Oh
>>> from orix.quaternion.orientation_region import OrientationRegion
>>> from orix.vector.neo_euler import AxAngle
>>> from orix import plot

Colorisation & Animation
^^^^^^^^^^^^^^^^^^^^^^^^
>>> from skimage.color import label2rgb
>>> from matplotlib.colors import to_rgb, to_hex
>>> import matplotlib.animation as animation
>>> plt.rc('font', size=6)


Generate artificial data
========================

Generate 3 random vonMises distributions as model clusters and set Oh symmetry
------------------------------------------------------------------------------

Set up data
^^^^^^^^^^^
Print some intermediate data to investigate how rotations are saved and what size they have.

>>> d1 = Orientation.random_vonmises(50, alpha=50)
>>> d2_0 = Rotation.from_neo_euler(AxAngle.from_axes_angles((1, 0, 0), np.pi/4))
>>> print('Rotation d2_0:',d2_0)
Rotation d2_0: Rotation (1,)
[[0.9239 0.3827 0.     0.    ]]
>>> d2 = Orientation.random_vonmises(50, alpha=50, reference=d2_0)
>>> print('length d2:',d2.size)
length d2: 50
>>> d3_0 = Rotation.from_neo_euler(AxAngle.from_axes_angles((1, 1, 0), np.pi/3))
>>> d3 = Orientation.random_vonmises(50, alpha=50, reference=d3_0)
>>> dat = Orientation.stack([d1, d2, d3]).flatten().set_symmetry(Oh)


Orientation clustering
======================

Perform clustering without application of crystal symmetry
----------------------------------------------------------

Compute misorientations, i.e. distance between orientations

>>> D = (~dat).outer(dat).angle.data
>>> # Perform clustering
>>> dbscan_naive = DBSCAN(0.3, 10, metric='precomputed').fit(D)
>>> print('Labels of clusters without accounting for crystal symmetry:', np.unique(dbscan_naive.labels_))
Labels of clusters without accounting for crystal symmetry: [0 1 2 3 4 5]

Perform clustering with application of crystal symmetry
-------------------------------------------------------

Compute misorientations, i.e. distance between orientations, with symmetry

>>> D = Misorientation((~dat).outer(dat)).set_symmetry(Oh,Oh).angle.data
>>> # Perform clustering
>>> dbscan = DBSCAN(0.3, 20, metric='precomputed').fit(D)
>>> print('Labels of clusters with accounting for crystal symmetry:', np.unique(dbscan.labels_))
Labels of clusters with accounting for crystal symmetry: [0 1 2]

This should have shown that without symmetry there are 6 clusters, whereas with symmetry there are 3.


Visualisation
=============
Orientation: axis-angle plot with the gray mesh showing the orientation region.

Define colors according to each cluster.

>>> colors = [to_rgb('C{}'.format(i)) for i in range(10)]  # ['C0', 'C1', ...]
>>> c = label2rgb(dbscan.labels_, colors=colors)
>>> c_naive = label2rgb(dbscan_naive.labels_, colors=colors)

Specify fundamental zone based on symmetry

>>> fr = OrientationRegion.from_symmetry(Oh)

Generate plot/figure
>>> fig = plt.figure(figsize=(12, 7))

This is the left hand plot

>>> ax1 = fig.add_subplot(121, projection='axangle', aspect='equal')
>>> ax1.scatter(dat, c=c_naive)    #doctest: +ELLIPSIS
<mpl_toolkits.mplot3d.art3d.Path3DCollection object at...
>>> ax1.plot_wireframe(fr, color='gray', alpha=0.5, linewidth=0.5, rcount=30, ccount=30)     #doctest: +ELLIPSIS
<mpl_toolkits.mplot3d.art3d.Line3DCollection...
>>> ax1.set_axis_off()
>>> ax1.set_xlim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax1.set_ylim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax1.set_zlim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax1.set_title('Naive coloring')
Text(0.5, 0.92, 'Naive coloring')

This is the right hand plot

>>> ax2 = fig.add_subplot(122, projection='axangle', aspect='equal')
>>> ax2.scatter(dat, c=c)            #doctest: +ELLIPSIS
<mpl_toolkits.mplot3d.art3d.Path3DCollection object...
>>> ax2.plot_wireframe(fr, color='gray', alpha=0.5, linewidth=0.5, rcount=30, ccount=30)  #doctest: +ELLIPSIS
<mpl_toolkits.mplot3d.art3d.Line3DCollection...
>>> ax2.set_axis_off()
>>> ax2.set_xlim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax2.set_ylim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax2.set_zlim(-0.8, 0.8)
(-0.8, 0.8)
>>> ax2.set_title('With crystal symmetry coloring')
Text(0.5, 0.92, 'With crystal symmetry coloring')

Generate an animation of the plot

>>> def animate(angle):
...     ax1.view_init(15, angle)
...     ax2.view_init(15, angle)
...     plt.draw()

>>> plt.tight_layout()
>>> ani = animation.FuncAnimation(fig, animate, np.linspace(75, 360+74, 720), interval=100)
>>> plt.show()  #doctest: +SKIP


Trap: make sure doctest catches mistakes
========================================
>>> 1+1
3


