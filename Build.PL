#
# $Id: Build.PL,v 1.3 2003/12/17 03:39:54 james Exp $
#

use strict;
use warnings;

use Module::Build;

# if we don't have ithreads, this won't be pretty
use threads ();

# create the Buildfile
Module::Build->new(

    module_name          => 'Thread::App::Shutdown',

    dist_version         => '0.10',

    license              => 'perl',
    
    requires             => {
        perl              => '5.8.0',
    },
    
    build_requires       => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
    },

    create_makefile_pl   => 'passthrough',

)->create_build_script;

#
# EOF
