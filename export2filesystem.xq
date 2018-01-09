xquery version "3.0";

(: Saves all files in the export directory to the specified local directory :)
for $doc in collection('/db/apps/jmunaco/export')
let $filename := util:document-name($doc)
let $target-directory := '/Users/hollowswx/Desktop/JMU/LET/'
let $target-path := concat($target-directory, $filename)
return
    file:serialize($doc, $target-path, ("omit-xml-declaration=yes", "indent=yes"))