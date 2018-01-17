# JHU/APL pubgeo
JHU/APL is committed to advancing the state of the art in geospatial computer vision by advocating for public data sets 
and open source software. For more information on this and other efforts, please visit [JHU/APL](http://www.jhuapl.edu/pubgeo.html).

## AnnoteGeo
Annotation tool for labeling GeoTIFF images
>AnnoteGeo is a Matlab based image annotation tool for manually creating classification labels for GeoTIFF images.

### Features: 
* Save, load, and edit image labels
* Keyboard and mouse shortcuts for efficient navigation and annotating
* Image data buffering for handling large images
* Configurable classification categories
* Export to KML for viewing on Google Earth
* Export to rasterized GeoTIFF or to MAT-file format
* ESRI Shapefiles can be imported into the tool (Needs to be referenced to same UTM zone as imagery)

#### Matlab Requirements
* Minimim Version:
 * R2014b

* Toolboxes
 * image_toolbox
 * map_toolbox

###  Usage
    >> run
    Start AnnoteGeo with no arguments. User will be prompted with a dialog box to selecte GeoTIFF image file for labeling
    
    >> run(IMAGE_FILE_PATH)
    Start AnnoteGeo using the supplied GeoTIFF filename
    
    >> run(IMAGE_DIRECTORY)
    Start AnnoteGeo with GeoTIFF file selector at the specified directory

See [help.md](@AnnoteGeo/help/help.md) for more info

### Note
Input imagery is expected to be a GeoTIFF georeferenced in UTM.

On tool initialization, occassionally a stream of error messages will appear that include the message below.
<br>This typically occurs when the mouse is moved over figures on startup and does not impact usage of the tool.
 
 > Reference to non-existent field 'jPixelPos'
   
 

