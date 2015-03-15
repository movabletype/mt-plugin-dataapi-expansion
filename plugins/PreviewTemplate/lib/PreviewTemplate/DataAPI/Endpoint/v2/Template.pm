package PreviewTemplate::DataAPI::Endpoint::v2::Template;

use strict;
use warnings;

use MT::DataAPI::Endpoint::Common;

sub preview {
    my ( $app, $endpoint ) = @_;

    my ( $site, $tmpl ) = context_objects(@_) or return;

    if ( grep { $tmpl->type eq $_ } qw/ backup widget widgetset / ) {
        return $app->error( $app->translate('Template not found'), 404 );
    }

    $app->param( 'id', $tmpl->id );

    my $preview_basename;
    no warnings 'redefine';
    local *MT::App::DataAPI::preview_object_basename = sub {
        require MT::App::CMS;
        $preview_basename = MT::App::CMS::preview_object_basename(@_);
    };

    my $old = $app->config('PreviewInNewWindow');
    $app->config('PreviewInNewWindow', 1);

    require MT::CMS::Template;
    MT::CMS::Template::preview( $app );

    if ( $app->errstr ) {
        return $app->error(403);
    }

    $app->config('PreviewInNewWindow', $old);
    delete $app->{redirect}
        if $app->{redirect};

    my $session_class = MT->model('session');
    my $sess = $session_class->load({ id => $preview_basename });
    return $app->error( $app->translate('Preview data not found.'), 404 )
        unless $sess;

    require MT::FileMgr;
    my $fmgr = MT::FileMgr->new('Local');
    my $content = $fmgr->get_data($sess->name );

    $fmgr->delete($sess->name);
    $sess->remove;

    return +{
        status  => 'success',
        preview => $content
    };
}

1;
