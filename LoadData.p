{mfdtitle.i}
define temp-table tmp2 no-undo
field tmp_filename  as character
field tmp_error as character.

define temp-table tmp no-undo
    field tmp_cimfullpath as character.

DEFINE VARIABLE input_filename AS CHARACTER FORMAT "x(76)" .
update input_filename.
input from value(input_filename) no-echo.
repeat:
    create tmp.
    import tmp_cimfullpath.
end.
input close.

cimloop:
DO TRANSACTION :
    for each tmp where tmp_cimfullpath <> "" :
        input from value(tmp_cimfullpath) no-echo.
        output to value(tmp_cimfullpath + ".log") keep-messages.
        def var strdateformat as char .
        strdateformat = session:date-format .
        session:date-format = "mdy" .
        batchrun = yes.
        {gprun.i ""popomt.p""}
        batchrun = no.
        session:date-format = strdateformat .
        hide message
        no-pause.
        output close.
        input close.

        DEFINE VARIABLE hasError AS LOGICAL.
        DEFINE VARIABLE v_line_o AS CHARACTER FORMAT "X(300)" .
        input from value (tmp_cimfullpath + ".log") .
        repeat:
            import unformatted v_line_o.
            if index (v_line_o,"error:")    <> 0 or    /* for us langx */
            index (v_line_o,"´íÎó:")        <> 0 or    /* for ch langx */
            index (v_line_o,"¿ù»~:")        <> 0 or    /* for tw langx */
            index (v_line_o,"(87)")         <> 0 or
            index (v_line_o,"(557)")        <> 0 or
            index (v_line_o,"(143)")        <> 0
            then do:
                hasError = yes .
                leave.
            end.
        end. /*repeat:*/
        input close.

        if hasError then do:
            find first tmp2 where tmp_filename = (tmp_cimfullpath + ".log") no-lock no-error.
            if not available tmp2 then do:
                create tmp2.
                assign
                    tmp_filename = (tmp_cimfullpath + ".log")
                    tmp_error = v_line_o
                .
            end.
            else tmp_error = v_line_o.
        end.
    end.
    find first tmp2 where tmp_error <> "" no-lock no-error.
    if available tmp2 then do:
        undo cimloop,leave.
    end.
end.