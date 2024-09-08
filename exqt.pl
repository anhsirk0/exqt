#!/usr/bin/env perl

# simple code runner script
# https://codeberg.org/anhsirk0/exqt

use strict;
use warnings;
use Term::ANSIColor;

my %SCRIPTS = (
    "bash" => "bash",
    "cr"   => "crystal",
    "hs"   => "runhaskell",
    "js"   => "node",
    "ts"   => "ts-node",
    "pl"   => "perl",
    "py"   => "python3",
    "rb"   => "ruby",
    "sh"   => "sh",
    );

sub main {
    my $file = shift @ARGV;
    print_help_and_exit() if (!$file || $file eq "-h" || $file eq "--help");
    error_exit("File '$file' does not exist") unless -f $file;
    my ($name, $ext) = $file =~ /(.*)\.([a-zA-Z0-9]+)$/;
    my $code = 0; # Return code
    my $bin = "exqt_$name.out"; # binary executable name

    if ($ext eq "c") {
        $code = system("gcc", $file, "-o", $bin);
        run_compile($bin) if $code == 0;
    } elsif ($ext eq "cpp") {
        $code = system("g++", $file, "-o", $bin);
        run_compile($bin) if $code == 0;
    } elsif ($ext eq "java") {
        $code = system("javac", $file);
        if (-f "$name.class") {
            $code = system("java", $name, @ARGV);
            system("rm ./$name.class");
        }
    } elsif ($ext eq "odin") {
        $code = system("odin", "build", $file, "-file");
        run_compile($name) if $code == 0;
    } elsif ($ext eq "rs") {
        $code = system("rustc", $file);
        run_compile($name) if $code == 0;
    } else {
        my $cmd = $SCRIPTS{$ext};
        error_exit("Could not determine how to execute '$file'") unless $cmd;
        $code = system($cmd, $file, @ARGV);
    }
    error_exit("Failed to execute '$file'") if $code != 0;
}

sub print_help_and_exit {
    printf(
        "%s\n\n%s\n\n",
        colored("exqt", "green") . "\nSimple code runner script.",
        colored("USAGE:", "yellow") . "\n\t" . "exqt <FILE> [ARGS]",
        );
    exit();
}

sub error_exit {
    my $msg = shift;
    die(colored("[exqt] $msg", "red") . "\n");
}

sub run_compile {
    my $bin = shift;
    if (-f $bin) {
        my $code = system("./$bin", @ARGV);
        unlink $bin; # delete $bin file
        exit($code == 0 ? 0 : 1);
    }
}

main()
