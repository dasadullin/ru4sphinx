#!/usr/bin/perl

use FindBin qw($Bin);
use POSIX;

my $textfile;
my $outfilename;

if ( $ARGV[0] ) { $textfile=$ARGV[0]; } else { exit; }
if ( $ARGV[1] ) { $outfilename=$ARGV[1]; } else { exit; }

print "input text: $textfile\n
output dict: $outfilename\n";

#my $textfile="/home/SphinxTrain/etc/msu_ru_zero_src.transcription";
#my $outfilename = '/home/SphinxTrain/etc/msu_ru_zero.dic';

#my $textfile     = '/daemon/utils/sphinx/split/1_1_04.text';
#my $outfilename  = '/daemon/utils/sphinx/split/1_1_04.dic';

#my $textfile     = 'text.txt';
#my $outfilename  = 'msu_ru_nsh.dic';

use POSIX;
use utf8;

my %udar;
my %transcription;
my %uniword;
my $word;
my $testword;


# глухие?
$SURD = 'p|pp|f|ff|k|kk|t|tt|sh|s|ss|h|hh|c|ch|sch';
# гласные
$VOWEL = 'а|я|о|ё|у|ю|э|е|ы|и|aa|a|oo|o|uu|u|ee|e|yy|y|ii|i|uj|ay|jo|je|ja|ju';
# все гласные
$STARTSYL = "ь|ъ|$VOWEL";
# смягчаюшие гласные
$SOFTLETTERS = 'ь|я|ё|ю|е|и';
# несмягчающие гласные
$HARDLETTERS = 'ъ|а|о|у|э|ы';
# $NOPAIR_SOFT = '[ч|щ|й]';
# $NOPAIR_HARD = '[ж|ш|ц]';
$NOPAIR = 'ч|щ|й|ж|ш|ц|ch|sch|j|zh|sh|c';
# твёрдые согласные, кроме ж,ш,ц
$HARD_SONAR1 = 'b|v|g|d|z|k|l|m|n|p|r|s|t|f|h';
# твёрдые согласные ж,ш,ц
$HARD_SONAR2 = 'zh|sh|c';
#
$HARD_SONAR="$HARD_SONAR1|$HARD_SONAR2";
# мягкие согласные
$SOFT_SONAR = 'bb|vv|gg|dd|zz|j|kk|ll|mm|nn|pp|rr|ss|tt|ff|hh|ch|sch';
$SOFT_SONAR_SILVER = 'bb|gg|dd|zz|kk|ll|mm|nn|rr|ss|tt|ch|sch';
# все согласные
$ALL_SONAR="$HARD_SONAR|$SOFT_SONAR|ь|ъ";
# звонкие, кроме v,vv,j,l,ll,m,mm,n,nn,r,rr
$RINGING1 = 'b|bb|g|gg|d|dd|zh|z|zz';
# парные твёрдые согласные
$PAIR_HARD = 'б|в|г|д|ж|з|b|v|g|d|zh|z';
$PAIR_HARD1 = "$PAIR_HARD|ц|c";
#
$SOGL='б|в|г|д|з|к|л|м|н|й|п|р|с|т|ф|х|ж|ш|щ|ц|ч|ь|ъ|-|\'';

#####################################################
@dicfile[0]='yo_word.txt';
@dicfile[1]='add_word.txt';
@dicfile[2]='emo_word.txt';
@dicfile[3]='morph_word.txt';
@dicfile[4]='small_word.txt';
@dicfile[5]='sokr_word.txt';
@dicfile[6]='all_form.txt';

foreach (@dicfile)
{
my $infilename  = $_;
open(IN,  "<$Bin/$infilename")  or die ("file $infilename not found");

while (my $inline = <IN>)
{
        chomp $inline;
        utf8::decode($inline);
        my ($clword,$udword) = split(' ',$inline);
	if ($infilename eq 'yo_word.txt') {
		$udword=$clword;
		$udword=~s/ё/\+ё/;
		}
#	$clword=~s/ё/е/g; #!
#	$eword=$clword; $eword=~s/ё/е/g;
	$n=0;
	while (	$udar{$n}{$clword} ) {
		if ($udar{$n}{$clword} eq $udword) {
#			uprint ("duplicate found: $clword ($udword)\n");
			break;
			}
		$n++;
		}
	$udar{$n}{$clword}=$udword;

#### Если слово содёржит Ё добавить его в трнаскрипцию как слово с буквой Е
	if ($clword=~/ё/) {
	$clword=~s/ё/е/g; #!
	$n=0;
	while (	$udar{$n}{$clword} ) {
		if ($udar{$n}{$clword} eq $udword) {
			break;
			}
		$n++;
		}
	$udar{$n}{$clword}=$udword;
	}
####

}

close(IN);
print "Dictionary $infilename loaded\n";
}
#####################################################
my %dict;

open(IN, "<$textfile") or die ("file $textfile not found");
while (my $inline = <IN>)
{
        chomp $inline;
        utf8::decode($inline);
	$inline =~ s/\([\w\d\_\-]+\)//g;
#	$inline=~s/ё/е/g; #!
	$inline=~s/\+//g;

        @words=split(/[^\w\-\']+/,$inline);
        for ($ni = 0; $ni <= $#words; $ni++)
        {
                $word=@words[$ni];
                if ($word and !$dict{$word}) {
                        $dict{$word}++;
                        }
        }

}
close(IN);
#####################################################
open(NEW,  ">$Bin/new_word.txt")  or die ("can't save new_word.txt");

open(WORDS, ">$outfilename")   or die ("can't save $outfilename");
for my $word ( sort keys %dict)
        {
	$clearword=$word;
	$n=0;
	if (!$udar{$n}{$word}) { # если нет в словаре
#	uprint("неизвестное слово: $word");
############## Автоударение ####
	$word =~ s/ё/+ё/g;
	$word =~ s/ьо/ь+о/g;
	$word =~ s/йо/й+о/g;
	$word =~ s/чо/ч+о/g;
	$word =~ s/що/щ+о/g;
        if ($word=~/\+/) { } else
        {
		$word =~ s/нида/н+ида/;		# леонида
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/ирую/+ирую/;		# культивирующаяся
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/напя/нап+я/;		# напяливаете
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/знава/знав\+а/;	# опознаваемых
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/знача/знач\+а/;	# предназначавшаяся
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/ига/иг\+а/;		# отодвигаемого
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/([\w])мина([\w])/$1мин+а$2/;		# воспоминание
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/([\w])лав/$1л+ав/;	# Ярослав
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/([\w])янов/$1+янов/;	# Ульянов
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/([\w])([\w])нович/$1+$2нович/;	# флорентинович
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/какого/как\+ого/;
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/нибудь/ниб\+удь/;
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/сматр/см+атр/;
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/еча/еч\+а/;
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/^кое\-/к+ое-/;
	}

        if ($word=~/\+/) { } else
        {
		$word =~ s/^как([w+])\-/как+$1\-/;
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/^чьего\-/чьег+о\-/;
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/^чьему\-/чьем+у\-/;
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/^чь([\w]+)\-/чь+$1\-/;
	}
        if ($word=~/\+/) { } else
        {
		$word =~ s/^это([\w]+)\-/+это$1\-/;
	}

        if ($word=~/\+/) { } else
        	{
######## Автоматическая установка ударения ##########
        $word =~ s/^(($SOGL)*)($VOWEL)(($SOGL)*)$/$1\+$3$4/;
        $word =~ s/^(($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*)$/$1\+$3$4/;

        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*)$/$1\+$5$6/;
        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)$/$1\+$5$6/;

        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)$/$1\+$7$8/;
        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)$/$1\+$7$8/;

        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)$/$1\+$9$10/;
        $word =~ s/^(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)($VOWEL)(($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*($VOWEL)($SOGL)*)$/$1\+$9$10/;
######## Автоматическая установка ударения ##########
		}
############## Автоударение ####

#		uprint(" -> $word\n");

		my $newword="$clearword $word\n";
        	utf8::encode($newword);
		print NEW $newword;
		$udar{$n}{$clearword}=$word;
		}



	while (	$udar{$n}{$clearword} ) {

		$udword=$udar{$n}{$clearword};
		$trword=trancripts($udword);
		if ($transcription{$trword} eq $udword and $transcription{$clearword}) {
			uprint("skip: $clearword $udword $trword\n");
			$n++; next;
			} else {
#		if ($word eq 'в') { uprint("$n $word $udword $trword\n"); }
		$transcription{$trword}=$udword;
		$transcription{$clearword}++;
		my $str='';
#		if ($n==0) {
		if ($transcription{$clearword}==1) {
			$str="$clearword $trword";
			} else {
			$str="$clearword\(".($transcription{$clearword})."\) $trword";
			}
		utf8::encode($str);
		print WORDS "$str\n";
				}

		$n++;
		}
	}


close(WORDS);
close(NEW);

##########################################################
sub trancripts {
	my ($word)=@_;

	$testword='';
        my(@letters)=split('',$word);
        foreach (@letters) {
                $testword.=" ".$_;
                }
	$testword.=" ";		# установить в конце слова пробел

        my (@dashwords) = split(/\-/,$testword);
	$dashword='';
        foreach (@dashwords)
        {
                $testword=$_;
		&trancript();
		$dashword.=" $testword";
	}
	if ($dashword) {$testword=$dashword; $testword=~s/^\s//;}

return $testword;
}
##########################################################
sub trancript {

$testword=~s/\+\s/\+/g;	# [+ е] -> [+е]
#$testword=~s/\- /ъ /g;	# [о н - т о] -> [о н ъ т о]
$testword=~s/\' /ъ /g;	# [Д'артаньян] -> [Дъартаньян]


# НЕКТОРЫЕ ИСКЛЮЧЕНИЯ
$testword=~s/^( [+]?а) э (л [+]?и)/$1 j $2/;
# $testword=~s/^ б [+]?о г $/ b oo h /;

$testword=~s/^ ч т ([+]?о)/ sh t $1/g;
$testword=~s/(я [+]?и) ч (н [+]?а [+]?я)/$1 sh $2/g;		# яичная
$testword=~s/(р н и) ч (н [+]?а [+]?я)/$1 sh $2/g;		# горничная
$testword=~s/(р о) ч (н [+]?и к)/$1 sh $2/g;			# пятёрочник
$testword=~s/(^ к о н [+]?е) ч (н [+]?о)/$1 sh $2/g;		# конечно
$testword=~s/(^ н а р [+]?о) ч (н [+]?о)/$1 sh $2/g;		# нарочно
$testword=~s/(^ п [+]?о л о) г ([+]?о )$/$1 g $2/g;		# палога
$testword=~s/(^ с т р [+]?о) г ([+]?о )$/$1 g $2/g;		# строго
$testword=~s/^ (д [+]?о р [+]?о) г ([+]?о )$/ $1 g $2/g;	# дорого
$testword=~s/^ (н [+]?е м н [+]?о) г ([+]?о)/ $1 g $2/g;	# немного
$testword=~s/^ (н [+]?а м н [+]?о) г ([+]?о)/ $1 g $2/g;	# намного
$testword=~s/^ (м н [+]?о) г ([+]?о)/ $1 g $2/g;		# много
$testword=~s/^ (д [+]?о р [+]?о) г ([+]?о)/ $1 g $2/g;		# дорого

$testword=~s/([+]?е) г ([+]?о д н [+]?я )$/$1 v $2/g;		# сегодняшнее
$testword=~s/([+]?о) г ([+]?о )$/$1 v $2/g;			# -ого
$testword=~s/([+]?о) г ([+]?о ъ)/$1 v $2/g;
$testword=~s/([+]?е) г ([+]?о )$/$1 v $2/g;			# -его
$testword=~s/([+]?е) г ([+]?о ъ)/$1 v $2/g;
$testword=~s/([+]?е) г ([+]?о с [+]?я )$/$1 v $2/g;
#$testword=~s/([+]?е) г ([+]?о) \-/$1 v $2 \-/g;
#$testword=~s/ъ т ([+]?о) $/ъ t a /g;	# кого-то (-та)
#$testword=~s/^ э (т [+]?о)/ e $1/g;	# этом-то


$testword=~s/т ь с/ц/g;			# девятьсот -> дивицот
$testword=~s/г к/h к/g;			# легка
#$x=$testword;
#$testword=~s/ь [+]?о/ь j o/g;		# лосьон
#if ($x ne $testword) { print $testword."\n"; }


# ( # ж е [ н ] щ и н = nn )
# ( к р е м л [ е ] в  = o )
# ( # [ э ] к с к у р = i )
# ( # [ э ] л е к т р = i )
# $testword=~s/е ё/j e j oo/g;
# $testword=~s/^  а р т и л л е р/ а р т и ll е р/g;

# заимтвованные слова произносящиеся через "Э"
$testword=~s/(с [+]?и н) т ([+]?е з)/$1 t $2/g;
$testword=~s/([+]?и н) т ([+]?е р (в|ф|п))/$1 t $1/g;
$testword=~s/([+]?э с) т ([+]?е т)/$1 t $2/g;
$testword=~s/([+]?а) н ([+]?е л [+]?я)/$1 n $2/g;
$testword=~s/^ (с [+]?о) н ([+]?е т)/ $1 n $2/g;
$testword=~s/(т [+]?у н) н ([+]?е л)/$1 n $2/g;
$testword=~s/^ б ([+]?е к [+]?и н г)/ b $1/g;
$testword=~s/^ б ([+]?е й к [+]?е р)/ b $2/g;
$testword=~s/^ (м [+]?о) д ([+]?е с т)/ $1 d $2/g;
$testword=~s/^ ([+]?э к) з ([+]?е м)/ $1 z $2/g;
$testword=~s/^ ([+]?э) н ([+]?е й)/ $1 n $2/g;
$testword=~s/^ б р ([+]?е н д [+]?и)/ б r $1/g;

# Упрощение групп согласных (непроизносимый согласный)
$testword=~s/с т л/s л/g;	# стл – [сл]: счастливый сча[сл’]ивый
$testword=~s/с т н/s н/g;	# стн – [сн]: местный ме[сн]ый
$testword=~s/з д н/z н/g;	# здн – [сн]: поздний по[з’н’]ий ([зн]: поздний по[зн’]ий)
$testword=~s/з д ц/s ц/g;	# здц – [сц]: под уздцы под у[сц]ы
$testword=~s/н д ш/n ш/g;	# ндш – [нш]: ландшафт ла[нш]афт
$testword=~s/н т г/n г/g;	# нтг – [нг]: рентген ре[нг’]ен
$testword=~s/н д ц/n ц/g;	# ндц – [нц]: голландцы голла[нц]ы
$testword=~s/р д ц/r ц/g;	# рдц – [рц]: сердце се[рц]е
$testword=~s/р д ч/r ч/g;	# рдч – [рч’]: сердчишко се[рч’]ишко
$testword=~s/л н ц/n ц/g;	# лнц – [нц]: солнце со[нц]е

# Не читаемые фонемы
$testword=~s/т с [+]?я/c я/g;
$testword=~s/с ш [+]?е с т/sh е с т/g;
$testword=~s/с т с/s с/g;
$testword=~s/с т ь с/s с/g;
$testword=~s/с т ц/s ц/g;
$testword=~s/в с т в/с т в/g;
$testword=~s/н т ц/n ц/g;
$testword=~s/н т с/n с/g;
$testword=~s/н д с/n с/g;
$testword=~s/н г т/n т/g;
$testword=~s/ч ш/t ш/g;
$testword=~s/д ц/ц/g;


# варианты произношения: в слове «двоечник» произносится звукосочетание [чн], но допускается произношение [шн]
# произношение [шн] на месте ЧН в некоторых словах: яичница, скучный, что, чтобы, конечно
# редуцирование (количественное и качественное) гласных в безударных слогах (в[а]да')
# наличие непроизносимых согласных (солнце, голландский)
# оглушение согласных на конце слова (пло[т] – плоды)
# сохранение твердого согласного во многих иноязычных словах перед Е (т[э]мп)
# произношение глухой пары фрикативного Г - [γ] – в слове БОГ (бо[х])
# ассимилирование согласных, вплоть до полного (ко[з’]ба, до[щ’])
# стяжения и мены звуков в разговорной речи ([маривана] вместо Мария Ивановна; [барелина] вместо балерина)
# При этом различают быстрое разговорное произношение, когда мы в потоке речи стягиваем и выпускаем слова, слоги,
# сильно редуцируем гласные, кратко произносим согласные, и сценическое произношение, когда текст декламируется нараспев,
# четко произносятся все звуки, проговариваются.
# Ударение в русском языке силовое, т.е. ударный слог выделяется силой голоса. Гласный в ударном слоге слышится отчетливо, он длиннее безударного гласного.

# Русское ударение выполняет несколько важных функций:
# - смыслоразличительную, т.к. различает один из видов омонимов – омографы (за'мок – замок'),
# - форморазличительную, т.к. отличает друг от друга формы одного и того же слова (воды' в род п. ед. ч. – во'ды в им. п. мн.ч.),
# - стилистическую, т.к. отличает варианты и формы общенародного языка (проф. шо'фер – общелит. шофер').

# Work around doubled consonants.

$testword=~s/^ ([+]?э) м м/ $1 m м/g;
$testword=~s/б б/б/g;
$testword=~s/т т/т/g;
$testword=~s/с с/с/g;
$testword=~s/ф ф/ф/g;
$testword=~s/р р/р/g;
$testword=~s/н н/н/g;
$testword=~s/м м/м/g;
$testword=~s/к к/к/g;
$testword=~s/п п/п/g;
$testword=~s/л л/л/g;
$testword=~s/з з/з/g;


# обозначают гласный и мягкость предшествующего парного по твердости / мягкости согласного звука: мёл [м'ол] – ср.: мол [мол]
# исключение может составлять буква е в заимствованных словах, не обозначающая мягкости предшествующего согласного – пюре [п'урэ́];

$testword=~s/б ([+]?($SOFTLETTERS)) /bb $1 /g;
$testword=~s/в ([+]?($SOFTLETTERS)) /vv $1 /g;
$testword=~s/г ([+]?($SOFTLETTERS)) /gg $1 /g;
$testword=~s/д ([+]?($SOFTLETTERS)) /dd $1 /g;
$testword=~s/з ([+]?($SOFTLETTERS)) /zz $1 /g;
$testword=~s/к ([+]?($SOFTLETTERS)) /kk $1 /g;
$testword=~s/л ([+]?($SOFTLETTERS)) /ll $1 /g;
$testword=~s/м ([+]?($SOFTLETTERS)) /mm $1 /g;
$testword=~s/н ([+]?($SOFTLETTERS)) /nn $1 /g;
$testword=~s/п ([+]?($SOFTLETTERS)) /pp $1 /g;
$testword=~s/р ([+]?($SOFTLETTERS)) /rr $1 /g;
$testword=~s/с ([+]?($SOFTLETTERS)) /ss $1 /g;
$testword=~s/т ([+]?($SOFTLETTERS)) /tt $1 /g;
$testword=~s/ф ([+]?($SOFTLETTERS)) /ff $1 /g;
$testword=~s/х ([+]?($SOFTLETTERS)) /hh $1 /g;

# ан'тичнось
$testword=~s/ н (tt|sch|ch) / nn $1 /g;
$testword=~s/ с (tt|sch|ch) / ss $1 /g;

#$testword=~s/ ([+]?($SOFTLETTERS)) б ($SOFT_SONAR) / $1 bb $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) в ($SOFT_SONAR) / $1 vv $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) г ($SOFT_SONAR) / $1 gg $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) д ($SOFT_SONAR) / $1 dd $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) з ($SOFT_SONAR) / $1 zz $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) к ($SOFT_SONAR) / $1 kk $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) л ($SOFT_SONAR) / $1 ll $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) м ($SOFT_SONAR) / $1 mm $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) п ($SOFT_SONAR) / $1 pp $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) р ($SOFT_SONAR) / $1 rr $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) т ($SOFT_SONAR) / $1 tt $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) ф ($SOFT_SONAR) / $1 ff $3 /g;
#$testword=~s/ ([+]?($SOFTLETTERS)) х ($SOFT_SONAR) / $1 hh $3 /g;


# простые твёрдые
$testword=~s/б/b/g;
$testword=~s/в/v/g;
$testword=~s/г/g/g;
$testword=~s/д/d/g;
$testword=~s/ж/zh/g;
$testword=~s/з/z/g;
$testword=~s/к/k/g;
$testword=~s/л/l/g;
$testword=~s/м/m/g;
$testword=~s/н/n/g;
$testword=~s/п/p/g;
$testword=~s/р/r/g;
$testword=~s/с/s/g;
$testword=~s/т/t/g;
$testword=~s/ф/f/g;
$testword=~s/х/h/g;
$testword=~s/ц/c/g;
$testword=~s/ш/sh/g;

# и мягкие звуки
$testword=~s/ч/ch/g;
$testword=~s/щ/sch/g;
$testword=~s/й/j/g;

# звонкие парные меняются на глухие в абсолютном конце (оглушаются)

#$testword=~s/ b $/ p /;
#$testword=~s/ v $/ f /;
#$testword=~s/ g $/ k /;
#$testword=~s/ d $/ t /;
#$testword=~s/ zh $/ sh /;
#$testword=~s/ z $/ s /;
#$testword=~s/ bb $/ pp /;
#$testword=~s/ vv $/ ff /;
#$testword=~s/ gg $/ kk /;
#$testword=~s/ dd $/ tt /;
#$testword=~s/ zz $/ ss /;

$testword=~s/ b (ъ )?$/ p $1/;
$testword=~s/ v (ъ )?$/ f $1/;
$testword=~s/ g (ъ )?$/ k $1/;
$testword=~s/ d (ъ )?$/ t $1/;
$testword=~s/ z (ъ )?$/ s $1/;
$testword=~s/ zh (ъ )?$/ sh $1/;
$testword=~s/ bb (ъ )?$/ pp $1/;
$testword=~s/ vv (ъ )?$/ ff $1/;
$testword=~s/ gg (ъ )?$/ kk $1/;
$testword=~s/ dd (ъ )?$/ tt $1/;
$testword=~s/ zz (ъ )?$/ ss $1/;


# Мягкие сгласные в конце оглушаются ?
$testword=~s/ zh ь $/ sh ь /;
$testword=~s/ bb ь $/ pp ь /;
$testword=~s/ vv ь $/ ff ь /;
$testword=~s/ gg ь $/ kk ь /;
$testword=~s/ dd ь $/ tt ь /;
$testword=~s/ zz ь $/ ss ь /;

# звонкие парные меняются на глухие перед глухими (оглушаются)
$testword=~s/ b ($SURD)/ p $1/g;
$testword=~s/ v ($SURD)/ f $1/g;
$testword=~s/ g ($SURD)/ k $1/g;
$testword=~s/ d ($SURD)/ t $1/g;
$testword=~s/ z ($SURD)/ s $1/g;
$testword=~s/ zh ($SURD)/ sh $1/g;
$testword=~s/ bb ($SURD)/ pp $1/g;
$testword=~s/ vv ($SURD)/ ff $1/g;
$testword=~s/ gg ($SURD)/ kk $1/g;
$testword=~s/ dd ($SURD)/ tt $1/g;
$testword=~s/ zz ($SURD)/ ss $1/g;

# глухие парные, стоящие перед звонкими (кроме ... ) меняются за звонкие
$testword=~s/ p ($RINGING1)/ b $1/g;
$testword=~s/ f ($RINGING1)/ v $1/g;
$testword=~s/ k ($RINGING1)/ g $1/g;
$testword=~s/ t ($RINGING1)/ d $1/g;
$testword=~s/ sh ($RINGING1)/ zh $1/g;
$testword=~s/ s ($RINGING1)/ z $1/g;
#$testword=~s/ pp ($RINGING1)/ bb $1/g;
#$testword=~s/ ff ($RINGING1)/ vv $1/g;
#$testword=~s/ kk ($RINGING1)/ gg $1/g;
#$testword=~s/ tt ($RINGING1)/ dd $1/g;
#$testword=~s/ ss ($RINGING1)/ zz $1/g;
$testword=~s/ь $//;			# мягкий знак на конце больше не интересует




# Позиционное употребление согласных по имым признакам. Расподобление согласных.
$testword=~s/ s sh / sh /g;	# [с] + [ш]  -> [шш]: сшить [шшыт’] = [шыт’]
$testword=~s/ s ch / sch /g;	# [с] + [ч’] -> [щ’] или [щ’ч’]: с чем-то [щ’э́мта] или [щ’ч’э́мта],
$testword=~s/ s sch / sch /g;	# [с] + [щ’] -> [щ’]: расщепить [ращ’ип’и́т’]
$testword=~s/ z zh / zh /g;	# [з] + [ж]  -> [жж]: изжить [ижжы́т’] = [ижы́т’]
$testword=~s/ t s / c /g;	# [т] + [с]  -> [цц] или [цс]: мыться [мы́цца] = [мы́ца], отсыпать [ацсы́пат’]
$testword=~s/ t c / c /g;	# [т] + [ц]  -> [цц]: отцепить [аццып’и́т’] = [ацып’и́т’]
$testword=~s/ t ch / ch /g;	# [т] + [ч’] -> [ч’ч’]: отчет [ач’ч’о́т] = [ач’о́т]
$testword=~s/ t sch / ch sch /g;# [т] + [щ’] -> [ч’щ’]: отщепить [ач’щ’ип’и́т’]

# Спецзамена
$testword=~s/Б/b/g;
$testword=~s/В/v/g;
$testword=~s/Г/g/g;
$testword=~s/Д/d/g;
$testword=~s/Ж/zh/g;
$testword=~s/З/z/g;
$testword=~s/К/k/g;
$testword=~s/Л/l/g;
$testword=~s/М/m/g;
$testword=~s/Н/n/g;
$testword=~s/П/p/g;
$testword=~s/Р/r/g;
$testword=~s/С/s/g;
$testword=~s/Т/t/g;
$testword=~s/Ф/f/g;
$testword=~s/Х/h/g;
$testword=~s/Ц/c/g;
$testword=~s/Ш/sh/g;
$testword=~s/Ч/ch/g;
$testword=~s/Щ/sch/g;
$testword=~s/Й/j/g;


&transcript7();
&transcript0();

$testword=~s/ ъ//g;
$testword=~s/ ь//g;
$testword=~s/\+//g;
$testword=~s/^\s//;
$testword=~s/\s$//;


}

##################################################

sub transcript7 {

# не читаемые фонемы
$testword=~s/([+]?и) о ([+]?а)/$1 $2/g;			# радиоактивных [иоа]

# Й
$testword=~s/( [+]?($STARTSYL) |^ )([+]?[юяеё])/$1\j $3/g;	# звуки [ ю я е ё ]
$testword=~s/((ь|ъ) )([+]?[иоэ])/$1\j $3/g;			# бабьим [бабьйим], лосьон [лосьён]

# после твёрдых согласных - гласные становятся грухими
$testword=~s/( ($HARD_SONAR) [+]?)и/$1ы/g;
$testword=~s/( ($HARD_SONAR) [+]?)е/$1э/g;
$testword=~s/( ($HARD_SONAR) [+]?)я/$1а/g;
$testword=~s/( ($HARD_SONAR) [+]?)ё/$1о/g;
$testword=~s/( ($HARD_SONAR) [+]?)ю/$1у/g;

# после мягких согласных - гласные становятся звонкими
$testword=~s/( ($SOFT_SONAR) [+]?)ы/$1и/g;
$testword=~s/( ($SOFT_SONAR) [+]?)э/$1е/g;
$testword=~s/( ($SOFT_SONAR) [+]?)а/$1я/g;
$testword=~s/( ($SOFT_SONAR) [+]?)о/$1ё/g;
$testword=~s/( ($SOFT_SONAR) [+]?)у/$1ю/g;

# ^Г
$testword=~s/(^ )[ао]/$1a/g;	#+
$testword=~s/(^ )[эи]/$1i/g;	#+
$testword=~s/(^ )[ы]/$1y/g;	#+
$testword=~s/(^ )[у]/$1u/g;	#+

# Г$
$testword=~s/ [ао] $/ ay /g;	#+
$testword=~s/ [ияэеё] $/ i /g;	#+
$testword=~s/ [ы] $/ y /g;	#+
$testword=~s/ [ю] $/ uj /g;	#+
$testword=~s/ [у] $/ u /g;	#+

# Г + Г
#$testword=~s/ ([+]?($VOWEL)) [аяоё]/ $1 a/g;
#$testword=~s/ ([+]?($VOWEL)) [эе]/ $1 y/g;

############ Первая степень редукции ########
$testword=~s/ (zh|sh) [о](( ($ALL_SONAR))* \+($STARTSYL))/ $1 y$2/g;	# I - жЕлтели
$testword=~s/ [ао](( ($ALL_SONAR))* \+($STARTSYL))/ a$1/g;		# V - зАвод
############ Первая степень редукции ########

############ Вторая степень редукции ########
$testword=~s/ [ао]/ ay/g;	# @ - мОлоко
$testword=~s/ [у]/ u/g;		# U - Укол
$testword=~s/ [иея]/ i/g;	# $ - тЕперь
$testword=~s/ [ыэ]/ y/g;	# I - Этаж
$testword=~s/ [ю]/ uj/g;	# Y - новуЮ
############ Вторая степень редукции ########

# ое - не убирается?
$testword=~s/ ($VOWEL) j ($VOWEL) / $1 $2 /g;		# звук j между безударными гласными не произносится

}


# А - Альт - aa
# l - Ыкать - yy
# о - Он - oo
# u - Угол - uu
# E - Этот - ee
# 9 - нЁс - jo
# e - Есть je
# { - пЯть - ja
# } - лЮк - ju
# i - идИ - ii

# V - зАвод - a
# @ - мОлоко - ay
# U - Укол - u
# Y - новуЮ - uj
# I - Этаж - y
# $ - тЕперь - i

# Z-zh
# S-sh
# S'-sch
# Z'-Щ на конце
# ts - Ц в начале
# dz - Ц спеЦ-завод
# tS' - Чуть
# dZ' Начдив
# j - Йод
# dZ - ДЖем
# tS - имиДЖ
# дц - tts
# цз  - dz

sub transcript0 {
# типовая замена ударных гласных ##############
$testword=~s/\+а/aa/g;
$testword=~s/\+ы/yy/g;
$testword=~s/\+о/oo/g;
$testword=~s/\+у/uu/g;
$testword=~s/\+э/ee/g;
$testword=~s/\+и/ii/g;
$testword=~s/[\+]?ё/jo/g;
$testword=~s/\+е/je/g;
$testword=~s/\+я/ja/g;
$testword=~s/\+ю/ju/g;

# Спецзамена
$testword=~s/А/a/g;

}

######################
sub uprint {
        my ($vtxt)=@_;
        utf8::encode($vtxt);
        print $vtxt;
}
######################