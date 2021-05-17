***************************************************************************
*
*                           Ghost Killer v1.2
*                           -----------------
*
* Programme de nettoyage du Ghost, dédicacé à tous les Phans
* Par Rick ST, dernière modif le 05/07/93
*
* Mode d'emploi
* -------------
*
* o Installation
* --------------
*
*  L'installation et la détection de Ghost en mémoire se font automati-
*  quement au lancement du programme, que ce soit au boot ou non. Si
*  Ghost est en mémoire au moment de l'execution de GhostKiller, il sera
*  impitoyablement désactivé et désintégré. Si GhostKiller est déjà
*  installé, il s'autodétecte (protocole XBRA) et rend la main sans se
*  réinstaller une seconde fois.
*
* o Vecteurs utilisés
* -------------------
*
*  A chaque changement de disquette, le GEMDOS fait un appel à la fonction
*  GetBPB du BIOS, pour récupérer les paramètres du nouveau disk. C'est
*  en détournant le vecteur de cette fonction ($472) que Ghost se répand
*  sur vos disquettes... C'est aussi par ce vecteur que GhostKiller ira
*  vérifier chaque nouvelle disquette insérée dans l'un des deux lecteurs.
*  Pour ses tests clavier, GhostKiller utilise le premier vecteur libre
*  dans la queue VBL.
*  Le vecteur $472 est détourné en utilisant le protocole XBRA. L'identi-
*  ficateur utilisé est 'GKRS'.
*
* o Analyse de la disquette
* -------------------------
*
*  A chaque appel de GetBPB (fonction BIOS 7), GhostKiller rend compte de
*  son analyse par un ou plusieurs changement(s) de la couleur de fond:
*
*  Rien  => Boot exécutable mais ce n'est pas Ghost (ATTENTION, cela peut
*           etre un virus! GhostKiller ne limite sa recherche qu'à Ghost!)
*  Rouge => Ghost est présent sur la disquette, GhostKiller va faire une
*           tentative de vaccination
*  Bleu  => Erreur disque (si cette couleur apparait juste après le rouge,
*           enlever la protection disquette)
*  Vert  => Boot non exécutable
*
*  Si l'appel est effectué sur un lecteur différent de A ou B (disque dur,
*  cartouche, ramdisk, CD-Rom, etc.), GhostKiller n'effectuera aucune
*  opération.
*
* o Commandes clavier
* -------------------
*
*  L'analyse et le remplacement du boot secteur peuvent etre forcés en
*  utilisant les combinaisons de touches suivantes:
*
*  [Control]-[Shift droit]             => Test du boot sur lecteur courant
*  [Control]-[Alternate]-[Shift droit] => Vaccination sur lecteur courant
*
*  Dans le cas du test, une nouvelle couleur est utilisée:
*  Violet => Degas loader 1.4 présent sur la disquette
*
* o Vaccination
* -------------
*
*  Le boot utilisé est le "Degas boot loader 1.4". Ce boot effectue les
*  opérations suivantes:
*  - Test de la configuration 2,5Mo sur STe et modification des configura-
*     tions mémoire en conséquence (puis Reset et relancement du boot).
*  - Chargement d'une image BOOT.PI? si celle-ci est présente dans le
*     répertoire racine de la disquette sur laquelle le système a
*     booté. (Basse résolution = BOOT.PI1, Moyenne = BOOT.PI2,
*     Haute = BOOT.PI3)
*  Le chargement de l'image ne s'effectue que lors d'un reset à froid
*  ou lors de la première mise sous tension du ST. Il peut etre empeché
*  en appuyant sur [Alternate].
*  Une fois affichée, l'image peut etre gardée à l'écran en appuyant sur
*  [Control]; la procédure de boot continuera dès que cette touche sera
*  relachée.
*
* o Compatibilité
* ---------------
*
* A cause des changements de couleur, GhostKiller 1.0 n'est compatible
*  Falcon que dans les résolutions compatibles ST.
* Degas boot loader 1.4 fonctionne sur Falcon si celui-ci boote en mode
*  basse résolution ST.
*
* Lorsque le message de GhostKiller s'affiche, vous pouvez le lire en
* toute tranquillité en appuyant sur [Control]... Relachez-le quand
* vous aurez terminé!
*
*
*                                                  Bonne chasse... Rick.
*
***************************************************************************

	opt w+,o+

	SECTION TEXT

	move.l	a7,a5		Calcul mémoire pour Ptermres
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,Ptermres

	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	tst.w	d0
	bne.s	NoChgRez
	move.w	#1,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	pea	NewPal(pc)
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7

NoChgRez	pea	Install(pc)	Installation en superviseur
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7

Wait	move.w	#-1,-(a7)		Test de [Control]
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	and.b	#%1111,d0
	cmp.b	#%0100,d0
	beq.s	Wait

	move.w	#$19,-(a7)		DGETDRV
	trap	#1		Retourne lecteur actif dans d0
	addq.l	#2,a7
	cmp.b	#2,d0
	bge.s	End
	move.w	d0,-(a7)		Getbpb
	move.w	#7,-(a7)
	trap	#13
	addq.l	#4,sp

End	tst.w	Resident		Flag prg résident ou non
	bne.s	NonResident
	clr.w	-(a7)		Prg résident (Ptermres)
	move.l	Ptermres(pc),-(a7)
	move.w	#$31,-(a7)
	trap	#1

NonResident
	clr.w	-(a7)		Prg non résident (Pterm)
	trap	#1
	
Resident	dc.w	0


**************************************************

Install	
	LEA	MSG(PC),A0		Code les messages dans le
	LEA	CONT(PC),A1	 Degas boot loader
.CODE	NOT.B	(A0)+
	CMP.L	A1,A0
	BLT.S	.CODE
		
	lea	Present(pc),a0	Message de présentation
	bsr	Print

	lea	$140.w,a0		Adr de relocation de Ghost
	lea	Ghost(pc),a1	Adr de l'exemplaire de Ghost
	clr.w	d1		Compteur d'octets identiques
	move.w	#429,d0
.Detect	cmp.b	(a0)+,(a1)+
	bne.s	.NoGood
	addq.w	#1,d1
.NoGood	dbf	d0,.Detect
	cmp.w	#322,d1		Au moins 75% identiques?
	blt.s	.NoGhost		Non, Ghost n'est pas en mémoire

	lea	GhostOn(pc),a0	Message d'avertissement
	bsr	Print
	move.l	$2e2.w,$472.w	Restaure vecteur GetBPB
	move.l	#$31415926,$426.w	'magic' pour vecteur reset
	move.l	$190.w,$42a.w	Restaure vecteur reset
	tst.w	$42a.w		Teste vecteur reset
	bne.s	.OkReset
	clr.l	$426.w		Pas de vecteur reset!
.OkReset	lea	$140.w,a0		Efface Ghost de la mémoire
	move.w	#214,d0
.Clear	clr.w	(a0)+
	dbf	d0,.Clear	
	bsr	PlaySample
	
.NoGhost	move.l	$472.w,a0		Teste si GhostKiller est
	move.l	6(a0),d0		 dèjà installé (protocole
	cmp.l	#'GKRS',d0		 XBRA, identificateur GKRS)
	beq.s	.YetInstalled	Déjà installé, on sort
	
	move.l	$472.w,SysReturn	Sauve vecteur GetBPB
	move.l	$472.w,XBRA	Idem pour le XBRA
	move.l	#GetBPB,$472.w	Détourne le vecteur GetBPB

.End	lea	Active(pc),a0	'GhostKiller activé'
	bsr	Print
	rts

.YetInstalled
	lea	InActive(pc),a0	'GhostKiller déjà installé'
	bsr	Print
	not.w	Resident		Sort sans etre résident
	rts

NewPal	dc.w	$FFF,$F00,$0F0,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
Ptermres	dc.l	10000


************************************************************
*  Routine de détection et d'effacement de Ghost sur disk  *
*  S'installe sur le vecteur $472 (appel BIOS GetBPB)      *
************************************************************

GetBPB	bra.s	ContGet
	dc.b	'XBRA'
	dc.b	'GKRS'
XBRA	dc.l	0
ContGet	move.w	4(a7),d0		Device (0 = A, 1 = B, etc)
	cmp.w	#2,d0		Uniquement sur disquette!
	bge	.NoGhost
	movem.l	d1-a6,-(a7)	Sauve tous les registres

	move.w	d0,d7		Sauve numéro de lecteur
	move.w	#1,-(a7)	Count	Charge le nouveau boot secteur
	move.w	#0,-(a7)	Face
	move.w	#0,-(a7)	Piste
	move.w	#1,-(a7)	Secteur
	move.w	d7,-(a7)	Dev
	clr.l	-(a7)
	pea	Boot
	move.w	#8,-(a7)
	trap	#14
	lea	20(a7),a7
	tst.w	d0		Teste flag d'erreur
	bmi	.DiskError		Négatif => Erreur disque

	lea	Boot,a0		Adr de chargement du boot
	move.w	#255,d0		512 octets
	clr.w	d1
.Test	add.w	(a0)+,d1
	dbf	d0,.Test
	cmp.w	#$1234,d1		Checksum = $1234 ?
	bne	.NoGhost		Oui => Boot executable

.Executable
	tst.w	DegasTest
	beq.s	.GhostTest
	lea	Boot+30,a0		Saute paramètres disque
	lea	DEBUT_PROG(pc),a1	Exemplaire de Degas loader
	clr.w	d1		Compteur d'octets identiques
	move.l	#FIN_PROG,d0
	sub.l	a1,d0
.Detect	cmp.b	(a0)+,(a1)+
	bne.s	.NoGood
	addq.w	#1,d1
.NoGood	dbf	d0,.Detect
	cmp.w	#322,d1		Au moins 75% identiques?
	blt.s	.GhostTest		Non => Pas Degas loader!

	move.w	#$F0F,d4
	bsr	Flash		Violet! (Degas loader présent)
	bra	.NoGhost

.GhostTest	lea	Boot+30,a0		Saute paramètres disque
	lea	Ghost(pc),a1	Exemplaire de Ghost vivant
	clr.w	d1		Compteur d'octets identiques
	move.w	#429,d0
.GhDetect	cmp.b	(a0)+,(a1)+
	bne.s	.GhNoGood
	addq.w	#1,d1
.GhNoGood	dbf	d0,.GhDetect
	cmp.w	#322,d1		Au moins 75% identiques?
	blt.s	.NoGhost		Non => Ce n'est pas Ghost

	move.w	#$F00,d4
	bsr.s	Flash		Rouge! (Ghost présent)
	
	lea	DEBUT_PROG(pc),a0	Adr boot de remplacement
	lea	Boot+30,a1		Adr boot disque
	move.l	#FIN_PROG,d0	Adr fin du boot de remplacement
	sub.l	a0,d0
.Copy	move.b	(a0)+,(a1)+	Copie
	dbf	d0,.Copy

	move.w	#1,-(a7)		Boot executable
	move.w	#-1,-(a7)		Type disquette inchangé
	move.l	#-1,-(a7)		No série inchangé
	pea	Boot		Adr buffer
	move.w	#$12,-(a7)		Appel Protobt
	trap	#14
	lea	14(a7),a7

	move.w	#1,-(a7)	Count	Ecrit le nouveau boot sur
	move.w	#0,-(a7)	Face	 disque
	move.w	#0,-(a7)	Piste
	move.w	#1,-(a7)	Secteur
	move.w	d7,-(a7)	Dev
	clr.l	-(a7)
	pea	Boot
	move.w	#9,-(a7)
	trap	#14
	lea	20(a7),a7
	tst.w	d0		Teste Flag d'erreur
	bne.s	.DiskError		Nul => ok, on sort
	bsr	PlaySample
	bra.s	.NoGhost

.DiskError	move.w	#$F,d4
	bsr.s	Flash		Bleu! (Erreur disque)
	
.NoGhost	movem.l	(a7)+,d1-a6	Restaure tous les registres
	jmp	0.l		Rend la main au système
SysReturn	EQU	*-4

DegasTest	dc.w	0


********************************************

Flash	move.w	#$25,-(a7)		Vsync
	trap	#14
	addq.l	#2,a7
	move.w	$ffff8240.w,d5	Sauve ancienne couleur
	move.w	d4,$ffff8240.w	Flash!
	moveq	#9,d6		Attend 10 VBLs
.Red	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	dbf	d6,.Red
	move.w	d5,$ffff8240.w	Restaure l'ancienne couleur
	rts

Print	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

	include	A:\GHOSTKIL\DEGBOOT.S	Degas loader	

********************************************

PlaySample
	MOVE.W	#$2700,SR
	move.l	#Sample,d0
	move.l	#EndSample,d1
	sub.l	d0,d1
	AND.L	#$00FFFFFF,D0
	LEA	$FFFF8900.W,A0
	MOVEP.L	D0,$1(A0)
	ADD.L	D1,D0
	MOVEP.W	D0,$11(A0)
	SWAP	D0
	MOVE.B	D0,$F(A0)
	MOVE.B	#%10000001,$21(A0)
	MOVE.B	#%01,$1(A0)
	MOVE.W	#$2300,SR
	rts


	SECTION DATA
	
Ghost	incbin	A:\GHOSTKIL\GHOST
	even
Sample	incbin	A:\GHOSTKIL\GHOST.PCM
EndSample	
	even
Present	dc.b	27,'E',27,'p'
	dc.b	'  GhostKiller v1.2 (STE Only)                              ¢1993 by Rick ST from NGC  ',10,13,10,13,27,'q'
	dc.b	'  Press [Control] to read all the message...',10,13,10,13,10,13
	dc.b	'  Red    => Ghost found on boot sector',10,13
	dc.b	'  Purple => Degas boot loader 1.4 found on boot sector',10,13 
	dc.b	'  Blue   => Disk error',10,13,10,13
	dc.b	0
GhostOn	dc.b	'  Ghost was found and murdered in memory!',10,13,0
Active	dc.b	'  GhostKiller is now active.',10,13,10,13,0
InActive	dc.b	'  GhostKiller was already installed.',10,13,10,13,0
	even

	SECTION BSS

Boot	ds.b	512
