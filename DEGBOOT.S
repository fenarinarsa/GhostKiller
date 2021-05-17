	opt	p+
DEBUT_PROG:
	BRA.S	CONT
MSG	DC.B	27,'ENo picture loaded!',10,13,'¢ 1992 Rick ST',0
MSG2	DC.B	27,'EDegas loader v1.4',10,13,'¢ 1992 Rick ST',0

CONT	MOVE.W	#-1,-(A7)	; Appel Kbshift
	MOVE.W	#$B,-(A7)
	TRAP	#13
	ADDQ.L	#4,A7

	LEA	MSG(PC),A0
	LEA	CONT(PC),A1
	LEA	$6F000,A2
DECODE1	MOVE.B	(A0)+,(A2)
	NOT.B	(A2)+
	CMP.L	A1,A0
	BLT.S	DECODE1
	
	CMP.B	#%1001,$FFFF8001.W	Teste si 2.5 Mo
	BNE.S	NOMEG
	CMP.L	#$280000,$42E.W
	BEQ.S	NOMEG
	
	MOVE.L	#$280000,$42E.W
	MOVE.L	#$278000,$436.W
	MOVE.L	#$278000,$44E.W
	MOVE.L	#$237698AA,$43A.W
	MOVE.L	#$752019F3,$420.W
	MOVE.B	#%1001,$424.W
	MOVE.L	$4.W,A0
	JMP	(A0)

NOMEG	CMP.L	#'DL14',$5FC.W	; Teste Flag (mis si on sort
	BEQ	END		;  d'un reset)
	MOVE.L	#'DL14',$5FC.W	; Pas mis => On le place

	AND.B	#%1000,D0	; [Alternate] appuyé?
	BNE	END	; Pas de chargement
	
	MOVE.W	#4,-(A7)	; Appel GetRez (résolution)
	TRAP	#14
	ADDQ.L	#2,A7
	lea	NOM(PC),a6
	ADD.B	D0,10(a6)	; Change le nom du fichier en conséquence

	MOVE.W	#$19,-(A7)	; Appel DGETDRV (drive courant)
	TRAP	#1
	ADDQ.L	#2,A7
	ADD.B	D0,(a6)	; Pareil, on change le nom

	MOVE.W	#0,-(A7)	; Appel FOPEN (ouverture du fichier)
	PEA	NOM(PC)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	ADDQ.L	#8,A7
	TST.L	D0	; Il est aux abonnés absents?
	BMI	END	; Pas de chargement
	MOVE.W	D0,D1	; Sauvegarde le handle

	PEA	$6F025	; Affiche le message du
	MOVE.W	#9,-(A7)	; chargement
	TRAP	#1
	ADDQ.L	#6,A7
	
	PEA	$70000	; Charge le fichier en $70000
	MOVE.L	#32034,-(A7)	; Seulement 32034 octets
	MOVE.W	D1,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	LEA	12(a7),A7
	MOVE.L	D0,D2
	
	MOVE.W	D1,-(A7)	; Fermeture du fichier
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7

	CMP.L	#32034,D2	; 32034 octets transférés?
	BNE.S	END	; Non, on abandonne

	MOVEM.L	ZERO(PC),D0-D7	; Mise en place de la
	MOVEM.L	D0-D7,$FFFF8240.W	; palette blanche
	
	MOVE.W	#37,-(A7)	; Vsync
	TRAP	#14
	ADDQ.L	#2,A7
	
	MOVE.W	#2,-(A7)	; Ecran physique
	TRAP	#14
	ADDQ.L	#2,A7
	
	MOVE.L	D0,A0	; Copie de l'image
	LEA	$70022,A1
	MOVE.W	#665,D0
SCHLOUM	MOVEM.L	(A1)+,D1-D7/A2-A6
	MOVEM.L	D1-D7/A2-A6,(A0)
	LEA	48(A0),A0
	DBF	D0,SCHLOUM
	MOVEM.L	(A1)+,D1-D7/A2
	MOVEM.L	D1-D7/A2,(A0)
	
	MOVEM.L	$70002,D0-D7	; Palette de l'image
	MOVEM.L	D0-D7,$FFFF8240.W

WAIT	MOVE.W	#-1,-(A7)	; Attend que [Control]
	MOVE.W	#$B,-(A7)	; soit relaché
	TRAP	#13
	ADDQ.L	#4,A7
	AND.W	#%100,D0
	BNE.S	WAIT
	RTS
	
END	PEA	$6F000	; Pas de chargement
	MOVE.W	#9,-(A7)
	TRAP	#1
	ADDQ.L	#6,A7
	RTS

NOM	DC.B	'A:\BOOT.PI1',0,0,0,0,0
ZERO	DC.W	$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF
	DC.W	$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF,$FFF
FIN_PROG:
	opt	p-
