# Netica DNET file parser

    Usage: perl parse_dnet.pl /path/to/dnet/file

This will spit out a file called partial.dot and parsed_dnet.json.

partial.dot is a dot file, representing the partial order of the bayes net. With graphviz installed, you can run

    dot -o partial.png -Tpng partial.dot

and a png representation of the dot-graph will be generated. Have a look at http://www.graphviz.org/ for information on .dot file grammar and usage. For generating DGs or DAGs, dot is an excellent choice.

parsed_dnet.json is a serialization of the Perl object created by parsing the given .dnet file. It two main parts to it. All the nodes parsed from the .dnet file live in the "nodes" object, and all the derived data lives in the "meta" object. json is a portable and easily parsable object notation, so there should be no problems reading this in from any other language. Hint: 
http://jackson.codehaus.org/ is a good Java json parser.

## Dependencies
### perl JSON module
To find out how to install perl modules from cpan, read http://www.cpan.org/modules/INSTALL.html . Please heed the instructions telling you to install App::cpanminus. After cpanminus is installed, installing the JSON module is as simple as

    cpanm JSON

### GraphViz
