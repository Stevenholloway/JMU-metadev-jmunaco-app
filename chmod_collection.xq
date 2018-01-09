xquery version "3.0";

(: Uses dbutil to recurse through a collection and change file permissions by mime type :)

import module namespace dbutil = "http://exist-db.org/xquery/dbutil";

let $collection := "/db/apps/jmunaco/export"
let $perms := "rw-rw-r--"

return
    dbutil:scan(xs:anyURI($collection), function ($collection, $resource) {
        if ($resource and xmldb:get-mime-type($resource) = "application/xml") then
            (
            sm:chmod($resource, $perms)
            )
        else
            $collection, $perms
    })