xquery version "3.0";

(: copies the contents of jmunaco/data to jmunaco/data-archive & jmunaco/export, renames subcollections with the department name, and empties the data directory :)

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: moves the collections into different directories, removes the data directory, and then creates a new empty data directory :)


let $data := xmldb:copy('/db/apps/jmunaco/data', '/db/apps/jmunaco/data-archive')
let $export := xmldb:move('/db/apps/jmunaco/data', '/db/apps/jmunaco/export')
let $remake-data := xmldb:create-collection('/db/apps/jmunaco','data')


(: rename the copied directories with the Department Name :)
 
for $dept-name in 'DEPARTMENT NAME'
let $archive := xmldb:rename('/db/apps/jmunaco/data-archive/data', $dept-name)
let $rename-export := xmldb:rename('/db/apps/jmunaco/export/data', $dept-name)

return ($data,$export,$archive,$rename-export,$remake-data)