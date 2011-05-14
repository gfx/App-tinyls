#!perl
use strict;
use warnings;

use File::stat      qw(stat);
use Time::localtime qw(localtime);
use Fcntl           qw(:mode);

main(@ARGV);

sub main {
    my(@argv) = @_;

    @argv = ('.') if !@argv;

    foreach my $dir(@argv) {
        print list_one($dir);
    }
}

sub list_one {
    my($dir, %opts) = @_;

    my @output;

    opendir my $dh, $dir or die "Cannot opendir '$dir': $!";

    foreach my $file(sort readdir $dh) {
        my $st = stat("$dir/$file") or die "Cannot stat '$dir/$file': $!";

        my $mode = make_mode( $st->mode );

        my $size  = sprintf '%8s', $st->size;

        my $tm    = localtime($st->mtime);
        my $mtime = sprintf '%d-%02d-%02d %02d:%02d:%02d',
            $tm->year + 1900, $tm->mon + 1, $tm->mday,
            $tm->hour, $tm->min, $tm->sec;

        push @output, "$mode $size $mtime $file\n";
    }

    closedir $dh;

    return join '', @output;
}

sub make_mode {
    my($mode) = @_;

    my @m;
    push @m, $mode & S_IFDIR ? 'd' : '-';

    push @m, make_perm($mode, S_IRUSR, S_IWUSR, S_IXUSR);
    push @m, make_perm($mode, S_IRGRP, S_IWGRP, S_IXGRP);
    push @m, make_perm($mode, S_IROTH, S_IWOTH, S_IXOTH);

    return join '', @m;
}

sub make_perm {
    my($m, $r, $w, $x) = @_;

    return join '',
        $m & $r ? 'r' : '-',
        $m & $w ? 'w' : '-',
        $m & $x ? 'x' : '-',
    ;
}

