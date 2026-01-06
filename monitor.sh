#!/bin/bash

ROSU='\033[0;31m'
VERDE='\033[0;32m'
GALBEN='\033[1;33m'
ALBASTRU='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

TXT_VECHI="$1"
TXT_NOU="$2"

if [ -z "$TXT_VECHI" ] || [ -z "$TXT_NOU" ]; then
    echo -e "${ROSU}[EROARE]${NC} Lipsesc fișierele de intrare."
    echo -e "Utilizare: $0 status_vechi.txt status_nou.txt"
    exit 1
fi

analiza_disc() {
	echo -e "\n${ALBASTRU}=== 1. ANALIZA SPATIU PE DISC (Evoluție) ===${NC}"

	DISK_VECHI=$(grep " /$" "$TXT_VECHI")
	DISK_NOU=$(grep " /$" "$TXT_NOU")

	USED_V=$(echo "$DISK_VECHI" | awk '{print $3}')
	USED_N=$(echo "$DISK_NOU" | awk '{print $3}')

	if [ "$USED_N" -gt "$USED_V" ]; then
		DIF=$((USED_N - USED_V))
		MB=$((DIF / 1024))
		echo -e "${ROSU}[!] Spatiul ocupat a CRESCUT cu aprox. ${MB} MB${NC} ($DIF KB)."
		echo -e "   Înainte: $USED_V KB -> Acum: $USED_N KB"

	elif [ "$USED_N" -lt "$USED_V" ]; then
		DIF=$((USED_V - USED_N))
		MB=$((DIF / 1024))
		echo -e "${VERDE}[OK] S-a eliberat spatiu: ${MB} MB${NC} ($DIF KB)."
	else
		echo -e "${VERDE}[OK] Nicio modificare a spatiului pe disc.${NC}"
	fi
}

analiza_fisiere() {
	echo -e "\n${ALBASTRU}=== 2. ANALIZA MODIFICARI FISIERE (ls -l) ===${NC}"

	grep "^[-d]" "$TXT_VECHI" > /tmp/files_old.tmp
	grep "^[-d]" "$TXT_NOU" > /tmp/files_new.tmp

	DIFERENTE=$(diff -w /tmp/files_old.tmp /tmp/files_new.tmp)

	if [ -z "$DIFERENTE" ]; then
		echo -e "${VERDE}Nu s-au detectat modificări în structura fișierelor.${NC}"
	else
		echo -e "${GALBEN}S-au detectat următoarele schimbări:${NC}"

		echo "$DIFERENTE" | while IFS= read -r line; do
			if [[ $line == ">"* ]]; then
				F_NAME=$(echo "$line" | sed 's/^> //')
				echo -e "   ${VERDE}[+] APĂRUT/MODIFICAT:${NC} $F_NAME"
			elif [[ $line == "<"* ]]; then
				F_NAME=$(echo "$line" | sed 's/^< //')
				echo -e "   ${ROSU}[-] ȘTERS:${NC} $F_NAME"
			fi
		done
	fi
	echo -e "\n"
}

analiza_fisiere_updated() {
	echo -e "\n${ALBASTRU}=== 2. ANALIZA MODIFICARI FISIERE  ===${NC}"

        grep "^[-d]" "$TXT_VECHI" | tr -s ' ' > /tmp/lista_veche.tmp
	grep "^[-d]" "$TXT_NOU"   | tr -s ' ' > /tmp/lista_noua.tmp

        MODIFICARI_DETECTATE=0

        while read -r linie_noua; do

                nume=$(echo "$linie_noua" | awk '{print $NF}' | tr -d '\r\n')

		size_nou=$(echo "$linie_noua" | awk '{print $5}' | tr -d '\r\n')

                linie_veche=$(grep " $nume" /tmp/lista_veche.tmp | tail -n 1)

                if [ -z "$linie_veche" ]; then
                        echo -e "	${VERDE}[+] APARUT(NOU):${NC}   $nume	$size_nou"
                        MODIFICARE_DETECTATE=1
                else
			size_vechi=$(echo "$linie_veche" | awk '{print $5}' | tr -d '\r\n')
                        if [ "$size_nou" != "$size_vechi" ]; then
                                echo -e "	${GALBEN}[*] MODIFICAT:${NC}	$nume	( Marime $size_vechi --> $size_nou )"
                                MODIFICARI_DETECTATE=1
                        fi
                fi
        done < /tmp/lista_noua.tmp

        while read -r linie_veche; do
                nume=$(echo "$linie_veche" | awk '{print $NF}')
                exista_in_nou=$(grep " $nume$" /tmp/lista_noua.tmp | tail -n 1)

                if [ -z "$exista_in_nou" ]; then
                        echo -e "	${ROSU}[-] STERS:${NC}  $nume"
                        MODIFICARI_DETECTATE=1
                fi
        done < /tmp/lista_veche.tmp

        if [ $MODIFICARI_DETECTATE -eq 0 ]; then
                echo -e "${VERDE} Nu s-au detectat modifcari in structura fisierelor.${NC}"
        fi
        echo -e "\n"

}

analiza_disc
analiza_fisiere_updated
