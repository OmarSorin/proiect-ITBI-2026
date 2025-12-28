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
	echo -e "\n${ALBASTRU}=== 1. ANALIZA SPAȚIU PE DISC (Evoluție) ===${NC}"

	DISK_VECHI=$(grep " /$" "$TXT_VECHI")
	DISK_NOU=$(grep " /$" "$TXT_NOU")

	USED_V=$(echo "$DISK_VECHI" | awk '{print $3}')
	USED_N=$(echo "$DISK_NOU" | awk '{print $3}')

	if [ "$USED_N" -gt "$USED_V" ]; then
		DIF=$((USED_N - USED_V))
		MB=$((DIF / 1024))
		echo -e "${ROSU}[!] Spațiul ocupat a CRESCUT cu aprox. ${MB} MB${NC} ($DIF KB)."
		echo -e "   Înainte: $USED_V KB -> Acum: $USED_N KB"

	elif [ "$USED_N" -lt "$USED_V" ]; then
		DIF=$((USED_V - USED_N))
		MB=$((DIF / 1024))
		echo -e "${VERDE}[OK] S-a eliberat spațiu: ${MB} MB${NC} ($DIF KB)."
	else
		echo -e "${VERDE}[OK] Nicio modificare a spațiului pe disc.${NC}"
	fi
}

analiza_fisiere() {
	echo -e "\n${ALBASTRU}=== 2. ANALIZA MODIFICĂRI FIȘIERE (ls -l) ===${NC}"

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

analiza_disc
analiza_fisiere
