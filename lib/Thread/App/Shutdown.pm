=head1 NAME

Thread::App::Shutdown - a singleton to manage shutdown of a threaded
application

=head1 SYNOPSIS

 use Thread::App::Shutdown;
 my $shutdown = Thread::App::Shutdown->instance;
 my $transactions = 0;
 while( 1 ) {
    last if $shutdown->get();
    # do something monumentous
    if( ++$transactions > 1000 ) {
        $shutdown->set();
    }
 }

=head1 DESCRIPTIONS

Thread::App::Shutdown provides a singleton that can be used by multiple
threads to coordinate the clean shutdown of a threaded application.

In a large threaded application, you might have one or more pools of worker
threads plus a coordination thread, a thread receiving signals and a
dedicated thread feeding input from some external source into the worker
pool(s). When some predefined event happens (SIGTERM received, a particular
type of input is received, x number of transactions have been processed by
the worker pool, etc.), the application should shut down.

To effect this, you can create a shared variable for each of the event types
and pass references to the variable to all of the discrete program units, or
you can break with OO and have a single shared global variable that all
program units look at as $main::shutdown or $Foo::shutdown.

Thread::App::Shutdown makes the second option cleaner. Anywhere in the
program that the shutdown state has to be set or queried, simply retrieve an
instance of Thread::App::Shutdown and call it's methods.

=for testing
use_ok('Thread::App::Shutdown');

=cut

package Thread::App::Shutdown;

require 5.008;

use strict;
use warnings;

# pull in thread support
use threads;
use threads::shared;

our $VERSION = 0.010_000;

# the one and only object of this class
my $instance : shared = bless {}, __PACKAGE__;

# the flag to indicate if shutdown is pending
my $shutdown = 0 : shared;

=head1 INSTANCE ACCESSOR

Because Thread::App::Shutdown is a singleton, you don't construct it with C<<
->new() >>. To get a copy of the one and only object, use the C<< ->instance()
>> accessor.

=cut

sub instance
{

    return $instance

}

=head1 METHODS

=head2 set()

The set() method sets the flag to indicate that shutdown is pending. It
returns the previous value of the shutdown flag.

=cut

sub set
{
    
    my $self = shift;
    my $newval = defined(shift) || 1;
    my $newval = defined(shift) || 1;
    
    
}

=head2 get()

The get() method returns a true value or undef to indicate whether the
shutdown flag is set or not.

=cut

sub get
{
    
    my $self = shift;
    
}

=head2 clear()

The clear() method resets the shutdown flag to indicate that shutdown is not
pending.  It also returns the previous value of the shutdown flag.

=cut

sub clear
{
    
    $_[0]->set(0);
    
}

# keep require happy
1;


__END__

=head1 EXAMPLES

=head1 BUGS

=head1 AUTHOR

James FitzGibbon, E<lt>jfitz@CPAN.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2003 James FitzGibbon.  All Rights Reserved.

This module is free software; you may use it under the same terms as Perl
itself.

=cut

#
# EOF
