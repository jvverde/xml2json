Usage

using xalan

	$>xalan -in yourXMLSource.xml -xsl xml2json.xslt


Don't Normalize text nodes

	$>xalan -param normalize 0 -in yourXMLSource.xml -xsl xml2json.xslt


Include root node in the result 

	$>xalan -param includeRoot 1 -in yourXMLSource.xml -xsl xml2json.xslt

Include attributes of XMLSchema-instance namespace (http://www.w3.org/2001/XMLSchema-instance)  in the result<br> 

	$>xalan -param includexsiAttributes 1 -in yourXMLSource.xml -xsl xml2json.xslt

Include tag's prefix names in the result 

	$>xalan -param removeNS 0 -in yourXMLSource.xml -xsl xml2json.xslt

Define propertie's name for text nodes (by default the parent node name is used). Please note the doubles quotes around single quotes

	$>xalan -param textNodeName "'Content'" -in yourXMLSource.xml -xsl xml2json.xslt

Combining all the options

	$>xalan  -param normalize 0 -param includeRoot 1 -param includexsiAttributes 1 -param removeNS 0 -param textNodeName "'Content'" -in yourXMLSource.xml -xsl xml2json.xslt


Using the perl script attached (you may need to install some perl modules before using it)

	$>./xml2json.pl yourXMLSource.xml xml2json.xslt

Don't normalize text nodes

	$>./xml2json.pl -p normalize=0 yourXMLSource.xml xml2json.xslt

Using all the possible xsl parameters

	$>./xml2json.pl -p normalize=0 -p includeRoot=1 -p includexsiAttributes=1 -p removeNS=0 -p textNodeName="'Content'" yourXMLSource.xml xml2json.xslt




