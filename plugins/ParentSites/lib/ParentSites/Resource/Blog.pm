package ParentSites::Resource::Blog;

use strict;
use warnings;

use MT::Blog;
use MT::Website;

sub website {
    my ( $obj ) = @_;

    if ( $obj->is_blog ) {
        my $parent = $obj->website;
        return {
            id   => $parent->id,
            name => $parent->name,
        };
    }

    return undef;
}

1;
