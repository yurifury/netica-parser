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

sub create_ordered_hash {
    my $self = shift;

    my %ordering = ();
    foreach my $node (sort keys %{$self}) {
        next if $node =~ /^_/;
        if (defined $self->{$node}->{parents}) {
            foreach my $parent (@{$self->{$node}->{parents}}) {
                push @{$ordering{$node}}, $parent;
                #print "${node}'s parent is $parent\n";
            }
        }
    }
    return %ordering;
}
1;
