package WWW::Pastela::App;
use strict;
use warnings;
use Carp qw/croak/;
use Getopt::Long;
use Pod::Usage;
use Path::Class;
use WWW::Pastela;

sub run {
    my $class  = shift;

    my %config = $class->_process;

    my $result = $class->_paste(%config);

    $class->_put_result($result);

    return 1;
}

sub _process {
    my $self = shift;

    my %config = $self->_config_read;

    pod2usage(2) unless @ARGV;

    GetOptions(
        'title=s'  => \$config{title},
        'name=s'   => \$config{name},
        'lang=s'   => \$config{lang},
        'expire=s' => \$config{expire},
        'hide'     => \$config{hide},
        help       => sub {
            pod2usage(1);
        },
        version    => sub {
            require WWW::Pastela;
            print "pastela v$WWW::Pastela::VERSION\n";
            exit 1;
        },
    ) or pod2usage(2);

    my $code_file = shift @ARGV;

    return(
        file => $code_file,
        %config,
    );
}

sub _config_read {
    my $class = shift;

    my $filename = $class->_config_file;

    return unless -e $filename;

    open my $fh, '<', $filename
        or croak "couldn't open config file $filename: $!\n";

    my %config;
    while (<$fh>) {
        chomp;
        next if /\A\s*\Z/sm;
        if (/\A(\w+):\s*(.+)\Z/sm) { $config{$1} = $2; }
    }

    $config{title} = ''; # disable

    return %config;
}

sub _config_file {
    my $class     = shift;
    my $configdir = $ENV{'PASTELA_DIR'} || '';

    if ( !$configdir && $ENV{'HOME'} ) {
        $configdir = dir( $ENV{'HOME'}, '.pastela' );
    }

    return file( $configdir, 'config' );
}

sub _paste {
    my ($self, %config) = @_;

    open my $fh, '<', $config{file}
        or croak "couldn't open config file $config{file}: $!\n";
    my $p = WWW::Pastela->new(
        code => do { local $/; <$fh> },
        %config
    );
    close $fh;

    return $p->paste;
}

sub _put_result {
    my ($self, $result) = @_;

    if ($result->{code_url}) {
        print "$result->{code_url}\n";
    }
    elsif ($result->{error}) {
        if (ref $result->{error} eq 'ARRAY') {
            print "$_\n" for @{$result->{error}};
        }
        else {
            print "$result->{error}\n";
        }
    }
}

1;

__END__

=head1 NAME

WWW::Pastela::App - paste a code easily on paste.la


=head1 METHOD

=head2 run

    WWW::Pastela::App->run;

This is equivalent to running F<pastela>.


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
