#!/usr/bin/env perl
use strict;

my $dataPath = './data';
my @data = `cat $dataPath`;
my @stocks;
foreach (@ARGV) {
  &getFullname($_) =~ /^(s.*)$/ &&  push @stocks, $1;
}
$#stocks > -1 || exit 0;
my $stocks = join ',', @stocks;
my @stockList = `curl -s http://hq.sinajs.cn/list=$stocks | iconv -f gbk -t utf-8`;

foreach (@stockList) {
  /(\d{6})="([^,]+),([^,]+),([^,]+),([^,]+),([^,]+).+$/ && 
  $1 && $3 != 0 && printf "%s %s %s %.2f %.2f\n", $1, $2, ($5 >= 0 && "+") . "$5%", $3, $4;
}

sub getFullname {
  $_ = shift @_;
  /^(1696|1896|1979)$/ && return sprintf "s_sz%06s", $_;
  /^(\d{1,3}|[13]\d{3})$/ && return sprintf "s_sh6%05s", $_;
  /^c(\d+)$/ && return sprintf "s_sz300%03s", $1;
  /^[02]\d{3}$/ && return sprintf "s_sz%06s", $_;
  /^p$/ && return 's_sh000001,s_sz399001,s_sz399006';
  /^[a-z]{2,}$/ && return &getGrouplist($_);
}

sub getGrouplist {
  $_ = shift @_;
  my @list;
  `grep -Ehn "^# $_" $dataPath` =~ /^(\d+)/;
  foreach ($1..$#data) {
    @data[$_] !~ /^\d|c/ && last;
    @data[$_] =~ /^(.+)$/ && push @list, &getFullname($1);
  }
  return join ',', @list;
}
