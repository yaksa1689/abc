#!/usr/bin/env perl
use strict;

my @stocks;
foreach (@ARGV) {
  &getFullname($_) =~ /^(s\w\d{6})$/ &&  push @stocks, $1;
}
$#stocks > -1 || exit 0;
my $stocks = join ',', @stocks;
my @result = `curl -s http://hq.sinajs.cn/list=$stocks | iconv -fgbk -tutf-8`;

foreach (@result) {
  /(\d{6})="([^,]+),[^,]+,([^,]+),([^,]+),.+"/;
  $1 && $3 != 0 && printf "%s  %s  %s%.2f%\n", $1, $2, $4 > $3 && '+', ($4 / $3 - 1) * 100;
}

sub getFullname {
  $_ = shift @_;
  /^(1696|1896|1979)$/ && return sprintf "sz%06s", $_;
  /^(\d{1,3}|[13]\d{3})$/ && return sprintf "sh6%05s", $_;
  /^c(\d+)$/ && return sprintf "sz300%03s", $1;
  /^[02]\d{3}$/ && return sprintf "sz%06s", $_;
}
