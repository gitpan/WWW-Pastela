use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Pastela',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/WWW/Pastela.pm',
    build_requires      => {
        'Test::More' => 0.88,
    },
    requires => {
        'Carp' => 0,
        'Class::Accessor::Lite' => 0.05,
        'Furl' => 0.32,
        'Web::Scraper' => 0,
        'Path::Class' => 0,
        'Pod::Usage' => 0,
        'Getopt::Long' => 0,
    },
    add_to_cleanup      => [ 'WWW-Pastela-*' ],
    script_files        => [ 'bin/pastela' ],
    meta_merge     => {
      resources => {
        repository  => 'http://github.com/bayashi/WWW-Pastela'
      }
    },
);

$builder->create_build_script();
