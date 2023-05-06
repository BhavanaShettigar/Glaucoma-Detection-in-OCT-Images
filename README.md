# Glaucoma-Detection-in-OCT-Images
Glaucoma is a chronic condition that damages the optic nerve which leads to enduring visual impairment, if left untreated. The open angle glaucoma and the angle closure glaucoma are the two dominant categories of glaucoma with each having unique attributes. Among these two, angle closure glaucoma is a much rare class of glaucoma, developing quite rapidly as well as demanding medical treatment. It is caused when there is an increase in intraocular pressure. This intraocular pressure rises when the drainage canals in the eye are blocked. 

The data set images considered are preprocessed to take off noise from it.

Canny operator is used to detect edges which is then given to extract textural and clinical features from it. 

A hybrid approach is used to detect edges as edge detection plays a vital role in identifying glaucoma. 

This approach uses kirsch operator to detect edges, once canny edge operator is used. 

These edge detected images by kirsch operator are then used to extract features from it. 

These are then classified by applying k-nearest neighbor (KNN) and artificial neural network (ANN) classifier to categorize data set images into angle closure glaucoma and the images not affected by angle closure glaucoma.
