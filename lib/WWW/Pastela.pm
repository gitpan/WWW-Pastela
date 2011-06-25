package WWW::Pastela;
use strict;
use warnings;

our $VERSION = '0.04';

use Carp qw/croak/;
use Furl;
use Web::Scraper;
use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/
        code name title lang expire hide exec
    /],
);

our $PASTELA   = 'http://paste.la/';
our $END_POINT = +{
    get_exec => $PASTELA,
    paste    => "${PASTELA}paste",
};

sub paste {
    my ($self, %args) = @_;

    my $f = Furl->new(
        agent   => __PACKAGE__. "/$VERSION",
        timeout => 3,
    );

    my $res = $f->get($END_POINT->{get_exec});
    croak 'paste.la is down. status:'. $res->status_line unless $res->code == 200;
    my ($exec_key) = ($res->body =~ m!name="exec" value="([0-9a-zA-Z\:]+)" />!);
    croak 'could not get ecec_key.' unless $exec_key;

    my $pasted = $f->post(
        $END_POINT->{paste},
        [],
        [
            code   => $args{code}   || $self->code   || '',
            name   => $args{name}   || $self->name   || '',
            title  => $args{title}  || $self->title  || '',
            lang   => $args{lang}   || $self->lang   || '',
            expire => $args{expire} || $self->expire || '',
            hide   => $args{hide}   || $self->hide   || '',
            exec   => $exec_key,
        ],
    );

    my $response_body = $pasted->body;
    my $result;
    unless ($pasted->code =~ m!^[45]\d\d!) {
        if ( my ($code_key) = ($response_body =~ m!:\s(\w+)</title>!) ) {
            $result = +{
                code_key => $code_key,
                code_url => $END_POINT->{get_exec}. $code_key,
            };
        }
        elsif ($response_body =~ m!<div id="error">!) {
            my $error = scraper {
                process "#error ul li", "errors[]" => 'TEXT';
            };
            $result->{error} = $error->scrape($response_body)->{errors};
        }
        else {
            $result->{error} = 'maybe posted ok, but something wrong';
        }
    }
    else {
        $result->{error} = $pasted->status_line;
    }

    return $result;
}

1;

__END__

=head1 NAME

WWW::Pastela - paste a code easily on paste.la


=head1 SYNOPSIS

    use WWW::Pastela;

    my $p = WWW::Pastela->new(
        code   => $code,
        title  => $title,
        name   => $name,
        lang   => $lang,
        expire => $expire,
    );
    my $result = $p->paste; # print Dumper($result);

    # on the command line:
    $ pastela my_code.pl
    http://paste.la/FooBar12


=head1 DESCRIPTION

WWW::Pastela lets you post text to paste.la for public viewing.
You can show it on IRC, chat or your blog by tiny URL(e.g. http://paste.la/FooBar12).


=head1 METHOD

=head2  new(%args)

constructor

=head2  paste(%args)

send code to paste


=head1 REPOSITORY

WWW::Pastela is hosted on github
<http://github.com/bayashi/WWW-Pastela>


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

<http://paste.la/>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
