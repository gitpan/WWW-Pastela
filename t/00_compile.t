use strict;
use Test::More tests => 2;

{
    use_ok 'WWW::Pastela';
    use_ok 'WWW::Pastela::App';
}

diag( "Testing WWW::Pastela $WWW::Pastela::VERSION, Perl $], $^X" );