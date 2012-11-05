Cube
================
[![Build Status](https://travis-ci.org/drKreso/cube.png)](https://travis-ci.org/drKreso/cube)

Talk to the OLAP based backend via XMLA SOAP messages from Ruby.
You can send (simple) MDX queries and get the result back in a human friendly from. 

When harnesing OLAP power you are one tiny step away from graphs like this (highcharts.js)

![Example data visualisation](https://github.com/drKreso/cube/raw/master/doc/example.png)
##
  

Installation
------------
Add to Gemfile

```
gem 'cube'
```

Configuration
--------------
Set up your catalog and endpoint

```
XMLA.configure do |c|
 c.catalog = "OUTAGE"
 c.endpoint = "http://localhost:8383/mondrian/xmla"
end
```

Querying the OLAP
-------
```
table = XMLA::Cube.execute <<-MDX
    SELECT [Location].[City].children  on COLUMNS,
           [Measures].[Count] on ROWS
    FROM [OUTAGE]"
MDX
```
Table has two attributes: header and rows.

Scalar results
-----------
```
average_mtbf = XMLA::Cube.execute_scalar <<-MDX
   SELECT {Hierarchize({[Measures].[MTBF]})} ON COLUMNS
   FROM [OUTAGE]
   WHERE [Country].[Croatia]
MDX
```

Limitations
------------
* No drill down (fails to even parse the result)
* No multi named columns
* Tested only with icCube and Mondrian XMLA, in theory works with every XMLA provider

Contributing to cube
-------------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
----------

Copyright (c) 2012 drKreso. See LICENSE.txt for
further details.

