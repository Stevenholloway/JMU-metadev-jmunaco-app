xquery version "3.0";

(: runs an XSLT stored in eXist which changes a MARC collection to a single record, and saves it in the data directory with the filename taken from the 988$a  :)
(: Will only work on single files :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";


let $filename := collection("/db/apps/jmunaco/export/")//marc:datafield[@tag="988"]/marc:subfield[@code="a"]
let $input := collection("/db/apps/jmunaco/export/")
let $xsl := doc("/db/apps/jmunaco/modules/collection2record.xsl")
let $col2rec := transform:transform($input, $xsl, ())
let $nacofiles := xmldb:store("/db/apps/jmunaco/data/", $filename || '.xml', $col2rec)

return
    $nacofiles