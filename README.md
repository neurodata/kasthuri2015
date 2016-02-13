# Reproducible Scalable Science

Currently, scientific research groups produce data in a variety of data formats and different conventions, making it difficult to share information across labs and reproduce results. 

We propose a foundational, flexible data standard for large-scale neuroscience data called RAMON (Reusable Annotation Markup for Open Neuroscience).  This serves as a key enabling technology for communication and data democratization.

## Converting Kasthuri2015 raw data to parsed NeuroData format Supplemental Methods

### Ingest Template

For ingesting data, we provide a simple csv format, organized as kv pairs by RAMONType.  For each RAMON Object, a number of standard fields are available to aid in standardization and efficient queries.  However, from an ingest perspective, 

#### Input data

- The raw image and annotation data was obtained as an export from VAST.  This contained both object IDs, names, and hierarcy information
- Separately, annotation labels were provided indicating synapse, mitochondria, and vesicle locations.
- A spreadsheet was provided with additional metadata

#### Data ingest

We ingested the data beginning with full xy png stacks exported from VAST.  Neurodata offers several methods to ingest data, including an auto-ingest process.  This process is described in [detail](http://docs.neurodata.io/open-connectome/sphinx/ingesting.html) elsewhere.

#### Semantic Understanding

The VAST metadata was combined with information in the Cell supplemental information spreadsheet to create a metadata about each object.  When feasible, object statistics were recomputed from the raw data.  We choose to do this process using MATLAB because the VAST scripts and data are most amenable to parsing using existing tools.  

From the spreadsheet, several important pieces of metadata were gleaned:

#### From synapse spreadsheet

- Associations of connections between neuronal processes
	- Mapping of synapse paint to synapse ID
	- Presynaptic bouton (or axon if not available)
	- Post synaptic spine (or shaft or dendrite as appropriate)
- Axon type (Excitatory, Inhibitory, Myelinated, Unknown)
- Axon terminal or en-passant
- Dendrite type
- Spine apparatus

#### From VAST data
- Raw image and annotation labels
- PSD centroids
- Cylinder location
- PSD size
- Single synapse spine
- Cylinder locations and masks
- Linkages between paint 

#### From VAST Metadata Export
- Object IDs
- Object Hierarchy
- Object names (not currently used)

#### From spreadsheet, but could be from data
*further development will compute these from data*

- Vesicle count 
- Number of mitochondria in axon bouton
- Multi synaptic axon bouton
- Axon skeleton length
- Spine synapse

### RAMONification

- Each object is identified by its unique Id - this serves as the primary key for the object.  We use RAMON types to make it easy for users to identify, store, and access the information.  For this paper, we primarily focus on the following types:
	- RAMONSegment:  Allows for individual neurites and other cell fragments to be identified
	- RAMONNeuron:  Container of RAMONSegments
	- RAMONSynapse:  Represents the paint and metadata associated with neuronal connections
	- RAMONOrganelle:  Used for capturing sub-cellular objects like mitochondria and vesicles

- We initially assign each object a RAMONType based on a somewhat manual parsing of the VAST hierarchy labels and names
- Object metadata is then assigned using a combination of pre-determined standard fields and extensible key-value pairs

All of this information is stored in NeuroData databases - we choose to store the data in four channels within a single unifying project (neurons, synapses, mitochondria, vesicles).  The original raw data are also available for provenance and to allow others to parse this data in other ways.
	
## Queries

Once all of the data is parsed, we are able to do reproducible, scalable scientific discovery!  To retrieve the parsed data from the databases, we offer solutions in MATLAB, Python, and via RESTful endpoint.  To illustrate the diversity of queries and to provide reproducible results from the Kasthuri paper, we have created ipython notebooks for each claim.  We use [ndio](https://github.com/openconnectome/ndio) to facilitate getting data.

A full list of claims will be provided with a more detailed explaination.  For now, the claims may be viewed [here](https://github.com/neurodata/kasthuri2015/tree/master/claims), and are under active development. 

**NeuroData now offers the capabilities to crete RAMON objects during the process of manual or automatic discovery and annotation.  Please contact us for details on how to organize your data so that your claims are reproducible and available to the community as part of your publication process.**


### Things that are easy and things that are hard

### Next steps
