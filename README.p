{mfdtitle.i}
define variable input_filename as character format "X(74)".
update input_filename.
input from value(input_filename) no-echo.
output to value(input_filename + ".log") keep-message.
define variable strdateformate as character.
strdateformat = session:date-format.
session:date-format = "mdy".
batchrun = yes.
{gprun.i ""standard.p""}
batchrun = no.
session:date-format = strdateformat.
hide message
no-pause.
output close.
input close.
