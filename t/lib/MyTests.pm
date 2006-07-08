package MyTests;

use strict;
use Exporter   ();
use Test::More ();

use vars qw{@ISA @EXPORT};
BEGIN {
	@ISA    = qw{ Exporter };
	@EXPORT = qw{ tests  yaml_ok  slurp  load_ok };
}

# Do we have the authorative YAML to test against
eval { require YAML; };
my $COMPARE = !! $YAML::VERSION;

# 15 tests per call to yaml_ok
# 5  tests per call to load_ok
sub tests {
	my $yaml_ok = shift || 0;
	my $load_ok = shift || 0;
	my $count   = $yaml_ok * 15 + $load_ok * 4;
	return ( tests => $count );
}

sub yaml_ok {
	my $string = shift;
	my $object = shift;
	my $name   = shift || 'unnamed';
	bless $object, 'YAML::Tiny';

	# If YAML itself is available, test with it first
	SKIP: {
		skip( "Skipping compatibility testing (no YAML.pm)", 4 ) unless $COMPARE;

		# Test writing with YAML.pm
		my $yamlpm_out = eval { YAML::Dump( @$object ) };
		Test::More::is( $@, '', "$name: YAML.pm saves without error" );
		SKIP: {
			Test::More::skip( "Shortcutting after failure", 1 ) if $@;
			Test::More::ok(
				!!(defined $yamlpm_out and ! ref $yamlpm_out),
				"$name: YAML.pm serializes correctly",
			);
			my @yamlpm_round = eval { YAML::Load( $yamlpm_out ) };
			Test::More::is( $@, '', "$name: YAML.pm round-trips without error" );
			Test::More::skip( "Shortcutting after failure", 2 ) if $@;
			my $round = bless [ @yamlpm_round ], 'YAML::Tiny';
			Test::More::isa_ok( $round, 'YAML::Tiny' );
			Test::More::is_deeply( $round, $object, "$name: YAML.pm round-trips correctly" );		
		}

		# Test reading with YAML.pm
		my @yamlpm_in = eval { YAML::Load( $string ) };
		Test::More::is( $@, '', "$name: YAML.pm loads without error" );
		SKIP: {
			Test::More::skip( "Shortcutting after failure", 1 ) if $@;
			Test::More::is_deeply( \@yamlpm_in, $object, "$name: YAML.pm parses correctly" );
		}
	}

	# Does the string parse to the structure
	my $yaml = eval { YAML::Tiny->read_string( $string ); };
	Test::More::is( $@, '', "$name: YAML::Tiny parses without error" );
	SKIP: {
		Test::More::skip( "Shortcutting after failure", 2 ) if $@;
		Test::More::isa_ok( $yaml, 'YAML::Tiny' );
		Test::More::is_deeply( $yaml, $object, "$name: YAML::Tiny parses correctly" );
	}

	# Does the structure serialize to the string.
	# We can't test this by direct comparison, because any
	# whitespace or comments would be lost.
	# So instead we parse back in.
	my $output = eval { $object->write_string };
	Test::More::is( $@, '', "$name: YAML::Tiny serializes without error" );
	SKIP: {
		Test::More::skip( "Shortcutting after failure", 4 ) if $@;
		Test::More::ok(
			!!(defined $output and ! ref $output),
			"$name: YAML::Tiny serializes correctly",
		);
		my $roundtrip = eval { YAML::Tiny->read_string( $output ) };
		Test::More::is( $@, '', "$name: YAML::Tiny round-trips without error" );
		Test::More::skip( "Shortcutting after failure", 2 ) if $@;
		Test::More::isa_ok( $roundtrip, 'YAML::Tiny' );
		Test::More::is_deeply( $roundtrip, $object, "$name: YAML::Tiny round-trips correctly" );
	}

	# Return true as a convenience
	return 1;
}

sub slurp {
	my $file = shift;
	local $/ = undef;
	open( FILE, " $file" ) or die "open($file) failed: $!";
	my $source = <FILE>;
	close( FILE ) or die "close($file) failed: $!";
	$source;
}

sub load_ok {
	my $name = shift;
	my $file = shift;
	my $size = shift;
	Test::More::ok( -f $file, "Found $name" );
	Test::More::ok( -r $file, "Can read $name" );
	my $content = slurp( $file );
	Test::More::ok( (defined $content and ! ref $content), "Loaded $name" );
	Test::More::ok( ($size < length $content), "Content of $name larger than $size bytes" );
	return $content;
}

1;