#!/usr/bin/env perl
use strict;

my @stocks;
foreach (@ARGV) {
  if (&getFullname($_) =~ /^(s\w\d{6})$/) {
    push @stocks, $1;
  }
}
$#stocks > -1 || exit 0;
my $stocks = join ',', @stocks;
my @result = `curl -s http://hq.sinajs.cn/list=$stocks | iconv -fgbk -tutf-8`;

foreach (@result) {
  /(\d{6})="(\S+)"/;
  my $code = $1;
  my @data = split ',', $2;
  if ($#data > -1 && @data[1] != 0) {
    my $inc = (sprintf "%.2f%", (@data[3] / $data[2] - 1) * 100) =~ s/^(\d)/+$1/r;
    print "$code\t@data[0]\t$inc\n";
  }
}

sub getFullname {
  $_ = shift @_;
  # 宗申动力 豫能控股 招商蛇口
  if (/^(1696|1896|1979)$/) {
    return sprintf "sz%06s", $_;
  }
  # 上证601XXX 603XXX
  if (/^[13]?\d{1,3}$/) {
    return sprintf "sh6%05s", $_;
  }
  # 创业板
  if (/^c(\d+)$/) {
    return sprintf "sz300%03s", $1;
  }
  # 深圳
  if (/^[02]\d{3}$/) {
    return sprintf "sz%06s", $_;
  }
}
