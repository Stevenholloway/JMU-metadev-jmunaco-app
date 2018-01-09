xquery version "3.0";

(: database function selects all XML files from a directory in the file system and stores them in the jmunaco/data directory :)

declare namespace marc="http://www.loc.gov/MARC21/slim";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: must change URI to match file system :)
 
let $directoryName := '/Users/hollowswx/Desktop/JMU/NACO_App_Documentation/test_NARS'
let $files := xmldb:store-files-from-pattern('/db/apps/jmunaco/data/', $directoryName, '*.xml')

return
    $files