#!/bin/bash

RAW_VECHI="status_vechi.raw"
RAW_NOU="status_nou.raw"
TXT_VECHI="status_vechi.txt"
TXT_NOU="status_nou.txt"

FISIER_MARE="fisier_mare.tmp"

rm -f "$RAW_VECHI" "$RAW_NOU" "$TXT_VECHI" "$TXT_NOU" document_nou.txt

script -q -c "ls -l; df -P /" $RAW_VECHI
col -b < $RAW_VECHI > $TXT_VECHI

echo -e "\n Cream un fisier mare pentru a simula modificari"

touch document_nou.txt

dd if=/dev/zero of=$FISIER_MARE bs=1M count=500 status=none
sleep 2

script -q -c "ls -l; df -P/" $RAW_NOU
col -b < $RAW_NOU > $TXT_NOU

if [ -f "./monitor.sh" ]; then
	chmod +x monitor.sh
	./monitor.sh $TXT_VECHI $TXT_NOU
fi

rm -f $FISIER_MARE

echo -e "\n Fisier mare pt simulare sters"
