#!/usr/bin/perl

use utf8;
use POSIX;

#$dict="/daemon/utils/sphinx/split/msu_ru_zero.dic";
#$dict="/daemon/utils/sphinx/transcript/udarenie.txt";
#$dict="/daemon/utils/sphinx/transcript/yo_word.txt";
#$dict="/home/SphinxTrain/etc/msu_ru_zero.dic";

$dict='cat ../text2dict/*.txt|';

my @ch_t;

@ch_e[0]='ноль';
@ch_e[1]='один';
@ch_e[2]='два';
@ch_e[3]='три';
@ch_e[4]='четыре';
@ch_e[5]='пять';
@ch_e[6]='шесть';
@ch_e[7]='семь';
@ch_e[8]='восемь';
@ch_e[9]='девять';
@ch_e[10]='десять';
@ch_e[11]='одинадцать';
@ch_e[12]='двенадцать';
@ch_e[13]='тринадцать';
@ch_e[14]='четырнадцать';
@ch_e[15]='пятнадцать';
@ch_e[16]='шестнадцать';
@ch_e[17]='семьнадцать';
@ch_e[18]='восемьнадцать';
@ch_e[19]='девятнадцать';
@ch_e[20]='двадцать';
@ch_e[30]='тридцать';
@ch_e[40]='сорок';
@ch_e[50]='пятьдесят';
@ch_e[60]='шестьдесят';
@ch_e[70]='семьдесят';
@ch_e[80]='восемдесят';
@ch_e[90]='девяносто';

@ch_s[1]='сто';
@ch_s[2]='двести';
@ch_s[3]='триста';
@ch_s[4]='четыреста';
@ch_s[5]='пятьсот';
@ch_s[6]='шестьсот';
@ch_s[7]='семьсот';
@ch_s[8]='восемьсот';
@ch_s[9]='девятьсот';

#print '|';
#uprint (wdigits(1,'1230','я'));
#print '|';
#exit;

if ( $ARGV[0] ) { $infile=$ARGV[0]; } else { exit; }


open(DICT, $dict) or die ("need output file name");

my %dict;
my %edict;
my %tdict;

while (my $inline = <DICT>)
{
        chomp $inline;
        $inline =~ s/\(\d\)//g;
        utf8::decode($inline);
        my ($word,$text) = split(/[\s]+/,$inline,2);
        $word=~s/\+//g;
        $dict{$word}++;
        $eword=$word; $eword=~s/ё/е/g;
        $edict{$eword}=$word;
        $tword=$eword; $tword=~s/\-//g;
        $tdict{$tword}=$word;
}

print "dict loaded\n";
close(DICT);


my @words;

$outfile=$infile.'.norm';

# ($infile_name,$tmp)=split('.txt',$infile,2);

open(IN, "<$infile") or die ("need output file name");
open(OUT, ">$outfile") or die ("need output file name");

$preline='';
while (my $inline = <IN>)
{
        chomp $inline;
        utf8::decode($inline);
#        $inline =~ s/\-\r\n//;
#        $inline =~ s/\-\r\n//;
#        $inline =~ s/\-\r//;

        $inline =~ s/[\-]+/-/g;
        $inline =~ s/ - / /g;
        $inline =~ s/[^\w\d\-\/\%]/ /g;
        $inline =~ s/cу/су/g;
        $inline =~ s/ и т\.д\./ и так далее /g;
        $inline =~ s/ т\.е\./ тоесть/g;
        $inline =~ s/ св\./ святого/g;
        $inline =~ s/ гр-на / гражданина /g;
        $inline =~ s/ гр-н / гражданин /g;
        $inline =~ s/ г-н / господин /g;
        $inline =~ s/ г-на / господина /g;
        $inline =~ s/ґ//g;
        $inline =~ s/(\w) \-(\w)/$1\-$2/g;
        $inline =~ s/(\w)\- (\w)/$1\-$2/g;

        $inline =~ s/([\d]+)(Ч|x)([\d]+)/$1 на $3/g;	# [фото] 3x4
        $inline =~ s/ г\./ год/g;
        $inline =~ s/ изд\./ издание/g;
        $inline =~ s/\// дробь /g;
        $inline =~ s/(1)(\s+)?\%/$1 процент /g;
        $inline =~ s/(2|3|4)(\s+)?\%/$1 процента /g;
        $inline =~ s/\%/ процентов /g;
        $inline =~ s/[\s]+/ /g;

	$inline = lc($inline);

	@words=split(" ",$inline);
	undef $outline;
        for (my $ni = 0; $ni <= $#words; $ni++)
        {
#		@words[$ni]=wcheck($ni);
#		@words[$ni]=wcheck($ni);
		if ($ni==0 and $preline=~/\-$/) { $outline.=wcheck($ni); } else { $outline.=" ".wcheck($ni); }
#		$outline.=" ".@words[$ni];
#		$outline.=" ".wcheck($ni);
        }


	$preline=$outline;
	$outline=~s/\-$//;
        $outline=~s/ - / /g;
	utf8::encode($outline);
	print OUT $outline;
}

######################
sub uprint {
        my ($vtxt)=@_;
        utf8::encode($vtxt);
        print $vtxt;
}
######################
sub wcheck {
	my ($wn)=@_;
#	my $rtext;
	my $rtext=@words[$wn];

#	if (@words[$wn] eq 'все') {
#		if ( @words[$wn+1] eq 'одолеет' ) { $rtext='всё'; }
#		}

#	if (@words[$wn] eq '11') {
#		if ( @words[$wn+1] eq 'декабря' ) { @words[$wn]='одинадцатое'; }
#		}

	if (@words[$wn]=~/([\d]+)([\w\-]+)?/) {
		$rtext=wdigits($wn,$1,$2);
		}

	$rtext=dict($rtext);

return $rtext;
}
######################
sub wdigits {
	my $str;
	my $wn=@_[0];
	my $digits=@_[1];
	my $end=@_[2];
	$end=~s/-//g;

	$str=sdigits($digits);
	$str=~s/ $//;

	$str=~s/один тысяч/одна тысяча/;
	$str=~s/два тысяч/две тысячи/;
	$str=~s/три тысяч/три тысячи/;
	$str=~s/четыре тысяч/четыре тысячи/;

	if (length($end)>3) {
		$str=~s/один$/одна/;
		$str=~s/два$/двух/;
		$str=~s/три$/трёх/;
		$str=~s/четыре$/четырёх/;
		$str=~s/пять$/пяти/;
		$str=~s/шесть$/шести/;
		$str=~s/семь$/семи/;
		$str=~s/восемь$/восьми/;
		$str=~s/девять$/девяти/;
		$str=~s/десять$/десяти/;
		$str=~s/одинадцать$/одинадцати/;
		$str=~s/двенадцать$/двенадцати/;
		$str=~s/тринадцать$/тринадцати/;
		$str=~s/четырнадцать$/четырнадцати/;
		$str=~s/пятнадцать$/пятнадцати/;
		$str=~s/шестнадцать$/шестнадцати/;
		$str=~s/семьнадцать$/семнадцати/;
		$str=~s/восемьнадцать$/восемнадцати/;
		$str=~s/девятнадцать$/девятнадцати/;
		$str=~s/двадцать$/двадцати/;
		$str=~s/тридцать$/тридцати/;
		$str=~s/сорок$/сорока/;
		$str=~s/пятьдесят$/пятидесяти/;
		$str=~s/шестьдесят$/шестидесяти/;
		$str=~s/семьдесят$/семидесяти/;
		$str=~s/восемьдесят$/восьмидесяти/;
		$str=~s/девяносто$/девяноста/;
		$str=$str." ".$end;
		undef $end;
		}

	if ($end=~/я$/) {
		$str=~s/один$/первая/;
		$str=~s/два$/вторая/;
		$str=~s/три$/третья/;
		$str=~s/четыре$/четвёртая/;
		$str=~s/пять$/пятая/;
		$str=~s/шесть$/шестая/;
		$str=~s/семь$/седьмая/;
		$str=~s/восемь$/восьмая/;
		$str=~s/девять$/девятая/;
		$str=~s/десять$/десятая/;
		$str=~s/одинадцать$/одинадцатая/;
		$str=~s/двенадцать$/двенадцатая/;
		$str=~s/тринадцать$/тринадцатая/;
		$str=~s/четырнадцать$/четырнадцатая/;
		$str=~s/пятнадцать$/пятнадцатая/;
		$str=~s/шестнадцать$/шестнадцатая/;
		$str=~s/семьнадцать$/семнадцатая/;
		$str=~s/восемьнадцать$/восемнадцатая/;
		$str=~s/девятнадцать$/девятнадцатая/;
		$str=~s/двадцать$/двадцатая/;
		$str=~s/тридцать$/тридцатая/;
		$str=~s/сорок$/сороковая/;
		$str=~s/пятьдесят$/пятидесятая/;
		$str=~s/шестьдесят$/шестидесятая/;
		$str=~s/семьдесят$/семидесятая/;
		$str=~s/восемьдесят$/восьмидесятая/;
		$str=~s/девяносто$/девяностая/;
		}


	if ($end=~/й$/) {
		$str=~s/один$/первой/;
		$str=~s/два$/второй/;
		$str=~s/три$/третьей/;
		$str=~s/четыре$/четвёртой/;
		$str=~s/пять$/пятой/;
		$str=~s/шесть$/шестой/;
		$str=~s/семь$/седьмой/;
		$str=~s/восемь$/восьмой/;
		$str=~s/девять$/девятой/;
		$str=~s/десять$/десятой/;
		$str=~s/одинадцать$/одинадцатой/;
		$str=~s/двенадцать$/двенадцатой/;
		$str=~s/тринадцать$/тринадцатой/;
		$str=~s/четырнадцать$/четырнадцатой/;
		$str=~s/пятнадцать$/пятнадцатой/;
		$str=~s/шестнадцать$/шестнадцатой/;
		$str=~s/семьнадцать$/семнадцатой/;
		$str=~s/восемьнадцать$/восемнадцатой/;
		$str=~s/девятнадцать$/девятнадцатой/;
		$str=~s/двадцать$/двадцатой/;
		$str=~s/тридцать$/тридцатой/;
		$str=~s/сорок$/сороковой/;
		$str=~s/пятьдесят$/пятидесятой/;
		$str=~s/шестьдесят$/шестидесятой/;
		$str=~s/семьдесят$/семидесятой/;
		$str=~s/восемьдесят$/восьмидесятой/;
		$str=~s/девяносто$/девяностой/;
		}

	if ($end=~/ю$/) {
		$str=~s/один$/первую/;
		$str=~s/два$/вторую/;
		$str=~s/три$/третью/;
		$str=~s/четыре$/четвёртую/;
		$str=~s/пять$/пятую/;
		$str=~s/шесть$/шестую/;
		$str=~s/семь$/седьмую/;
		$str=~s/восемь$/восьмую/;
		$str=~s/девять$/девятую/;
		$str=~s/десять$/десятую/;
		$str=~s/одинадцать$/одинадцатую/;
		$str=~s/двенадцать$/двенадцатую/;
		$str=~s/тринадцать$/тринадцатую/;
		$str=~s/четырнадцать$/четырнадцатую/;
		$str=~s/пятнадцать$/пятнадцатую/;
		$str=~s/шестнадцать$/шестнадцатую/;
		$str=~s/семьнадцать$/семнадцатую/;
		$str=~s/восемьнадцать$/восемнадцатую/;
		$str=~s/девятнадцать$/девятнадцатую/;
		$str=~s/двадцать$/двадцатую/;
		$str=~s/тридцать$/тридцатую/;
		$str=~s/сорок$/сороковую/;
		$str=~s/пятьдесят$/пятидесятую/;
		$str=~s/шестьдесят$/шестидесятую/;
		$str=~s/семьдесят$/семидесятую/;
		$str=~s/восемьдесят$/восьмидесятую/;
		$str=~s/девяносто$/девяностую/;
		}


	if ($end=~/го$/) {
		$str=~s/один$/первого/;
		$str=~s/два$/второго/;
		$str=~s/три$/третьего/;
		$str=~s/четыре$/четвёртого/;
		$str=~s/пять$/пятого/;
		$str=~s/шесть$/шестого/;
		$str=~s/семь$/седьмого/;
		$str=~s/восемь$/восьмого/;
		$str=~s/девять$/девятого/;
		$str=~s/десять$/десятого/;
		$str=~s/одинадцать$/одинадцатого/;
		$str=~s/двенадцать$/двенадцатого/;
		$str=~s/тринадцать$/тринадцатого/;
		$str=~s/четырнадцать$/четырнадцатого/;
		$str=~s/пятнадцать$/пятнадцатого/;
		$str=~s/шестнадцать$/шестнадцатого/;
		$str=~s/семьнадцать$/семнадцатого/;
		$str=~s/восемьнадцать$/восемнадцатого/;
		$str=~s/девятнадцать$/девятнадцатого/;
		$str=~s/двадцать$/двадцатого/;
		$str=~s/тридцать$/тридцатого/;
		$str=~s/сорок$/сорокового/;
		$str=~s/пятьдесят$/пятидесятого/;
		$str=~s/шестьдесят$/шестидесятого/;
		$str=~s/семьдесят$/семидесятого/;
		$str=~s/восемьдесят$/восьмидесятого/;
		$str=~s/девяносто$/девяностого/;
		}


	if ($end=~/е$/) {
		$str=~s/один$/первые/;
		$str=~s/два$/вторые/;
		$str=~s/три$/третье/;
		$str=~s/четыре$/четвёртые/;
		$str=~s/пять$/пятые/;
		$str=~s/шесть$/шестые/;
		$str=~s/семь$/седьмые/;
		$str=~s/восемь$/восьмые/;
		$str=~s/девять$/девятые/;
		$str=~s/десять$/десятые/;
		$str=~s/одинадцать$/одинадцатые/;
		$str=~s/двенадцать$/двенадцатые/;
		$str=~s/тринадцать$/тринадцатые/;
		$str=~s/четырнадцать$/четырнадцатые/;
		$str=~s/пятнадцать$/пятнадцатые/;
		$str=~s/шестнадцать$/шестнадцатые/;
		$str=~s/семьнадцать$/семнадцатые/;
		$str=~s/восемьнадцать$/восемнадцатые/;
		$str=~s/девятнадцать$/девятнадцатые/;
		$str=~s/двадцать$/двадцатые/;
		$str=~s/тридцать$/тридцатые/;
		$str=~s/сорок$/сороковые/;
		$str=~s/пятьдесят$/пятидесятые/;
		$str=~s/шестьдесят$/шестидесятые/;
		$str=~s/семьдесят$/семидесятые/;
		$str=~s/восемьдесят$/восьмидесятые/;
		$str=~s/девяносто$/девяностые/;
		}

	if ($end=~/х$/) {
		$str=~s/один$/первых/;
		$str=~s/два$/вторых/;
		$str=~s/три$/третих/;
		$str=~s/четыре$/четвёртых/;
		$str=~s/пять$/пятых/;
		$str=~s/шесть$/шестых/;
		$str=~s/семь$/седьмых/;
		$str=~s/восемь$/восьмых/;
		$str=~s/девять$/девятых/;
		$str=~s/десять$/десятых/;
		$str=~s/одинадцать$/одинадцатых/;
		$str=~s/двенадцать$/двенадцатых/;
		$str=~s/тринадцать$/тринадцатых/;
		$str=~s/четырнадцать$/четырнадцатых/;
		$str=~s/пятнадцать$/пятнадцатых/;
		$str=~s/шестнадцать$/шестнадцатых/;
		$str=~s/семьнадцать$/семнадцатых/;
		$str=~s/восемьнадцать$/восемнадцатых/;
		$str=~s/девятнадцать$/девятнадцатых/;
		$str=~s/двадцать$/двадцатых/;
		$str=~s/тридцать$/тридцатых/;
		$str=~s/сорок$/сороковых/;
		$str=~s/пятьдесят$/пятидесятых/;
		$str=~s/шестьдесят$/шестидесятых/;
		$str=~s/семьдесят$/семидесятых/;
		$str=~s/восемьдесят$/восьмидесятых/;
		$str=~s/девяносто$/девяностых/;
		}

	if ($end=~/м$/) {
		$str=~s/один$/первом/;
		$str=~s/два$/втором/;
		$str=~s/три$/третьем/;
		$str=~s/четыре$/четвёртом/;
		$str=~s/пять$/пятом/;
		$str=~s/шесть$/шестом/;
		$str=~s/семь$/седьмом/;
		$str=~s/восемь$/восьмом/;
		$str=~s/девять$/девятом/;
		$str=~s/десять$/десятом/;
		$str=~s/одинадцать$/одинадцатом/;
		$str=~s/двенадцать$/двенадцатом/;
		$str=~s/тринадцать$/тринадцатом/;
		$str=~s/четырнадцать$/четырнадцатом/;
		$str=~s/пятнадцать$/пятнадцатом/;
		$str=~s/шестнадцать$/шестнадцатом/;
		$str=~s/семьнадцать$/семнадцатом/;
		$str=~s/восемьнадцать$/восемнадцатом/;
		$str=~s/девятнадцать$/девятнадцатом/;
		$str=~s/двадцать$/двадцатом/;
		$str=~s/тридцать$/тридцатом/;
		$str=~s/сорок$/сороковом/;
		$str=~s/пятьдесят$/пятидесятом/;
		$str=~s/шестьдесят$/шестидесятом/;
		$str=~s/семьдесят$/семидесятом/;
		$str=~s/восемьдесят$/восьмидесятом/;
		$str=~s/девяносто$/девяностом/;
		}

	if ($str=~/$end$/) { } else { uprint("$str (-$end) | @words[$wn-1] @words[$wn] @words[$wn+1]\n"); }

return $str;
}

sub sdigits {
	my $str;
	my $digit=@_[0];
	my $flag=@_[1];

	if ($digit>=0 and $digit<20) {
		if ($flag==1 and $digit==0) { return; }
		$str=@ch_e[$digit];
		return $str;
		}
	if ($digit>=20 and $digit<100) {
		my $ch=floor($digit/10)*10;
		$str=@ch_e[$ch]." ".sdigits($digit-$ch,1);
		return $str;
		}

	if ($digit>=100 and $digit<1000) {
		my $ch=floor($digit/100);
		$str=@ch_s[$ch]." ".sdigits($digit-$ch*100,1);
		return $str;
		}

	if ($digit>=1000) {
		my $ch=floor($digit/1000);
		$str=sdigits($ch)." тысяч ".sdigits($digit-$ch*1000,1);
		return $str;
		}
}

##############

sub dict {
        my ($word)=@_;
        if ($word and !$dict{$word}) {
                my $found=0;
                if ($edict{$word}) { $word=$edict{$word}; $found++; }
                if ($tdict{$word}) { $word=$tdict{$word}; $found++; }
                if ($found==0) { uprint("$word not found in dict\n"); }
                }
return $word;
}
