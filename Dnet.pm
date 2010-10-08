use warnings;
use strict;
use Data::Dumper;

package Dnet;
sub new {
    my $self = {};
    bless $self;
    return $self;
}

sub list_priors {
    my $self = shift;
    my @priors = ();
    foreach my $node (sort keys %{$self}) {
        next if $node =~ /^_/;
        if (defined $self->{$node}->{parents}
                and @{$self->{$node}->{parents}} == 0) {
            push @priors, $node;
        }
    }
    return @priors;
}
1;
