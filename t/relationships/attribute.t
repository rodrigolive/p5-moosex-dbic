use Test::More;
use SQL::Translator;

use Data::Dumper;

BEGIN{$Data::Dumper::Maxdepth = 3;
$Data::Dumper::Indent = 1;
}

package CD;
use MooseX::DBIC;
    
has_column 'title';
belongs_to 'artist';
might_have 'cover';
might_have cover2 => ( isa => 'CD::Cover', foreign_key => 'cd2' );

package Artist;
use MooseX::DBIC;

has_column 'name';
has_many cds => ( isa => 'CD' );

package CD::Cover;
use MooseX::DBIC;

has_column 'name';
belongs_to 'cd' => ( isa => 'CD' );
belongs_to 'cd2' => ( isa => 'CD' );


package main;

{
    ok(my $rel = CD->meta->get_relationship('artist'), 'get belongs_to relationship artist');
    is($rel->accessor, 'artist', 'is => rw');
    ok($rel->has_read_method && $rel->has_write_method, 'has reader and writer');
    ok($rel->is_lazy, 'is lazy');
    is($rel->related_class, 'Artist', 'related class is Artist');
    is($rel->foreign_key, $rel, 'foreign key is artist in Artist');
}

{
    ok(my $rel = CD->meta->get_relationship('cover'), 'get might_have relationship cover');
    is($rel->accessor, 'cover', 'is => rw');
    ok($rel->has_read_method && $rel->has_write_method, 'has reader and writer');
    ok($rel->is_lazy, 'is lazy');
    is($rel->related_class, 'CD::Cover', 'related class is CD::Cover');
    is($rel->foreign_key, CD::Cover->meta->get_relationship('cd'), 'foreign key is cd in CD::Cover');
}

{
    ok(my $rel = CD->meta->get_relationship('cover2'), 'get might_have relationship cover2');
    is($rel->related_class, 'CD::Cover', 'related class is CD::Cover');
    is($rel->foreign_key, CD::Cover->meta->get_relationship('cd2'), 'foreign key is cd2 in CD::Cover');
}

done_testing;
