package ## no critic: Modules::RequireFilenameMatchesPackage
    # hide from PAUSE
    TableDataRole::Calendar::Date::Holiday::ID;

use 5.010001;
use strict;
use warnings;

use Role::Tiny;
with 'TableDataRole::Source::AOA';

around new => sub {
    require Calendar::Indonesia::Holiday;

    my $orig = shift;

    my $res = Calendar::Indonesia::Holiday::list_idn_holidays(detail=>1);
    die "Can't list holidays from Calendar::Indonesia::Holiday: $res->[0] - $res->[1]"
        unless $res->[0] == 200;

    my $aoa = [];
    my $column_names = [qw/
                              date day month year dow fixed_date
                              eng_name ind_name
                              is_holiday is_joint_leave
                              is_tag_religious is_tag_calendar_lunar
                              year_start
                              tags
                          /];
    for my $rec (@{ $res->[2] }) {
        push @$aoa, [
            $rec->{date},
            $rec->{day},
            $rec->{month},
            $rec->{year},
            $rec->{dow},
            $rec->{fixed_date} ? 1:0,

            $rec->{eng_name},
            $rec->{ind_name},

            $rec->{is_holiday},
            $rec->{is_joint_leave},

            ((grep { $_ eq 'religious' } @{ $rec->{tags} // [] }) ? 1:0),
            ((grep { $_ eq 'calendar=lunar' } @{ $rec->{tags} // [] }) ? 1:0),

            $rec->{year_start},

            join(", ", @{ $rec->{tags} // [] }),
        ];
    }

    $orig->(@_, aoa => $aoa, column_names=>$column_names);
};

package TableData::Calendar::Date::Holiday::ID;

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;

# AUTHORITY
# DATE
# DIST
# VERSION

with 'TableDataRole::Calendar::Date::Holiday::ID';

# STATS

1;
# ABSTRACT: Indonesian holiday dates

=head1 DESCRIPTION

This table gets its data dynamically by querying
L<Calendar::Indonesia::Holiday>, so this is basically just a L<TableData>
interface for C<Calendar::Indonesia::Holiday>.
