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
use diagnostics;

# pull in thread support
use threads;
use threads::shared;

our $VERSION = 0.010_000;

# the one and only object of this class;
my $instance;

=head1 INSTANCE ACCESSOR

Because Thread::App::Shutdown is a singleton, you don't construct it with
C<< ->new() >>. To get a copy of the one and only object, use the C<<
->instance() >> accessor.

If an instance of the class does not already exist, one will be created and
returned. All subsequent uses of C<< ->instance >> will return the same
object. As such, it is important that the first instance of the
B<Thread::App::Shutdown> object be created prior to any other threads.
Typically you would get the instance as part of the program initialization.

=begin testing

use threads::shared;

use Test::Exception;

my $class = 'Thread::App::Shutdown';

# make sure we can get an instance
my $shutdown;
lives_ok { $shutdown = $class->instance }
    "can get an instance of $class";
isa_ok( $shutdown, $class );
is( $shutdown->get, 0, 'flag is not set' );

# create a new condition variable
my $cond : shared = 0;

# test subroutine
sub test_in_thread
{
    
    # wait for the condition to be set
    lock $cond;
    cond_wait $cond;
    
    # check the flag status
    is( $shutdown->get, 0, 'flag is not set in thread' );
    
    # set the condition
    cond_signal $cond;
    
    # wait for the condition to be set
    lock $cond;
    cond_wait $cond;
    
    # check the flag status
    is( $shutdown->get, 1, 'flag is set in thread' );

    # set the condition
    cond_signal $cond;
    
}

# run the test subroutine in a new thread
threads->create( \&test_in_thread )->detach;

# set the condition
lock $cond;
cond_signal $cond;

# wait for the condition to be set
lock $cond;
cond_wait $cond;

# set the flag status
$shutdown->set(1);

# set the condition
cond_signal $cond;

# wait for the condition to be set
lock $cond;
cond_wait $cond;

# check the flag status
is( $shutdown->get, 1, 'flag is set' );

=end testing

=cut

sub instance
{

    my $class = shift;
    
    # if we already have an instance, return it
    return $instance if $instance;
    
    # create a new object and return it
    my $self : shared = 0;
    $instance = bless \$self, $class;

}

=head1 METHODS

=head2 set()

The set() method sets the flag to indicate that shutdown is pending. It
returns the previous value of the shutdown flag.

=for testing
my $shutdown = Thread::App::Shutdown->instance;
lives_ok { $shutdown->set( 0 ) } 'set flag to 0';
is( $shutdown->get, 0, 'flag is not set');
lives_ok { $shutdown->set( 1 ) } 'set flag to 1';
is( $shutdown->get, 1, 'flag is set');
lives_ok { $shutdown->set( 0 ) } 'set flag to 0';
is( $shutdown->get, 0, 'flag is not set');
lives_ok { $shutdown->set( 'foo' ) } 'set flag to foo';
is( $shutdown->get, 1, 'flag is set');
lives_ok { $shutdown->set( undef ) } 'set flag to undef';
is( $shutdown->get, 0, 'flag is not set');
lives_ok { $shutdown->set } 'set flag with no arg';
is( $shutdown->get, 1, 'flag is set');
lives_ok { $shutdown->set( 0 ) } 'set flag to 0';
is( $shutdown->get, 0, 'flag is not set');

=cut

sub set
{
    
    my $self = shift;
    my $newval;
    if( @_ ) {
        $newval = shift(@_) ? 1 : 0;
    }
    else {
        $newval = 1;
    }
    
    # lock ourselves, set a new value and return the old value
    lock $$self;
    my $oldval = $$self;
    $$self = $newval;
    return $oldval;
    
}

=head2 get()

The get() method returns a true value or undef to indicate whether the
shutdown flag is set or not.

my $shutdown = Thread::App::Shutdown->instance;
lives_ok { $shutdown->set( 1 ) } 'set flag to 1';
is( $shutdown->get, 1, 'flag is set');

=cut

sub get
{
    
    my $self = shift;
    
    # lock ourselves and return our value
    lock $$self;
    return $$self;
    
}

=head2 clear()

The clear() method resets the shutdown flag to indicate that shutdown is not
pending.  It also returns the previous value of the shutdown flag.

=for testing
my $shutdown = Thread::App::Shutdown->instance;
lives_ok { $shutdown->set( 1 ) } 'set flag to 1';
is( $shutdown->get, 1, 'flag is set');
lives_ok { $shutdown->clear } 'clear flag';
is( $shutdown->get, 0, 'flag is not set');

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
