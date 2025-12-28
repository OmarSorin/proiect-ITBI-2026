#!/bin/bash

    INPUT_LOG="sesiune_test.log"
    curata_log(){
        sed -r 's|\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]||g' "$INPUT_LOG" | col -b > log_curat.tmp
    }

    extrage_date() {
        grep -n "ls -l" log_curat.tmp > linii_ls.tmp
        grep -n "df" log_curat.tmp > linii_df.tmp
        LINIE_LS_T1=$(head -n 1 linii_ls.tmp | cut -d: -f1)
        LINIE_LS_T2=$(tail -n 1 linii_ls.tmp | cut -d: -f1)
        sed -n "$((LINIE_LS_T1 + 1)),$((LINIE_LS_T1 + 20))p" log_curat.tmp > ls_t1.tmp
        sed -n "$((LINIE_LS_T2 + 1)),$((LINIE_LS_T2 + 20))p" log_curat.tmp > ls_t2.tmp
    }

    compara_ls(){
        echo -e "\n=== Analiza evolutiei fisierelor (ls -l) === "
        awk '/^-/{print $9, $5}' ls_t1.tmp | grep -v "^$" > date_t1.tmp
        awk '/^-/{print $9, $5}' ls_t2.tmp | grep -v "^$" > date_t2.tmp

        echo "Fisiere adaugate:"
        comm -13 <(sort date_t1.tmp) <(sort date_t2.tmp) | awk '{printf " [+] %s (%s bytes)\n", $1, $2}'
        echo "Fisiere eliminate:"
        comm -23 <(sort date_t1.tmp) <(sort date_t2.tmp) | awk '{printf " [-] %s\n", $1}'

    }
