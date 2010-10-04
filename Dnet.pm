use warnings;
use strict;

package Dnet;
sub new {
    my $self = {};
    bless $self;
    return $self;
}

sub list_priors {
    my $self = shift;
    my @priors = ();
    use Data::Dumper;
    foreach my $node (sort keys %{$self}) {
        print "$node\n";
        $self->{$node};
        #print Dumper $self->{$node}->{parents};
        #if (defined $self->{$node}->{parents}
                #and @{$self->{$node}->{parents}} == 0) {
            #push @priors, $node;
        #}
    }
    return @priors;
}
1;
