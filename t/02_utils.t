use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Utils;

like date(time) => qr/^[0-9]{4}\-[0-9]{2}\-[0-9]{2}$/, "expected date format";
like datetime(time) => qr/^[0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/, "expected datetime format";

is decimal(5.7) => '5.70', "expected decimal format";
is decimal(0.1) => '0.10', "expected decimal format";

is percent(10, 100) => '10.00', "expected percent format";

done_testing;
