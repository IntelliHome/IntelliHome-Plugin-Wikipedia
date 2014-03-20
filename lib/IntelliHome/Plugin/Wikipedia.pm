package IntelliHome::Plugin::Wikipedia;

=encoding utf-8

=head1 NAME

IntelliHome::Plugin::Wikipedia - Wikipedia plugin for Google@Home

=head1 SYNOPSIS

  $ ./intellihome-master -i Wikipedia #for install
  $ ./intellihome-master -r Wikipedia #for remove

=head1 DESCRIPTION

IntelliHome::Plugin::Wikipedia is a wikipedia plugin that enables searches on wikipedia by calling "Wikipedia <term>" on the interfaces supported by Google@Home

=head1 METHODS

=over

=item search

Takes input terms and process the Wikipedia research.
It reads coniguration from Config attribute (If you intend to use it separately to G@H you need to setup it properly).
The output is redirected to the parser output (to be dispatched on the correct node).

=item install
Install the plugin into the mongo Database

=item remove
Remove the plugin triggers from the mongo Database

=back 

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=head1 COPYRIGHT

Copyright 2014- mudler

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO
L<WWW::Wikipedia>, L<WWW::Google::AutoSuggest>

=cut

use strict;
use 5.008_005;
our $VERSION = '0.02';
use Moose;
use WWW::Google::AutoSuggest;
use WWW::Wikipedia;
use Encode;
use HTML::Strip;
use Regexp::Common qw/URI/;

extends 'IntelliHome::Plugin::Base';

sub search {
    my $self      = shift;
    my $Said      = shift;
    my $Phrase    = join( " ", @{ $Said->result } ); 
    my $Wikipedia = WWW::Wikipedia->new(
        language => $self->Config->DBConfiguration->{'language'} );
    my $result = $Wikipedia->search($Phrase);
    my $hs     = HTML::Strip->new();
    my $Output;
    if ($result) {

        $Output = $result->text;

    }
    else {
        my $Suggest = WWW::Google::AutoSuggest->new();
        $result = $Wikipedia->search( @{ $Suggest->search($Phrase) }[0] );
        if ( $result->text ) {
            $Output = $result->text;
        }
        else {
            $result = $Wikipedia->search(
                join( " ",
                    map { $_ = uc( substr( $_, 0, 1 ) ) . substr( $_, 1 ) }
                        @{ $Said->result } )
            );
            $Output = $result->text    #needs strip
                if ($result);

        }

    }
    if ($Output) {
        $Output = $hs->parse($Output);
        $Output =~ tr {\n} { };
        $Output =~ s/\{.*?\}|\[.*?\]|$RE{URI}{HTTP}//g;
        $Output =~ s/[\[|\[\[](.*?)[\]|\]\]]/$1/g;
        $Output =~ s/\{|\}|\[|\]/ /g;
        local $/;
        my @Speech = $Output =~ m/(.{1,150}\W)/gs;
        $self->Parser->Output->info( join( " ", @Speech ) );
        $self->Parser->Output->debug( join( " ", @Speech ) );
        $hs->eof;
    }

}

sub install {
    my $self = shift;

    ############## MONGODB ##############
    $self->Parser->Backend->installPlugin(
        {   regex         => 'wikipedia\s+(.*)', #We have one global match here 
            plugin        => "Wikipedia",
            plugin_method => "search"
        }
    ) if $self->Parser->Backend->isa("IntelliHome::Parser::DB::Mongo");
    #####################################
}

sub remove {
    my $self = shift;

    ############## MONGODB ##############
    $self->Parser->Backend->removePlugin(
        {
            plugin        => "Wikipedia",
        }
    ) if $self->Parser->Backend->isa("IntelliHome::Parser::DB::Mongo");
    #####################################
}

###We don't define update because default behaviour: remove() and install() it's enough
1;
__END__
