package Dnet;

use warnings;
use strict;
use Data::Dumper;
use Storable qw(dclone); 

sub new {
    my $self = {};
    bless $self;
    return $self;
}

sub parse {
    my $self = shift;

    my $in_node = 0;

    foreach (@_) {
        # If we've found a node, make a new node in dnet
        # Also get ready to pull this node's attributes
        if (/node (\S+)/) {
            my $node_name = $1;
            $in_node = $1;
            $self->{$1} = {};
        }
        # We're in the attributes of a node
        if ($in_node) {
            # Fields to ignore
            next if /comment|whenchanged|center|height/;
            # Parse a single key/value
            if (/(\S+) = (\S+)/) {
                $self->{$in_node}->{$1} = $2;
            }
            # Parse a list
            if (/(\S+) = (\((?:\S?,?\s*)+\))/) {
                #my @list = split /,/, $2;
                my $list = $self->parse_list($2);
                #print Dumper @list;
                $self->{$in_node}->{$1} = $list;
            }
        }
        # Set the name of the BN when we've found it
        if (/bnet (\S+)/) {
            $self->{_name} = $1;
        }
    }
    
    $self->{_nodes} = [];
    foreach my $node (sort keys %{$self}) {
        next if $node =~ /^_/;
        push @{$self->{_nodes}}, $node;
    }

    $self->{_roots} = [];
    foreach my $node (@{$self->{_nodes}}) {
        if (defined $self->{$node}->{parents}
                and @{$self->{$node}->{parents}} == 0) {
            push @{$self->{_roots}}, $node;
        }
    }

    $self->{_ordering} = {};
    foreach my $node (@{$self->{_nodes}}) {
        if (defined $self->{$node}->{parents}) {
            foreach my $parent (@{$self->{$node}->{parents}}) {
                push @{$self->{_ordering}->{$node}}, $parent;
            }
        }
    }

    my %leaves = map {$_ => 1} @{$self->{_nodes}};
    foreach my $node (@{$self->{_nodes}}) {
        foreach my $parent (@{$self->{_ordering}->{$node}}) {
            delete $leaves{$parent} if defined $leaves{$parent};
        }
    }
    @{$self->{_leaves}} = keys %leaves;

    %{$self->{_partial}} = map { $_ => [undef] } @{$self->{_leaves}};
    foreach my $node (@{$self->{_nodes}}) {
        foreach my $parent (@{$self->{_ordering}->{$node}}) {
            push @{$self->{_partial}->{$parent}}, $node;
        }
    }

}

sub parse_list {
    my $self = shift;
    my $list = shift;

    $list =~ s/^,//g;
    $list =~ s/\s//g;

    $list =~ s/([\w.]+)/"$1"/g;

    $list =~ s/\(/[/g;
    $list =~ s/\)/]/g;

    my $parsed_list = eval $list;
    #print Dumper $parsed_list;
    return $parsed_list;
}

sub create_from_file {
    my $self = shift;
    my $filename = shift;

    my @contents; { 
        local $/ = "\n";
        local *FILE;
        open FILE, "<", $filename;
        @contents = <FILE>;
        close FILE 
    }

    map { 
    s/\/\/.*$//g;
    } @contents;

    my $file = join "", @contents;
    @contents = split /[;{}]/, $file;
    @contents = grep { !/^\s*$/ } @contents;
    map { 
    s/\/\/.*$//g;
    s/\s+/ /g;
    s/\s*$//g;
    s/^\s*//g;
    } @contents;

    $self->parse(@contents);
}

sub gen_dot_partial {
    my $self = shift;
    my $filename = shift;

    open my $dot_file, ">", $filename;

    my $header = << "END";
digraph $self->{_name} {
    rankdir=TB;
END

    my $footer = '}';

    print $dot_file $header;
    foreach my $node (sort keys %{$self->{_partial}}) {
        foreach my $parent (@{$self->{_partial}->{$node}}) {
            print $dot_file "    $node -> $parent\n" if defined $parent;
        }
    }
    print $dot_file $footer;
}

sub gen_dot_topo {
    my $self = shift;
    my $filename = shift;

    open my $dot_file, ">", $filename;

    my $header = << "END";
digraph $self->{_name} {
    rankdir=TB;
END

    my $footer = '}';
    print $dot_file $header;
    my $self_clone = dclone($self);
    my %partial = %{$self_clone->{_partial}};
    my @L = ();
    my @S = @{$self->{_roots}};
    #print "list of S:\n";
    foreach my $x (@S) {
        #print "$x\n";
    }
    while (@S) {
        my $found = 0;
        my $n = pop @S;
        #print "n $n popped from S\n";
        push @L, $n;
        #print "pushed $n into L\n";
        foreach my $m (@{$partial{$n}}) {
            #print "popped $popped\n";
            #print "\nL:\n";
            #foreach my $x (@L) {
                #print "$x\n";
                ## body...
            #}
            #print "\ns:\n";
            #foreach my $x (@L) {
                #print "$x\n";
                ## body...
            #}
            #print "\npartial:\n";
            #print Dumper %partial;
            #print "m = $m\n";
            my $popped =  pop @{$partial{$n}};

            foreach my $key (sort keys %partial) {
                foreach my $parent (@{$partial{$key}}) {
                    next unless defined $parent;
                    $found++ if $m eq $parent;
                }
            }
            foreach my $key (sort keys %partial) {
                #print "$key => " . Dumper $partial{$key};
            }
            #print Dumper %partial;
            unless ($found) {
                push @S, $m;
            }

            #print "found is $found\n";

        }
    }
    foreach my $leaf (@{$self->{_leaves}}) {
        push @L, $leaf;
    }
    #print Dumper @L;
    my $num = scalar @L - 1;
    #print "num is $num\n";
    while ($num) {
        my $from = $L[$num];
        my $to = $L[$num - 1];
        print $dot_file "$to -> $from\n";
        #last unless defined $from;
        $num--;
    }


    print $dot_file $footer;
}
#L ← Empty list that will contain the sorted elements
#S ← Set of all nodes with no incoming edges
#while S is non-empty do
    #remove a node n from S
    #insert n into L
    #for each node m with an edge e from n to m do
        #remove edge e from the graph
        #if m has no other incoming edges then
            #insert m into S
#if graph has edges then
    #output error message (graph has at least one cycle)
#else 
    #output message (proposed topologically sorted order: L)




1;
