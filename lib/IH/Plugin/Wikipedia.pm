package IH::Plugin::Wikipedia;

use strict;
use 5.008_005;
our $VERSION = '0.01';
use Moose;
use IH::Schema::Mongo::Trigger;
use WWW::Google::AutoSuggest;
use WWW::Wikipedia;

extends 'IH::Plugin::Base';

sub search {
    my $self      = shift;
    my $Said      = shift;
    my $Phrase    = join( " ", @{ $Said->result } );
    my $Wikipedia = WWW::Wikipedia->new(
        language => $self->Config->DBConfiguration->{'language'} );
    my $result = $Wikipedia->search($Phrase);
    if ( $result->text ) {
        $self->Parser->Output->info( $result->text );    #needs strip
    }
    else {
        my $Suggest = WWW::Google::AutoSuggest->new();
        $result = $Wikipedia->search( $Suggest->search($Phrase)[0] );
        if ( $result->text ) {
            $self->Parser->Output->info( $result->text );    #needs strip
        }
        else {
            $Wikipedia->search(
                join( "\n",
                    map { $_ = uc( substr( $_, 0, 1 ) ) . substr( $_, 1 ) }
                        @{ $Said->result } )
            );
            $self->Parser->Output->info( $result->text ) if ( $result->text );

        }

    }

}

sub install {
    my $self = shift;
    $self->Parser->Backend->installPlugin(
        {   trigger       => 'wikipedia\s+(.*?)',
            plugin        => "Wikipedia",
            plugin_method => "search"
        }
    );

}

sub remove {
    my $self = shift;
    $self->Parser->Backend->removePlugin(
        {   trigger       => 'wikipedia\s+(.*?)',
            plugin        => "Wikipedia",
            plugin_method => "search"
        }
    );
}

sub update {

}

1;
__END__

=encoding utf-8

=head1 NAME

IH::Plugin::Wikipedia - Blah blah blah

=head1 SYNOPSIS

  use IH::Plugin::Wikipedia;

=head1 DESCRIPTION

IH::Plugin::Wikipedia is

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=head1 COPYRIGHT

Copyright 2014- mudler

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
