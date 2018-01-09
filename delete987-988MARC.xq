xquery version "3.0";

(: Recursively reads MARCXML file(s) in jmunaco/export and blitzes any 987 or 988 datafields.  Update functions work without warning... :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

(:  import module namespace marc="http://freelibrary.info/xquery/marc"; :)


let $record := collection('/db/apps/jmunaco/export')
let $d := $record//marc:datafield[@tag="988"]
let $e := $record//marc:datafield[@tag="987"]

return 
    update delete ($d,$e)

