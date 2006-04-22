package YAML::Tiny;

# YAML, but just the best bits

use 5.004;
use strict;

use vars qw{$VERSION $errstr};
BEGIN {
	$VERSION = '0.01';
	$errstr  = '';
}

use constant FILE   => 0;
use constant SCALAR => 1;
use constant ARRAY  => 2;
use constant HASH   => 3;
use constant ANY    => 4;

# Create an empty YAML::Tiny object
sub new {
	bless [], shift;
}

# Create an object from a file
sub read {
	my $class = ref $_[0] ? ref shift : shift;

	# Check the file
	my $file = shift or return $class->_error( 'You did not specify a file name' );
	return $class->_error( "File '$file' does not exist" )              unless -e $file;
	return $class->_error( "'$file' is a directory, not a file" )       unless -f _;
	return $class->_error( "Insufficient permissions to read '$file'" ) unless -r _;

	# Slurp in the file
	local $/ = undef;
	open CFG, $file or return $class->_error( "Failed to open file '$file': $!" );
	my $contents = <CFG>;
	close CFG;

	$class->read_string( $contents );
}

# Create an object from a string
sub read_string {
	my $class = ref $_[0] ? ref shift : shift;
	my $self  = bless [], $class;
	return undef unless defined $_[0];
	return $self unless length  $_[0];

	# State variables
	my $line_count = 0;
	my $level      = 0;
	my $state      = FILE;
	my $indents    = [ ];
	my $types      = [ ];

	foreach ( split /(?:\015{1,2}\012|\015|\012)/, shift ) {
		$line_count++;

		# Skip comments and empty lines
		next if /^\s*(?:\#|$)/;

		die "CODE INCOMPLETE";
	}

	$self;
}

# Save an object to a file
sub write {
	my $self = shift;
	my $file = shift or return $self->_error(
		'No file name provided'
		);

	# Write it to the file
	open( CFG, '>' . $file ) or return $self->_error(
		"Failed to open file '$file' for writing: $!"
		);
	print CFG $self->write_string;
	close CFG;
}

# Save an object to a string
sub write_string {
	my $self = shift;
	return '' unless @$self;
	die "CODE INCOMPLETE";
}

# Error handling
sub errstr { $errstr }
sub _error { $errstr = $_[1]; undef }

1;

__END__

=pod

=head1 NAME

YAML::Tiny - Read/Write YAML files with as little code as possible

=head1 SYNOPSIS

    #############################################
    # In your file
    
    ---
    rootproperty: blah
    section:
      one: two
      three: four
      Foo: Bar
      empty: ~
    
    #############################################
    # In your program
    
    use YAML::Tiny;
    
    # Create a YAML file
    my $yaml = YAML::Tiny->new;
    
    # Open the config
    $yaml = YAML::Tiny->read( 'file.yml' );
    
    # Reading properties
    my $root = $yaml->[0]->{rootproperty};
    my $one  = $yaml->[0]->{section}->{one};
    my $Foo  = $yaml->[0]->{section}->{Foo};
    
    # Changing data
    $yaml->[0]->{newsection} = { this => 'that' }; # Add a section
    $yaml->[0]->{section}->{Foo} = 'Not Bar!';     # Change a value
    delete $yaml->[0]->{section};                  # Delete a value or section
    
    # Add an entire document
    $yaml->[1] = [ 'foo', 'bar', 'baz' ];
    
    # Save the file
    $yaml->write( 'file.conf' );

=head1 DESCRIPTION

B<WARNING: THIS MODULES IS HIGHLY EXPERIMENTAL AND SUBJECT TO CHANGE
WITHOUT NOTICE>

C<Config::Tiny> is a perl class to read and write YAML-style files with as
little code as possible, reducing load time and memory overhead.

Most of the time it is accepted that Perl applications use a lot
of memory and modules. The C<::Tiny> family of modules is specifically
intended to provide an ultralight alternative to the standard modules.

This module is primarily for reading human written files (like config files)
and generating simple human-readable report. Note that I said
B<human-readable> and not B<geek-readable>. The sort of files that your
average manager or secretary should be able to look at and make sense of.

L<YAML::Tiny> does not generate comments, it won't necesarily preserve the
order of your hashs, and it may normalise if reading in and writing out
again.

It only supports a very basic subset of the full YAML specification.

It is also targetted at files like Perl's META.yml, for which a small and
easily-embeddable module would be highly useful.

Features will only be added if they are human readable, and can be written
in a few lines of code. Please don't be offended if your request is
refused. Someone has to draw the line, and for YAML::Tiny that someone is
the module author.

If you need something with more power move up to L<YAML> (4 megabytes of\
memory overhead) or L<YAML::Syck> (requires libsyck).

To restate, L<YAML::Tiny> does B<not> preserve your comments, whitespace, or
the order of your YAML data. But it should round-trip from Perl structure
to file and back again just fine.

=head1 METHODS

=head2 new

The constructor C<new> creates and returns an empty C<Config::Tiny> object.

=head2 read $filename

The C<read> constructor reads a YAML file, and returns a new
C<YAML::Tiny> object containing the contents of the file. 

Returns the object on success, or C<undef> on error.

When C<read> fails, C<YAML::Tiny> sets an error message internally
you can recover via C<<YAML::Tiny->errstr>>. Although in B<some>
cases a failed C<read> will also set the operating system error
variable C<$!>, not all errors do and you should not rely on using
the C<$!> variable.

=head2 read_string $string;

The C<read_string> method takes as argument the contents of a YAML file
(a YAML document) as a string and returns the C<YAML::Tiny> object for
it.

=head2 write $filename

The C<write> method generates the file content for the properties, and
writes it to disk to the filename specified.

Returns true on success or C<undef> on error.

=head2 write_string

Generates the file content for the object and returns it as a string.

=head2 errstr

When an error occurs, you can retrieve the error message either from the
C<$YAML::Tiny::errstr> variable, or using the C<errstr()> method.

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=YAML-Tiny>

For other issues, or commercial enhancement or support, contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>cpan@ali.asE<gt>

=head1 SEE ALSO

L<http://ali.as/>, L<YAML>, L<YAML::Syck>, L<Config::Tiny>, L<CSS::Tiny>

=head1 COPYRIGHT

Copyright 2006 Adam Kennedy. All rights reserved.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
