# danina-data

Data repository for the Danina edition/translation compiled at the University of Bern in 2026.

Sources: [Zapiski bolʹnoj / Tatʹjana Danina](https://doi.org/10.7891/e-manuscripta-169904), [SOB RoEu ag 63](https://ube.swisscovery.ch/discovery/fulldisplay?docid=alma99117537399405511&context=L&vid=41SLSP_UBE:UBE)

## Status

Experimental

### Test data

* put Transkribus export in `transkribus-preprocess/input-file`
* run transformation (e.g. `java -jar /opt/Saxonica/SaxonHE13-0/saxon-he-13.0.jar -xsl:transkribus-preprocess.xsl -it`)
* processed outputs in `danina.xml`, `register.xml` and `facs` directory

## Plan

* agree on split units
* agree on entity handling
* adjust transformation
* test LEAF writer
* documentation/instruction of class