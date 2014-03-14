# NAME

IH::Plugin::Wikipedia - Wikipedia plugin for Google@Home


# SYNOPSIS

	$ ./intellihome-master -i Wikipedia #for install
	$ ./intellihome-master -r Wikipedia #for remove

# DESCRIPTION

IH::Plugin::Wikipedia is a wikipedia plugin that enables searches on wikipedia by calling "Wikipedia <term>" on the interfaces supported by Google@Home

## METHODS

### search()
Takes input terms and process the Wikipedia research.
It reads coniguration from Config attribute (If you intend to use it separately to G@H you need to setup it properly).
The output is redirected to the parser output (to be dispatched on the correct node).

### install
Install the plugin into the mongo Database

### remove
Remove the plugin triggers from the mongo Database

# AUTHOR

mudler <mudler@dark-lab.net>

# COPYRIGHT

Copyright 2014- mudler

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

WWW::Wikipedia, WWW::Google::AutoSuggest