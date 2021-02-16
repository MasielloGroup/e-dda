import numpy as np
shape = np.loadtxt('shape.dat',skiprows=7)
shape_points = shape[:,2:4]

def unique():
	'''Because Mox has out of date numpy and I can't use axis argument for np.unique
	'''
	# shape_points_un = np.unique(shape_points,axis=0)
	x = np.random.rand(shape_points.shape[1])# unique()
	y = shape_points.dot(x)
	unique, index = np.unique(y, return_index=True)
	shape_points_un = shape_points[index]
	return shape_points_un

def find_raster(extent, raster_ss):
	'''Find all the points within a 2D area that are not a shape point 
	'''
	shape_points_un = unique()
	specimg_ymin = min(shape_points_un[:,0])-extent
	specimg_ymax = max(shape_points_un[:,0])+extent
	specimg_zmin = min(shape_points_un[:,1])-extent
	specimg_zmax = max(shape_points_un[:,1])+extent

	yrange = np.arange(specimg_ymin, specimg_ymax,raster_ss)
	zrange = np.arange(specimg_zmin, specimg_zmax,raster_ss)
	ygrid, zgrid = np.meshgrid(yrange, zrange)
	ypoints = np.ravel(ygrid); zpoints = np.ravel(zgrid)
	spec_grid = np.column_stack((ypoints, zpoints))
	spec_points = np.zeros((len(spec_grid),2))

	count = 0
	for line in range(0, len(spec_grid)):
		idx = np.where( (shape_points_un == spec_grid[line,:]).all(axis=1) )
		if not idx[0]: # if idx = [], this means it's not in the shape file
			spec_points[count,:] =  spec_grid[line,:]
			count=count+1
	spec_points_trmed = spec_points[:count,:]
	print(str('Number of folders created: ') + str(len(spec_points_trmed)))
	file = open(str('run_these_points.txt'),'w')

	count = 0
	for i in range(0, len(spec_points_trmed)):
		file.write(str(int(spec_points_trmed[i,0])) + '\t' + str(int(spec_points_trmed[i,1])) + '\n')
		count = count+1
	file.close()
#        return specimg_ymin, specimg_ymax, specimg_zmin, specimg_zmax
