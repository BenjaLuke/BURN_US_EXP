	output "BURNUSexpcast.rom"
	
	
CLS			equ	#00C3	;CLS											;borra la pantalla
SCREEN0		equ	#006C	;INITXT											;pasa a modo screen 0
SCREEN1		equ	#006F	;INIT32											;pasa a modo screen 1 
MODOTEXTO	equ	#00D2	;TOTEXT											:fuerza a modo texto
LOCATE		equ	#00C6	;POSIT											;coloca el cursor en una rectrices h,l
CHPUT		equ	#00A2	;CHPUT											;escribe un caracter en pantalla
KEYOFF		equ	#00CC	;ERAFNK											;hace desaparecer las teclas de función
COLOR		equ	#0062	;CHGCLR											;da color a la pantalla
COLLETRA	equ	#F3E9	;FORCLR											;define el color de letras para CHGCLR
COLFONDO	equ	#F3EA	;BAKCLR											;define el color de fondo para CHGCLR
COLBORDE	equ	#F3EB	;BDRCLR											;defeine el color de bordes para CHGCLR
INPUT		equ	#009F	;CHGET											;espera que pulses una tecla y manda el valor a registro a
ANCHOSC0	equ	#F3AF	;LINL40											;define el width de screen 0
ANCHOSC1	equ	#f3AF	;LINL32											;define el width de screen 1
CLICKOFF	equ	#f3DB	;CLIKSW											;quita el sonido del toque de teclas
DISSCR		equ	#0041													;desconecta la pantalla_en_blanco
ENASCR		equ	#0044													;conecta la pantalla


RDVDP		equ	#013E													;lee registro 8 del VDP
WRTVDP		equ	#0047													;escribe registros del VDP
GRABAVRAM	equ	#005C	;LDIRVM											;graba en vram una parte de ram
GRABARAM	equ	#0059	;LDIRMV											;grava en ram una parte de vram

SCREENX		equ	#005F	;CHGMOD											;elige el modo grafico
ONSTICK		equ	#00D5	;GTSTCK											;controla el stick
ONSTRIG		equ	#00D8	;GTTRIG											;controla los botones del joystick o la barra espaciadora
RESET		equ #003B	;INITIO											;reinicia el ordenador

H.KEYI		equ	#FD9A	;H.KEYI
H.TIMI		equ	#FD9F	;H.TIMI

SNSMAT		equ	#0141	;INKEY$											;controla si se ha pulsado una tecla

ENASLT		equ	#0024													;para ampliar la rom
EXPTBL		equ	#FCC1
SLTTBL		equ	#FCC5		
RSLREG  	equ	#0138
SLOTVAR		equ	#C000

RG0SAV		equ	#F3DF													;COPIA DE vdp DEL REGISTRO 0 (BASIC:VDP(0))
RG1SAV		equ	#F3E0													;COPIA DE vdp DEL REGISTRO 1 (BASIC:VDP(1))
RG2SAV		equ	#F3E1													;COPIA DE vdp DEL REGISTRO 2 (BASIC:VDP(2))
RG3SAV		equ	#F3E2													;COPIA DE vdp DEL REGISTRO 3 (BASIC:VDP(3))
RG4SAV		equ	#F3E3													;COPIA DE vdp DEL REGISTRO 4 (BASIC:VDP(4))
RG5SAV		equ	#F3E4													;COPIA DE vdp DEL REGISTRO 5 (BASIC:VDP(5))
RG6SAV		equ	#F3E5													;COPIA DE vdp DEL REGISTRO 6 (BASIC:VDP(6))
RG7SAV		equ	#F3E6													;COPIA DE vdp DEL REGISTRO 7 (BASIC:VDP(7))
RG9SAV		equ	#FfE8													;COPIA DE vdp DEL REGISTRO 9 (BASIC:VDP(9)) para control de los MSX2

STATFL		equ	#F3E7													;COPIA DE vdp DEL REGISTRO 8 (EL QUE ES DE ESCRITURA (S#0))
CLRSPR		equ	#0069													;inicializa todos los sprites

;PÀGINA 0		(#0000 - #3FFF)

	org		#0000

instru_caste:		incbin	"INSTRUCCIONES.DAT"							;las instrucciones en catellano
instru_ingle:		incbin	"INSTRUCTIONS.DAT"							;las instrucciones en inglés

CANCION:			incbin	"MUSICMENUPLETTER.99"						;incluye la cancion de apertura desde el modo binario
SILENCIO:			incbin	"MUTEPLETTER.99"							;para crear un mute a la música
MUSICA_GAMEOVER:	incbin	"GAMEOVERPLETTER.99"						;música de game over
MUSICA_FASES:		incbin	"FASESPLETTER.99"							;música de fases
MUSICA_MUERTO:		incbin	"MUERTOPLETTER.99"							;musica de muere
MUSICA_ENTRE_FASES:	incbin	"ENTRE_FASESPLETTER.99"						;musica de entre fases

pant_carga_til:	incbin	"PANTALLA_DE_CARGA_TILES.til"					;tiles de pantalla de carga
pant_carga_col:	incbin	"PANTALLA_DE_CARGA_TILES.col"					;colores de pantalla de carga
pant_carga:		incbin	"PANTALLA_DE_CARGA.DAT"							;pantalla de carga

tiles_1:		incbin	"TILESFpletter.til"								;tiles de juego 1
colores_1:		incbin	"TILESFpletter.col"								;colores de juego 1


fase_1:			incbin	"FASE_1_pletter.dat"							;pantalla fase 1
fase_2:			incbin	"FASE_2_pletter.dat"
fase_3:			incbin	"FASE_3_pletter.dat"
	
relleno_page_0_:	
		ds      04000h-$,0000h       									;Rellena hasta completar los 16KB de la pagina 0

;PÁGINAS 1 Y 2	(#4000 - #BFFF)

	org		#4000	

	db	"AB"															;Cabecera de fichero ROM
	word	START														;Dónde empieza la ejecución
	word	0,0,0,0,0,0
		
	
	
START:

; pasamos a 50 herzios si es un msx2 o superior

		ld		a,[#002D]												;si se trata de un msx1 no tocamos la vdp registro 9
		or		a
		jr.		z,ampliamos_lectura_a_32kb
		
		ld		a,7
		call	SNSMAT
		bit		7,a
		jr.		z,ampliamos_lectura_a_32kb

		ld		a,(RG9SAV)
		or		00000010b												;a 50 hz
		ld		b,a
		ld		c,9
		call	WRTVDP													;lo escribe en el registro 9 del VDP

ampliamos_lectura_a_32kb:

; ampliamos la lectura de rom a 32 k

		di
		
		im		1														;modo de interrupciones 1
		ld		a,#C9													;a tiene el valor de ret
		ld		(#FD9F),A												;colocamos ese ret en el gancho H.Timi POR SI EL ORDENADOR TUVIERA ALGO (ALGUN MSX 2 CONTROL DE DISQUETERA)
		ld		(#FD9A),A												;colocamos ese ret en el gancho H.Key POR SI EL ORDENADOR TUVIERA ALGO
 		ld		sp,#F380												; colocmos la pila en esta posicion, que suele ser donde empieza las zona ram que usa el S.O. del MSX. Recuerda que la pila crece hacia abajo así que no pisaremos nada

; borramos la vram entera

        ld  hl,inicio_ram
        ld  de,inicio_ram + 1
        ld  bc,#F380 - inicio_ram
        ld  (hl),0
        ldir
        
		call	search_slotset
		
		ei

;descomprimimos la musica

		di																;desconectamos las interrupciones
		call	setrompage0												;con la pagina 0 de la rom pisamos la bios
				
		ld		hl,MUSICA_GAMEOVER										;descomprime musica game over
		ld		de,GAME_OVER
		call	depack
		
		ld		hl,SILENCIO												;descomprime musica mute
		ld		de,MUTE
		call	depack
		
		ld		hl,MUSICA_MUERTO										;descomprime musica mute
		ld		de,MUERTO
		call	depack
		
		ld		hl,MUSICA_ENTRE_FASES									;descomprime musica entre fases
		ld		de,ENTRE_FASES
		call	depack
		
		ld		hl,EFECTOS_BAN_P
		LD		DE,EFECTOS_BANCO
		
		CALL	depack
		
		call	recbios
											
;inicializamos la música
		        						
		ld		hl,EFECTOS_BANCO										;hl ahora vale la direccion donde se encuentran los efectos
		call	ayFX_SETUP												;inicia el reproductor de efectos
		
;engancha nuestra rutina de servicio al gancho que djea preparada la BIOS cuando se termina de pintar la pantalla (50 o 60 veces por segundo)

		ld		a,#C3													;#c3 es el código binario de jump (jp)
		ld		[H.TIMI],a												;metemos en H.TIMI ese jp
		ld		hl,nuestra_isr											;cargamos nuestra secuencia en hl
		ld		[H.TIMI+1],hl											;la ponemos a continuación del jp
		
		ei																;conectamos las interrupciones
		
		call	musica_con_bucle
		
		jr.		PANTALLA_DE_CARGA

;original from Ramones (http://karoshi.auic.es/index.php?topic=628.0)
; -----------------------
; SEARCH_SLOTSET
; Posiciona en pagina 2
; Nuestro ROM.
; -----------------------

search_slotset:
		call search_slot
		jp ENASLT


; -----------------------
; SEARCH_SLOT
; Busca slot de nuestro rom
; -----------------------

search_slot:

	call RSLREG
	rrca
	rrca
	and 3
	ld c,a
	ld b,0
	ld hl,0FCC1h
	add hl,bc
	ld a,(hl)
	and 080h
	or c
	ld c,a
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	and 0Ch
	or c
	ld h,080h
	ld (SLOTVAR),a
	ret	
	
PANTALLA_DE_CARGA:
		
		call	PREPARACION_SCREEN_2
		call	DISSCR													;desconectamos la pantalla
		call	limpia_sprites
		call	colores_inicio
		jr.		cargando_patrones
		
colores_inicio:
		
		ld		a,7
		ld		[COLLETRA],a											;aunque sólo quieras cambiar uno de los colores, tienes que volver a definir los otros dos para que te acepte un cambio
		xor		a
		ld		[COLFONDO],a
		ld		[COLBORDE],a
		jr.		COLOR

cargando_patrones:

		di
		call	setrompage0
		
		ld		hl,pant_carga_til										;cargamos patrones
		ld		de,#0000
		call	depack_VRAM
		
		ld		hl,pant_carga											;carga el marcador
		ld		de,#1800
		call	depack_VRAM
		
		ld		hl,pant_carga_col										;cargamos colores de patrones
		ld		de,#2000
		call	depack_VRAM
		
		call	recbios
		ei
		
			
		call	SPRITES_PETISOS
		
		call	ENASCR													;conectamos la pantalla
		
		call	activa_musica_menu

INICIA_MUSICA:

		call	activa_musica_menu										;inicia el reproductor de PT3
		
		ld		a,1
		ld		(direccion_exp),a
		ld		a,15
		ld		(petisoy),a
		ld		a,110
		ld		(petisox),a
		ld		a,40
		ld		(espera_petiso),a
		ld		(espera_petiso_resta_2),a
		ld		(espera_petiso_resta),a
petisos:
		
		xor		a
		CALL	ONSTRIG
		or		a
		jr.		nz,MENU
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		nz,MENU
		
		call	petiso_activity
		
		jr.		petisos
		
		jr.		MENU

petiso_activity:

		ld		a,(espera_petiso_resta)
		dec		a
		or		a
		ld		(espera_petiso_resta),a
		ret		nz
		ld		a,(espera_petiso)
		ld		(espera_petiso_resta),a
		ld		a,(espera_petiso_resta_2)
		dec		a
		or		a
		ld		(espera_petiso_resta_2),a
		ret		nz
		ld		a,(espera_petiso)
		ld		(espera_petiso_resta),a
		ld		(espera_petiso_resta_2),a
		
		ld		hl,(espera_petiso)
		ld		(espera_petiso_resta),hl

		ld		a,(petiso_que_toca)
		or		a
		jr.		z,petiso_a_saltar
		
		xor		a
		ld		(petiso_que_toca),a
		ld		a,(petisoy)
		add		3
		ld		(petisoy),a
		jr.		registros_petiso
		
petiso_a_saltar:
		
		ld		a,16
		ld		(petiso_que_toca),a
		ld		a,(petisoy)
		sub		3
		ld		(petisoy),a
		jr.		registros_petiso

registros_petiso:

		halt
		ld		ix,atributos_sprite_general
		ld		a,(petisoy)
		call	CERO_CUATRO_OCHO
		ld		(ix+12),a
		ld		a,(petisox)
		call	UNO_CINCO_NUEVE
		ld		(ix+13),a
		ld		a,(petiso_que_toca)
		call	DOS_SEIS_DIEZ
		add		4
		ld		(ix+14),a
		ld		a,1
		ld		(ix+3),a
		ld		a,4
		ld		(ix+7),a
		ld		a,10
		ld		(ix+11),a
		ld		a,15
		ld		(ix+15),a
		
		jr.		atributos_sprites

exp_activity:

		ld		a,(retardo_exp)
		inc		a
		ld		(retardo_exp),a
		cp		20
		ret		nz
		xor		a
		ld		(retardo_exp),a
		
		ld		a,(direccion_exp)
		or		a
		jr.		z,exp_resta_posicion
		
exp_suma_posicion:

		ld		a,(valor_suma_resta_exp)
		ld		b,a
		ld		a,(y_exp)
		add		b
		ld		(y_exp),a
		ld		a,(valor_suma_resta_exp)
		inc		a
		ld		(valor_suma_resta_exp),a
		cp		4
		jr.		c,exp_sprites
		
		xor		a
		ld		(direccion_exp),a
		jr.		exp_sprites

exp_resta_posicion:

		ld		a,(valor_suma_resta_exp)
		ld		b,a
		ld		a,(y_exp)
		sub		b
		ld		(y_exp),a
		ld		a,(valor_suma_resta_exp)
		dec		a
		ld		(valor_suma_resta_exp),a
		or		a
		jr.		nz,exp_sprites
		
		ld		a,1
		ld		(direccion_exp),a
		
		ld		a,(y_exp)
		cp		70
		jr.		nc,exp_sprites
		
		ld		a,70
		ld		(y_exp),a
		
exp_sprites:		
		
		ld		a,(cuenta_gira_exp)
		cp		20
		jr.		nc,exp_sprites_diferente

exp_sprite_1:
		
		ld		a,8*4
		jr.		registros_exp		

exp_sprites_diferente:

		cp		20
		jr.		z,exp_sprite_2
		cp		26
		jr.		z,exp_sprite_2
		cp		21
		jr.		z,exp_sprite_3
		cp		25
		jr.		z,exp_sprite_3
		cp		22
		jr.		z,exp_sprite_4
		cp		24
		jr.		z,exp_sprite_4
		cp		23
		jr.		z,exp_sprite_5

exp_sprite_2:
		
		ld		a,11*4
		jr.		registros_exp

exp_sprite_3:
		
		ld		a,14*4
		jr.		registros_exp

exp_sprite_4:
		
		ld		a,17*4
		jr.		registros_exp

exp_sprite_5:
		
		ld		a,20*4
		jr.		registros_exp		
		
registros_exp:

		ld		(ix+18),a
		add		4
		ld		(ix+22),a
		add		4
		ld		(ix+26),a
		ld		a,(y_exp)
		ld		(ix+16),a
		ld		(ix+20),a
		ld		(ix+24),a
		ld		a,120
		ld		(ix+17),a
		ld		(ix+21),a
		ld		(ix+25),a
		ld		a,1
		ld		(ix+19),a
		ld		a,10
		ld		(ix+23),a
		ld		a,15
		ld		(ix+27),a
		
		ld		a,(cuenta_gira_exp)
		inc		a
		ld		(cuenta_gira_exp),a
		cp		27
		jr.		nz,atributos_sprites
		xor		a
		ld		(cuenta_gira_exp),a
		jr.		atributos_sprites
		
MENU:		

		;prepara la pantalla
		
		call	colores_inicio
		call	limpia_sprites
		call	PREPARACION_SCREEN_2
		
		xor		a														;XOR se lo carga todo poniendolo a 0, es como un ld a,0 pero ocupa menos
		call	CLS
		
		ld		a,32													;pone el width a 32
		ld		[ANCHOSC1],a
		xor		a
		ld		[CLICKOFF],a											;quita el click de las teclas
		call	SCREEN1													;pasa a modo screen 1
	
		call	KEYOFF													;borramos las teclas de función
		call	SPRITES_PETISOS											;carga sprites petisos y exp

PREPARA_VARIABLES_SERPIENTE:

		ld		a,16
		ld		(y_serp),a
		ld		bc,3000
		ld		(clock),bc
		
		ld		a,174
		ld		(petisoy),a
		ld		a,30
		ld		(petisox),a
		ld		a,7
		ld		(espera_petiso),a
		ld		(espera_petiso_resta_2),a
		ld		(espera_petiso_resta),a
		xor		a
		ld		(valor_suma_resta_exp),a
		ld		(cuenta_gira_exp),a
		ld		(retardo_exp),a
		ld		(fuego_cambia),a
		ld		a,1
		ld		(direccion_exp),a
		ld		a,70
		ld		(y_exp),a
				
RUTINA_DE_MENU:

		ld		hl,letras_A												;redefine las letras
		ld		de,#0208
		ld		bc,8*26
		call	GRABAVRAM
		
		ld		hl,titulo_centro1										;redefine tiles de título
		ld		de,#0308
		ld		bc,8*24
		call	GRABAVRAM
		
		ld		hl,parentesis_a											;redefine parentesis
		ld		de,#0140
		ld		bc,8*2
		call	GRABAVRAM
		
		ld		hl,guion												;redefine guion y punto
		ld		de,#0158
		ld		bc,8*2
		call	GRABAVRAM
		
		ld		hl,numero0												;redefine numeros y dos puntos
		ld		de,#0180	
		ld		bc,8*11
		call	GRABAVRAM
								
PANTALLA_DE_SELECCION:
		
		xor		a
		call	CLS
				
		ld		h,1
		ld		l,4
		call	LOCATE
		ld		hl,titulo_1
		call	lee_pinta_una
						
		ld		h,2
		ld		l,24
		call	LOCATE
		ld		hl,copyright
		call	lee_pinta_una
		
		ld		a,(idioma)
		or		a
		jr.		z,menu_castellano

menu_ingles:

		ld		h,3														;escribe pantalla de menu
		ld		l,1
		call	LOCATE
		ld		hl,empresa
		call	lee_pinta_una
			
		ld		h,12
		ld		l,16
		call	LOCATE
		ld		hl,teclado
		call	lee_pinta_una	
		
		ld		h,12
		ld		l,18
		call	LOCATE
		ld		hl,mando
		call	lee_pinta_una
		
		ld		h,15
		ld		l,13
		call	LOCATE
		ld		hl,mensaje_ING
		call	lee_pinta_una
				
		ld		h,12
		ld		l,20
		call	LOCATE
		ld		hl,instrucciones
		call	lee_pinta_una
		
		ld		h,12
		ld		l,22
		call	LOCATE
		ld		hl,salir
		call	lee_pinta_una
		
		jr.		rutina_colores_inicio
		
menu_castellano:

		ld		h,3														;escribe pantalla de menu
		ld		l,1
		call	LOCATE
		ld		hl,empresa_e
		call	lee_pinta_una
		
		ld		h,15
		ld		l,13
		call	LOCATE
		ld		hl,mensaje
		call	lee_pinta_una
		
		ld		h,12
		ld		l,16
		call	LOCATE
		ld		hl,teclado_e
		call	lee_pinta_una	
		
		ld		h,12
		ld		l,18
		call	LOCATE
		ld		hl,mando_e
		call	lee_pinta_una
				
		ld		h,12
		ld		l,20
		call	LOCATE
		ld		hl,instruccion_e
		call	lee_pinta_una
		
		ld		h,12
		ld		l,22
		call	LOCATE
		ld		hl,salir_e
		call	lee_pinta_una		
				
rutina_colores_inicio:													;rutina de colores
		
		ld		hl,col_letras_10
		call	rutina_colores_pinto
		ld		hl,col_letras_9
		call	rutina_colores_pinto
		
								
		jr.		anima_fuego
		
rutina_colores_pinto:
																		;redefine los colores de las letras
		ld		de,#200c
		ld		bc,4
		call	GRABAVRAM
		
reinicia_fuego:

		ld		hl,65000
		ld		(fuego_cambia),hl
		ret

cambia_variable_fuego:

		ld		a,(fuego_cambiante)
		or		a
		jr.		z,cambia_variable_fuego_2
		xor		a
		ld		(fuego_cambiante),a
		
		ret
		
cambia_variable_fuego_2:

		ld		a,1
		ld		(fuego_cambiante),a
		
		ret
				
anima_fuego:

		ld		hl,(fuego_cambia)
		or		a
		call	z,cambia_variable_fuego
		ld		hl,(fuego_cambiante)
		or		a
		call	z,reinicia_fuego
						
		ld		a,(fuego_cambiante)
		or		a
		jr.		z,anima_fuego_2
		
		ld		hl,fueguito_1	
		ld		de,#0340
		ld		bc,8*2
		call	GRABAVRAM
		
		ld		hl,fuego_quema	
		ld		de,#03c0
		ld		bc,8*3
		call	GRABAVRAM
		
		ld		hl,flame_1	
		ld		de,#0370
		call	standard_tiles_cambiantes
				
		jr.		contro_serpiente_a_pintar
		
anima_fuego_2:

		ld		hl,1
		ld		(fuego_cambia),hl
		
		ld		hl,fueguito_2	
		ld		de,#0340
		call	standard_tiles_cambiantes
		
		ld		hl,fueguito_1											;redefine tiles de fuego
		ld		de,#0348
		call	standard_tiles_cambiantes
		
		ld		hl,fuego_quema_2
		ld		de,#03c0
		ld		bc,8*3
		call	GRABAVRAM
		
		ld		hl,flame_2
		ld		de,#0370
		ld		bc,8*1
		call	GRABAVRAM
		
contro_serpiente_a_pintar:
		
		ld		hl,(fuego_cambia)
		dec		hl
		ld		(fuego_cambia),hl
		
		call	petiso_activity
		
		ld		hl,col_letras_8
		call	rutina_colores_pinto
		
		call	exp_activity											;llama al exp en movimiento
		
		ld		hl,col_letras_7
		call	rutina_colores_pinto
		
		jr.		pinta_serpiente_1
				
control_stick_menu:
		
		ld		hl,col_letras_5
		call	rutina_colores_pinto
		
		xor		a
		call	ONSTICK
		or		a
		jp		nz,mas_control
		ld		a,1
		call	ONSTICK
		or		a
		jp		nz,mas_control
		jp		limpiamos_la_ultima_opcion

mas_control:
		
		ld		a,(sigue_pulsando)
		or		a
		jp		nz,control_strig_menu
		
		xor		a														;controla el movimiento de la serpiente en menu
		call	control_stick_menu_para_dos_sticks
		
		ld		a,1
		call	control_stick_menu_para_dos_sticks
		
		jr.		control_strig_menu

control_stick_menu_para_dos_sticks:
		
		call	ONSTICK
		cp		1
		jr.		z,sube_cursor
		cp		5
		jr.		z,baja_cursor
		
		ret

limpiamos_la_ultima_opcion:

		xor		a
		ld		(sigue_pulsando),a
				
control_strig_menu:														;controla si pulsa espacio para seleccionar una opcion
		
		ld		hl,col_letras_12
		call	rutina_colores_pinto
		
		xor		a
		CALL	ONSTRIG
		or		a
		jr.		nz,que_ha_elegido
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		nz,que_ha_elegido
				
controla_tiempo_para_cambio:											;contador para ir a mostrar los creditos
		
;		ld		hl,(clock)
;		ld		bc,1		
;		sbc		hl,bc
;		ld		(clock),hl
;		jr.		nz,rutina_colores_inicio			
;		ld		bc,30000
;		ld		(clock),bc
		jr.		rutina_colores_inicio									;quitamos creditos para ahorrar memoria								

;CREDITOS:
		
;		call	limpia_sprites
						
;		xor		a
;		call	CLS
				
;		ld		h,18
;		ld		l,1
;		call	LOCATE
;		ld		hl,benja
;		call	lee_pinta_una
				
;		ld		h,21
;		ld		l,9
;		call	LOCATE
;		ld		hl,john
;		call	lee_pinta_una
					
;		ld		h,17
;		ld		l,13
;		call	LOCATE
;		ld		hl,salguero
;		call	lee_pinta_una
				
;		ld		h,21
;		ld		l,17
;		call	LOCATE
;		ld		hl,jorge
;		call	lee_pinta_una
		
;		ld		h,2
;		ld		l,24
;		call	LOCATE
;		ld		hl,mis_chicos
;		call	lee_pinta_una
				
;		ld		h,14
;		ld		l,5
;		call	LOCATE
;		ld		hl,tromax
;		call	lee_pinta_una
		
;		call	SPRITES_ONIRIC
		
;		ld		a,140
;		ld		ix,atributos_sprite_general
;		ld		(ix),a
;		ld		(ix+8),a
;		add		16
;		ld		(ix+4),a
;		ld		(ix+12),a
;		ld		a,90
;		ld		(ix+1),a
;		ld		(ix+5),a
;		add		16
;		ld		(ix+9),a
;		ld		(ix+13),a
;		ld		a,15
;		ld		(ix+3),a
;		ld		(ix+7),a
;		ld		(ix+11),a
;		ld		(ix+15),a
;		xor		a
;		ld		(ix+2),a
;		add		4
;		ld		(ix+10),a
;		add		4
;		ld		(ix+6),a
;		add		4
;		ld		(ix+14),a
		
;		call	atributos_sprites
		
;		ld		a,(idioma)
;		cp		0
;		jr.		z,creditos_castellano
		
	
;creditos_ingles:

;		ld		h,1
;		ld		l,5
;		call	LOCATE
;		ld		hl,mano_derecha_e
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,1
;		call	LOCATE
;		ld		hl,programacion
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,9
;		call	LOCATE
;		ld		hl,musica
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,13
;		call	LOCATE
;		ld		hl,ilustrations
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,17
;		call	LOCATE
;		ld		hl,graficos
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,20
;		call	LOCATE
;		ld		hl,thanks
;		call	lee_pinta_una
		
;		jr.		controla_tiempo_para_cambio_2
		
;creditos_castellano:
		
;		ld		h,1
;		ld		l,5
;		call	LOCATE
;		ld		hl,mano_derecha
;		call	lee_pinta_una
;		
;		ld		h,1
;		ld		l,1
;		call	LOCATE
;		ld		hl,programacion_e
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,9
;		call	LOCATE
;		ld		hl,musica_e
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,13
;		call	LOCATE
;		ld		hl,ilustraciones
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,17
;		call	LOCATE
;		ld		hl,graficos_e
;		call	lee_pinta_una
		
;		ld		h,1
;		ld		l,20
;		call	LOCATE
;		ld		hl,agradecido
;		call	lee_pinta_una
		
;controla_tiempo_para_cambio_2:

;		xor		a
;		CALL	ONSTRIG
;		cp		0
;		jr.		nz,prepara_contador_para_menu
		
;		ld		a,1
;		CALL	ONSTRIG
;		cp		0
;		jr.		nz,prepara_contador_para_menu
		
;		ld		hl,(clock)	
;		ld		bc,1				
;		sbc		hl,bc
;		ld		(clock),hl
		
;		jr.		nz,controla_tiempo_para_cambio_2
			
;prepara_contador_para_menu:

;		ld		bc,60000
;		ld		(clock),bc

;		jr.		MENU
				
que_ha_elegido:

		ld		a,1														;efecto de pinchar opción
		call	efecto_sonido
		
		ld		a,(y_serp)
		cp		16
		jp		z,prepara_nivel_1
		cp		18
		jp		z,prepara_nivel_2
		cp		20
		jp		z,idioma_a_pintar
		cp		22
		jp		z,PANTALLA_DE_CARGA

idioma_a_pintar:
		
		ld		a,(idioma)
		or		a
		jr.		nz,ingles

castellano

		ld		a,1
		ld		(idioma),a
		
		jr.		MENU
		
ingles:
	
		xor		a
		ld		(idioma),a
		
		JR.		MENU
					
prepara_nivel_1:

		xor		a
		ld		(nivel),a
		call	prepara_juego

prepara_nivel_2:

		ld		a,1
		ld		(nivel),a
		call	prepara_juego
		
lee_pinta_una:															;imprime el texto fijo
		ld		a,[hl]
		ld		b,a
		
loop_lee_pinta_una:
		inc		hl
		ld		a,[hl]
		call	CHPUT
		djnz	loop_lee_pinta_una
		ret
				
pinta_serpiente_1:
		
		ld		bc,[y_serp]
		ld		h,10
		ld		l,c
		call	LOCATE
		ld		hl,serp_1
		call	lee_pinta_una
		ld		[y_serp],bc
		jp		control_stick_menu
	
sube_cursor:															;comprueva si lo puede subir
 		
		ld		a,1
		ld		(sigue_pulsando),a
		
 		ld		a,(y_serp)
 		cp		16
 		jp		nz,lo_sube
 		
 		ret

lo_sube:																;lo sube porque es posible

		xor		a														;efecto de movimiento
		call	efecto_sonido
		
		ld		a,(y_serp)
		ld		h,10
		ld		l,a
		call	LOCATE
		ld		hl,nada
		call	lee_pinta_una
		
		ld		a,(y_serp)
		sub		2														;decrementa a 2 veces
		ld		(y_serp),a
		
		ret

baja_cursor:															;comprueva si lo puede bajar

		ld		a,5
		ld		(sigue_pulsando),a
			
		ld		a,(y_serp)
 		cp		22
 		jp		nz,lo_baja
 		
 		ret

lo_baja:																;lo baja porque es posbile

		xor		a														;efecto de movimiento
		call	efecto_sonido
		
		ld		a,(y_serp)
		ld		h,10
		ld		l,a
		call	LOCATE
		ld		hl,nada
		call	lee_pinta_una
				
		ld		a,(y_serp)
		add		2														;incrementa a 2 veces
		ld		(y_serp),a
		
		ret
		
limpia_sprites:

		ld		ix,atributos_sprite_general
		ld		a,209
		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		ld		(ix+12),a
		ld		(ix+16),a
		ld		(ix+20),a
		ld		(ix+24),a
		ld		(ix+28),a
		ld		(ix+32),a
		ld		(ix+36),a
		ld		(ix+40),a
		ld		(ix+44),a
		halt
		jr.		atributos_sprites
				
prepara_juego:
		
		call	limpia_sprites
		
		call	activa_mute												
		
		call	PREPARACION_SCREEN_2

		
		call	SPRITES_UNO
		
		call	DISSCR													;desconectamos la pantalla
		
		call	limpia_sprites
		
		di
		call	setrompage0
		
		ld		hl,tiles_1												;cargamos patrones
		ld		de,#0000
		call	depack_VRAM
		
		ld		hl,colores_1											;cargamos colores de patrones
		ld		de,#2000
		call	depack_VRAM
		
		xor		a
		ld		(py),a
		ld		a,(idioma)
		or		a
		jr.		z,instrucciones_en_castellano

instrucciones_en_ingles:		
																			
		ld		hl,instru_ingle											;instrucciones en ingles
		ld		de,#1800
		call	depack_VRAM
				
		jr.		animaciones_de_instrucciones
		
instrucciones_en_castellano:

		ld		hl,instru_caste											;instrucciones en castellano
		ld		de,#1800
		call	depack_VRAM
		
animaciones_de_instrucciones:
		
		call	recbios													;recuperamos la bios
		ei
		call	ENASCR
		
		ld		ix,atributos_sprite_general
		call	SPRITES_BOMBA
		
animaciones_de_instrucciones_1:
		
		ld		a,152													;camina hacia la derecha lento con o sin bomba
		ld		(ix),a
		sub		7
		ld		(ix+8),a
		add		16
		ld		(ix+4),a
		
		ld		a,(py)
		add		5
		ld		(py),a
		call	UNO_CINCO_NUEVE
		
		xor		a
		call	DOS_SEIS_DIEZ
		
		ld		a,1
		ld		(ix+3),a
		ld		a,3
		ld		(ix+7),a
		ld		a,9
		ld		(ix+11),a
		
		ld		a,17													;efecto sonoro de paso lento
		call	efecto_sonido
		
		call	atributos_sprites

		ld		a,5
		ld		(clock),a
		
		call	espera_de_animaciones
		
		ld		a,(py)
		add		5
		ld		(py),a
		call	UNO_CINCO_NUEVE
		
		ld		a,3*4
		call	DOS_SEIS_DIEZ
		
		call	atributos_sprites

		ld		a,5
		ld		(clock),a
				
		call	espera_de_animaciones
		
		xor		a
		CALL	ONSTRIG
		or		a
		jr.		nz,vamos_alla
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		nz,vamos_alla
				
		ld		a,(py)
		cp		120
		jr.		z,animaciones_de_instrucciones_2
		jr.		c,animaciones_de_instrucciones_1
		cp		250
		jr.		z,animaciones_de_instrucciones_3
		jr.		c,animaciones_de_instrucciones_1


animaciones_de_instrucciones_2:									
		
		call	SPRITES_UNO
		
		ld		a,3														;efecto sonoro de bomba
		call	efecto_sonido
		
		ld		a,160													; lanza la bomba
		ld		(ix+12),a
		ld		a,135
		ld		(ix+13),a
		ld		a,21*4
		ld		(ix+14),a
		ld		a,15
		ld		(ix+15),a
		
		call	atributos_sprites
		
		ld		a,10
		ld		(clock),a
		
		call	espera_de_animaciones
		
		ld		a,22*4
		ld		(ix+14),a
		
		call	atributos_sprites
		
		ld		a,10
		ld		(clock),a
		
		call	espera_de_animaciones
		
		ld		a,23*4
		ld		(ix+14),a
		
		call	atributos_sprites
		
		ld		a,10
		ld		(clock),a
		
		call	espera_de_animaciones
		
		ld		a,24*4
		ld		(ix+14),a
		
		call	atributos_sprites
		
		ld		a,30
		ld		(clock),a
		
		call	espera_de_animaciones
		
		jr.		animaciones_de_instrucciones_1
		
animaciones_de_instrucciones_3:

		ld		a,(py)													;camina hacia la izquierda rápido
		sub		5
		ld		(py),a
		call	UNO_CINCO_NUEVE
		
		ld		a,6*4
		call	DOS_SEIS_DIEZ
		
		ld		a,18													;efecto sonoro de paso rápido
		call	efecto_sonido
		
		call	atributos_sprites

		ld		a,4
		ld		(clock),a
		
		call	espera_de_animaciones
		
		xor		a
		CALL	ONSTRIG
		or		a
		jr.		nz,vamos_alla
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		nz,vamos_alla
		
		ld		a,(py)
		cp		200
		jr.		nc,animaciones_de_instrucciones_4
		
		add		50
		ld		(ix+13),a
		ld		(ix+17),a
		ld		a,152
		ld		(ix+12),a
		ld		(ix+16),a
		ld		a,25*4
		ld		(ix+14),a
		ld		a,29*4
		ld		(ix+18),a
		ld		a,11
		ld		(ix+15),a
		ld		a,1
		ld		(ix+19),a
		
animaciones_de_instrucciones_4:		
		
		ld		a,(py)
		sub		5
		ld		(py),a
		call	UNO_CINCO_NUEVE
		
		ld		a,9*4
		call	DOS_SEIS_DIEZ
		
		call	atributos_sprites

		ld		a,4
		ld		(clock),a
		
		call	espera_de_animaciones
		
		ld		a,(py)
		cp		200
		jr.		nc,animaciones_de_instrucciones_5
		
		add		50
		ld		(ix+13),a
		ld		(ix+17),a
		ld		a,26*4
		ld		(ix+14),a
		ld		a,30*4
		ld		(ix+18),a

animaciones_de_instrucciones_5:
				
		ld		a,(py)
		or		a
		jr.		nz,animaciones_de_instrucciones_3
		
		call	SPRITES_CUCHILLO
		
		call	limpia_sprites
		call	esperando

vamos_alla:

		call	datos_a_preparar
		jr.		bloque_sanctuary_1
		
esperando:
		
		call	ENASCR													;conectamos la pantalla
		xor		a
		CALL	ONSTRIG
		or		a
		ret		nz
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		z,esperando
		
		ret
		
datos_a_preparar:
		
		call	limpia_sprites
		call	SPRITES_UNO
		
		call	DISSCR		
		
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		di
		call	depack_VRAM
		ei
		ld		hl,marcador												;carga el marcador
		ld		de,#1800
		di
		call	depack_VRAM
		ei
		CALL	ENASCR
		
		ld		a,192
		ld		(posicion_del_punto_centenas),a
		ld		(posicion_del_punto_decenas),a
		ld		(posicion_del_punto_millares),a
		ld		(posicion_del_punto_unidades),a
		
		ld		a,6
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(ESTADO_MUSICA),a
		
		xor		a
		ld		(contador_para_puntuacion),a
		ld		(cuanto_sumamos_a_score),a
		ld		(score),a
		ld		(OUS_ACTIU),a
		ld		(trampa),a
		ld		(inmune_serp),a
		ld		(inmune_bomb),a

		ret
		
define_espera_entre_fases:

		ld		hl,240
		ld		(clock),hl	
		ret

coordenadas_prota:

		ld		(py),a
		ld		(py_salida),a
		ld		a,b
		ld		(px),a
		ld		(px_salida),a
				
		ret
		
bloque_sanctuary_1:
				
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 1
		or		a
		jr.		z,bloque_sanctuary_1_esp
		ld		hl,sanctuary_x
		jr.		bloque_sanctuary_1_cont

bloque_sanctuary_1_esp:

		ld		hl,santuario_x

bloque_sanctuary_1_cont:
		
		
		call	anunciamos_el_santuario_correspondiente
		ld		hl,sanctuary_1
		call	anunciamos_el_santuario_correspondiente_numero
		;		coordenadas prota
		ld		a,120													;define variables
		ld		b,a
		ld		a,24						
		call	coordenadas_prota
		
		call	variables_iguales
				
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,72
		ld		(iy),a
		ld		a,168
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		a,11
		ld		(iy+4),a
		ld		a,8
		ld		(iy+5),a
		ld		a,1
		ld		(iy+7),a
						
		ld		a,1
		ld		(serp1),a
		
		;		otras variables
		ld		a,1
		ld		(fase_en_la_que_esta),a
		ld		hl,111
		ld		(posicion_puerta),hl
		
		call	define_espera_entre_fases					
		call	rutina_de_esperar_un_rato

		call	activa_musica_fases										;inicia el reproductor de PT3
		
		di
		call	setrompage0
		
		ld		hl,fase_1												;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	recbios
		ei
		
		call	diferencias_en_las_fases
				
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase
								
bloque_sanctuary_2:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 1
		or		a
		jr.		z,bloque_sanctuary_2_esp
		ld		hl,sanctuary_x
		jr.		bloque_sanctuary_2_cont

bloque_sanctuary_2_esp:

		ld		hl,santuario_x

bloque_sanctuary_2_cont:
		
		call	anunciamos_el_santuario_correspondiente
		ld		hl,sanctuary_2
		call	anunciamos_el_santuario_correspondiente_numero
		;		coordenadas prota
		ld		a,24													;define variables
		ld		b,a
		ld		a,16						
		call	coordenadas_prota
		
		call	variables_iguales
				
		;		coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		ld		a,216
		ld		(iy),a
		ld		a,16
		ld		(iy+1),a
		xor	a
		ld		(iy+2),a
		ld		a,11
		ld		(iy+4),a
		ld		a,1
		ld		(iy+7),a
						
		ld		a,1
		ld		(serp1),a
		
		;		otras variables
		ld		a,2
		ld		(fase_en_la_que_esta),a
		ld		hl,67
		ld		(posicion_puerta),hl
		
		call	define_espera_entre_fases					
		call	rutina_de_esperar_un_rato

		call	activa_musica_fases										;inicia el reproductor de PT3
		
		di
		call	setrompage0
		
		ld		hl,fase_2												;cargamos sanctuary 1 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	recbios
		ei

		call	diferencias_en_las_fases
				
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase
		
bloque_sanctuary_3:
		
		call	pantalla_en_blanco
		
		ld		a,(idioma)												;anunciamos sanctuary 3
		or		a
		jr.		z,bloque_sanctuary_3_esp
		ld		hl,sanctuary_x
		jr.		bloque_sanctuary_3_cont

bloque_sanctuary_3_esp:

		ld		hl,santuario_x

bloque_sanctuary_3_cont:

		call	anunciamos_el_santuario_correspondiente
		ld		hl,sanctuary_3
		call	anunciamos_el_santuario_correspondiente_numero
		
		;		variables coordenadas prota
		
		ld		a,120													;define variables
		ld		b,a
		ld		a,88						
		call	coordenadas_prota
		
		call	variables_iguales
		
		;variables coordenadas serpientes
		
		ld		iy,variables_serpiente_1
		
		ld		a,24
		ld		(iy+1),a
		ld		a,120
		ld		(iy),a
		ld		a,5
		ld		(iy+5),a
		ld		a,13
		ld		(iy+4),a
				
		ld		a,1	
		ld		(serp1),a
		
		;		otras variables
			
		ld		a,3
		ld		(fase_en_la_que_esta),a
		ld		hl,367
		ld		(posicion_puerta),hl
		ld		a,1
		ld		(toca_bombero),a

		call	define_espera_entre_fases
		call	rutina_de_esperar_un_rato
		
		call	activa_musica_fases
		
		di
		call	setrompage0
		
		ld		hl,fase_3												;cargamos sanctuary 3 en ram
		ld		de,buffer_colisiones
		call	depack
		
		call	recbios
		ei
		
		call	diferencias_en_las_fases
		
		call	copiamos_en_pantalla_lo_de_memoria

		call 	gran_rutina												;vamos a la rutina de movimientos general
		
		jr.		repite_fase

bloque_sanctuary_4:
				
		jr.		MENU

pinta_mando_de_luz_en_su_sitio:

		ld		a,93
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		bc,1
		jr.		GRABAVRAM

pantalla_en_mas_blanco:
		
		call	DISSCR
		
		di
		ld		hl,mas_blanco											;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
				
		ei
		
		jp		ENASCR
				
pantalla_en_blanco:
		
		call	DISSCR
		
		di
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
		
		
		ld		hl,trofeos												;carga objetos
		ld		de,#1818
		call	depack_VRAM
		
		ei
		
		jp		ENASCR

copiamos_en_pantalla_lo_de_memoria:
		ld		a,(pantalla_activa)
		cp		1
		jr.		nz,copiamos_en_pantalla_lo_de_memoria_2
		
		ld		hl,buffer_colisiones									;copia en vram para que lo vea el jugador
		jr.		copiamos_en_pantalla_lo_de_memoria_tras_buffer
		
copiamos_en_pantalla_lo_de_memoria_2:

		ld		hl,buffer_colisiones_2
		
copiamos_en_pantalla_lo_de_memoria_tras_buffer:

		ld		de,#1820
		ld		bc,736
		jr.		GRABAVRAM

anunciamos_el_santuario_correspondiente:

		ld		de,#198a
		ld		bc,10
		jr.		GRABAVRAM

anunciamos_el_santuario_correspondiente_numero:

		ld		de,#1994
		ld		bc,2
		call	GRABAVRAM
		jr.		rutina_pone_consejo
				
variables_iguales:

		ld		a,2
		ld		(color_prota),a
		ld		a,1
		ld		(color_lineas_prota),a
		ld		(muerto),a
		ld		(grifo_estado),a
		ld		(vision_estado),a
		ld		(puede_cambiar_de_direccion),a
		ld		(pantalla_activa),a

		xor		a
		ld		(estado_prota),a
		ld		(pasamos_la_fase),a
		ld		(gasolina),a
		ld		(mechero),a
		ld		(ya_ha_cambiado_puerta),a
		ld		(tiene_objeto),a
		ld		(pasos_de_salto),a
		ld		(estado_de_salto),a
		ld		(momento_lanzamiento),a
		ld		(escalera_activada),a
		ld		(serp1),a
		ld		(serp2),a
		ld		(serp3),a
		ld		(serp4),a
		ld		(bombero_1),a
		ld		(colision_bombero_prota_real),a
		ld		(colision_cuchillo_serp_real),a
		ld		(prev_dir_prota),a
		ld		(dir_prota),a
		ld		(estado_de_explosion),a
		ld		(retard_anim),a
		ld		(balsa_activa),a
		ld		(toca_bombero),a
		ld		(tile_a_poner_agua),a
		ld		(estado_de_explosion),a
		ld		(contador_retardo_explosion),a
		
		ld		a,1
		ld		(pantalla_puerta),a
		ld		(pantalla_escalera),a
		ld		(grifos_balsa_cerrados),a
		ld		(balsa_bacia),a
		ld		(pantalla_tile_grifo_balsa_1),a
		ld		(pantalla_tile_grifo_balsa_2),a
		ld		(pantalla_balsa),a
		ld		(vision_estado),a
		ld		(clock),a		
		ld		(dir_cuchillo),a
		ld		(cx),a
		ld		(cy),a
		
		; serpientes
		
		ld		iy,variables_serpiente_1
		call	variables_serpientes		
		ld		iy,variables_serpiente_2		
		call	variables_serpientes
		ld		iy,variables_serpiente_3		
		call	variables_serpientes
		ld		iy,variables_serpiente_4		
		call	variables_serpientes
		
		; variables bombero_1
		
		;		coordenadas bombero
		
		ld		iy,bombero_control
		ld		a,2
		ld		(iy+2),a
		ld		a,150
		ld		(iy+3),a
		ld		a,10
		ld		(iy+4),a
		xor		a
		ld		(iy+5),a
		ld		(iy+6),a
		ld		(iy+7),a
		ld		(iy+10),a
		ld		a,20
		ld		(iy+8),a
		ld		a,1
		ld		(iy),a
		ld		(iy+1),a
		ld		(iy+9),a
		ld		a,1
		ld		(iy+12),a
		
		ld		a,5
		ld		(cont_no_salta_dos_seguidas),a
		ld		(contador_poses_lanzar),a
		ld		a,50
		ld		(contador_escalera),a
		ld		a,3
		ld		(velocidad_paseo_fases),a
				
		ret

variables_serpientes:

		ld		a,1
		ld		(iy+2),a
		ld		(iy+7),a
		ld		(iy+9),a
		xor		a
		ld		(iy+3),a
		ld		(iy+6),a
		ld		a,14
		ld		(iy+4),a
		ld		(iy+5),a	
		ld		a,255
		ld		(iy+8),a
		
		ret
		
SPRITES_PETISOS:

		ld		hl,sprites_pet											;cargamos petisos
		ld		de,#3800
		ld		bc,736
		jp		GRABAVRAM

;SPRITES_ONIRIC:

;		ld		hl,sprites_oniric										;cargamos petisos
;		ld		de,#3800
;		ld		bc,128
;		call	GRABAVRAM
		
;		ret
SPRITES_OJOS:
		
		ld		hl,sprites_ojos											;cargamos OJOS
		ld		de,#3A00
		ld		bc,128
		jp		GRABAVRAM
				
SPRITES_UNO:

		ld		hl,sprites												;carga sprites general
		ld		de,#3800
		ld		bc,1824
		call	GRABAVRAM
		
		ld		a,(idioma)
		or		a
		ret		nz
		
		ld		hl,quemado_esp											;carga sprites quemado en castellano
		ld		de,#3e60
		ld		bc,96
		jp		GRABAVRAM

SPRITES_DOS:

		ld		hl,sprites2												;cargamos sprites bombero parte 1
		ld		de,#3b20
		ld		bc,256
		call	GRABAVRAM

		ld		hl,sprites3												;cargamos sprites bombero parte 2
		ld		de,#3da0
		ld		bc,288
		call	GRABAVRAM
		
		ld		hl,sprites4												;cargamos sprites bombero parte 3
		ld		de,#3ee0
		ld		bc,256
		jp		GRABAVRAM
				
SPRITES_PAUSA:

		ld		hl,pausa_sprit											;cargamos sprites de pausa			
		ld		de,#3800
		ld		bc,192
		jp		GRABAVRAM
						
SPRITES_BOMBA:

		ld		hl,sprites5												;cargamos sprites de bomba			
		ld		de,#3800
		ld		bc,576
		jp		GRABAVRAM
						
SPRITES_CUCHILLO:

		ld		hl,sprites9												;cargamos sprites de cuchillo
		ld		de,#3800
		ld		bc,576
		jp		GRABAVRAM
		
SPRITES_PROTA_NORMAL:
		
		ld		hl,sprites13											;volvemos a sprites normales
		ld		de,#3800
		ld		bc,576
		jp		GRABAVRAM
			
SPRITES_BOMBERO_PERSIGUE:
		
		ld		hl,sprites_bomb_a										;volvemos a sprites normales
		ld		de,#3800
		ld		bc,576
		jp		GRABAVRAM
								
string_de_espera:

		xor		a
		CALL	ONSTRIG
		or		a
		ret		nz
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		z,string_de_espera
		
		ret

activa_mute:
	
		di
		
		ld		hl,MUTE-99												;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr. 	musica_con_bucle
		
activa_musica_fases:
				
		call	activa_mute
		
		ld		a,(ESTADO_MUSICA)
		CP		2		
		jr.		z,activa_musica_menu
			
		ld		A,(ESTADO_MUSICA)
		cp		0
		ret		z
	
		di
		
		call	setrompage0												;con la pagina 0 de la rom pisamos la bios
		
		ld		hl,MUSICA_FASES											;descomprime musica de inicio
		ld		de,GEN_MUSIC
		call	depack
		
		call	recbios
		
		ld		hl,GEN_MUSIC-99											;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr.		musica_con_bucle

activa_musica_menu:
			
		di
		
		call	setrompage0												;con la pagina 0 de la rom pisamos la bios
		
		ld		hl,CANCION												;descomprime musica de inicio
		ld		de,GEN_MUSIC
		call	depack
		
		call	recbios
		
		ld		hl,GEN_MUSIC-99											;SILENCIA LA MUSICA
		call	PT3_INIT
		
		ei
		
		jr.		musica_con_bucle
		
activa_musica_muerto:
	
		di
		
		ld		hl,MUERTO-99											;MUSICA DE MUERTE
		call	PT3_INIT
		
		ei
		
		jr.		musica_sin_bucle

activa_musica_entre_fases:
	
		di
		
		ld		hl,ENTRE_FASES-99										;MUSICA ENTRE FASES
		call	PT3_INIT
		
		ei
		
		jr.		musica_sin_bucle

rutina_de_esperar_un_rato:

		halt
		ld		hl,(clock)
		ld		bc,1		
		sbc		hl,bc
		ld		(clock),hl
		jr		nz,rutina_de_esperar_un_rato
		
		ret

PREPARACION_SCREEN_2:

		ld		a,2
		call	SCREENX
		ld		a,(RG1SAV)
		or		00000010b												;modo sprites a 16x16
		and		11111110b												;modo sprites no ampliados
		ld		b,a
		ld		c,1
		jp		WRTVDP													;lo escribe en el registro 1 del VDP
			
gran_rutina:
						
		halt
																		;espera a la interrupcion vblank y sincroniza toda la acción
		call	atributos_sprites
		call	actualiza_atributos_sprite		
		call	comprueba_estado_de_explosion
		call	que_pinto_de_la_balsa
		call	tiles_cambiantes
		
		call	pulsa_una_tecla
		call	ous
		
		call	revisa_escalera
		call	revisa_bombero
		call	grifo_bombero
		call	grifos_balsa_bombero
		
		call	estado_en_que_se_encuentra
		call	apaga_los_chorros
		call	movimiento_forzado_en_puertas
		call	vigila_si_cierra_puertas
		call	mueve_prota
		call	usa_objeto_o_salta
		call	rutina_cuchillo_volador
		call	coge_algun_objeto
		call	pose_si_esta_parado
		
		
		call	colision_bombero_prota
		call	colisiones_serpientes_cuchillos
		call	colisiones_serpientes_prota_1
		call	movimiento_serpientes
		call	actualiza_la_puerta
		call	puntuacion_vidas_fase
				
		ld		a,(pasamos_la_fase)
		or		a
		jr.		nz,animacion_entre_fases
		
		ld		a,(muerto)
		or		a
		jr.		z,repite_fase
		
		jp		gran_rutina

ous:
		
		ld		a,(OUS_ACTIU)
		or		a
		jr.		z,ous_inici
		cp		1
		jr.		z,ous_1_2
		cp		2
		jr.		z,ous_1_3
		cp		3
		jr.		z,ous_1_4
		cp		4
		jr.		z,ous_1_5
		cp		5
		jr.		z,ous_1_6
		cp		6
		jr.		z,ous_1_7
		cp		7
		jr.		z,ous_1_8
		cp		10
		jr.		z,ous_1_7
		cp		11
		jr.		z,ous_2_3
		cp		12
		jr.		z,ous_2_4
		cp		13
		jr.		z,ous_1_2
		cp		14
		jr.		z,ous_2_6
		cp		15
		jr.		z,ous_2_7
		cp		17
		jr.		z,ous_3_2
		cp		18
		jr.		z,ous_3_3
		cp		19
		jr.		z,ous_1_7
		cp		20
		jr.		z,ous_3_3
		cp		21
		jr.		z,ous_3_6
		cp		22
		jr.		z,ous_3_7
		cp		23
		jr.		z,ous_3_8
		cp		25
		jr.		z,ous_3_7
		cp		26
		jr.		z,ous_3_6
		cp		27
		jr.		z,ous_4_4
		cp		28
		jr.		z,ous_4_5
		cp		29
		jr.		z,ous_1_3
		cp		30
		jr.		z,ous_3_7
		cp		31
		jr.		z,ous_4_4
		cp		32
		jr.		z,ous_1_6
		cp		33
		jr.		z,ous_4_10
		
		ret
		
ous_inici:
		
		ld		a,5
		call	SNSMAT
		bit		0,a
		jr.		z,aumenta_ou
		
		ld		a,5
		call	SNSMAT
		bit		1,a
		jr.		z,inicia_ou_2
		
		ld		a,4
		call	SNSMAT
		bit		4,a
		jr.		z,inicia_ou_3
		
		ld		a,4
		call	SNSMAT
		bit		1,a
		jr.		z,inicia_ou_4
				
		ret

ous_1_2:

		ld		a,2
		call	SNSMAT
		bit		6,a
		jr.		z,aumenta_ou		
		ret

ous_1_3:

		ld		a,4
		call	SNSMAT
		bit		1,a
		jr.		z,aumenta_ou		
		ret
		
ous_1_4:

		ld		a,3
		call	SNSMAT
		bit		4,a
		jr.		z,aumenta_ou		
		ret
		
ous_1_5:

		ld		a,5
		call	SNSMAT
		bit		2,a
		jr.		z,aumenta_ou		
		ret
		
ous_1_6:

		ld		a,3
		call	SNSMAT
		bit		2,a
		jr.		z,aumenta_ou		
		ret
		
ous_1_7:

		ld		a,4
		call	SNSMAT
		bit		7,a
		jr.		z,aumenta_ou		
		ret
		
ous_1_8:

		ld		a,3
		call	SNSMAT
		bit		6,a
		jr.		z,dos_vidas_mas	
		ret
		
inicia_ou_2:
		
		ld		a,10
		ld		(OUS_ACTIU),a
		
		ret

inicia_ou_3:
		
		ld		a,17
		ld		(OUS_ACTIU),a
		
		ret

inicia_ou_4:
		
		ld		a,25
		ld		(OUS_ACTIU),a
		
		ret
				
ous_2_3:

		ld		a,4
		call	SNSMAT
		bit		4,a
		jr.		z,aumenta_ou		
		ret

ous_2_4:

		ld		a,4
		call	SNSMAT
		bit		2,a
		jr.		z,aumenta_ou		
		ret
				
ous_2_6:

		ld		a,5
		call	SNSMAT
		bit		5,a
		jr.		z,aumenta_ou		
		ret
		
ous_2_7:

		ld		a,3
		call	SNSMAT
		bit		2,a
		jr.		z,activa_pasa_fases		
		ret

ous_3_2:

		ld		a,4
		call	SNSMAT
		bit		3,a
		jr.		z,aumenta_ou		
		ret
		
ous_3_3:

		ld		a,3
		call	SNSMAT
		bit		6,a
		jr.		z,aumenta_ou		
		ret

ous_3_6:

		ld		a,3
		call	SNSMAT
		bit		0,a
		jr.		z,aumenta_ou		
		ret

ous_3_7:

		ld		a,5
		call	SNSMAT
		bit		2,a
		jr.		z,aumenta_ou		
		ret

ous_3_8:

		ld		a,5
		call	SNSMAT
		bit		0,a
		jr.		z,inmune_a_serpientes	
		ret

ous_4_4:

		ld		a,4
		call	SNSMAT
		bit		0,a
		jr.		z,aumenta_ou		
		ret

ous_4_5:

		ld		a,5
		call	SNSMAT
		bit		6,a
		jr.		z,aumenta_ou		
		ret

ous_4_10:

		ld		a,2
		call	SNSMAT
		bit		7,a
		jr.		z,inmune_bombero		
		ret
						
																						
aumenta_ou:
		
		ld		a,(OUS_ACTIU)
		inc		a
		ld		(OUS_ACTIU),a
		
		ret

inmune_a_serpientes:
		
		ld		a,100
		ld		(OUS_ACTIU),a
		
		ld		a,1
		ld		(inmune_serp),a
		
		ld		a,2														;efecto sonoro de coger
		jp		efecto_sonido

inmune_bombero:
		
		ld		a,100
		ld		(OUS_ACTIU),a
		
		ld		a,1
		ld		(inmune_bomb),a
		
		ld		a,2														;efecto sonoro de coger
		jp		efecto_sonido
	
dos_vidas_mas:

		ld		a,100
		ld		(OUS_ACTIU),a
		ld		a,(vidas_prota)
		add		10
		ld		(vidas_prota),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,2														;efecto sonoro de coger
		jp		efecto_sonido

activa_pasa_fases:
		
		ld		a,100
		ld		(OUS_ACTIU),a
		ld		a,3
		ld		(trampa),a
		
		ld		a,2														;efecto sonoro de coger
		jp		efecto_sonido

variantes_de_items:
		
		ld		a,(posicion_brillo_items)
		inc		a
		ld		(posicion_brillo_items),a

		cp		3
		jr.		z,variante_1
		cp		6
		jr.		z,variante_2
		cp		9
		jr.		z,variante_3
		cp		12
		jr.		z,variante_4
		cp		15
		jr.		z,variante_5
		cp		18
		jr.		z,variante_6
		cp		21
		jr.		z,variante_7
		cp		24
		jr.		z,variante_8
		
		ret

standard_brillo:

		push	hl
		push	de
		ld		a,2
		ld		(valor_a_cambiar_en_tile_v),a
		jp		resto_de_standard
						
variante_1:
		
		ld		hl,color_gas_1
		ld		de,#2308
		call	standard_brillo
		ld		hl,color_mec_1
		ld		de,#2310
		jr.		standard_brillo
		
variante_2:
		
		ld		hl,color_gas_2
		ld		de,#2309
		call	standard_brillo
		ld		hl,color_mec_2
		ld		de,#2311
		jr.		standard_brillo
		
variante_3:
		
		ld		hl,color_gas_3
		ld		de,#230a
		call	standard_brillo
		ld		hl,color_mec_3
		ld		de,#2312
		jr.		standard_brillo
		
variante_4:
		
		ld		hl,color_gas_4
		ld		de,#230b
		call	standard_brillo
		ld		hl,color_mec_4
		ld		de,#2313
		jr.		standard_brillo

variante_5:
		
		ld		hl,color_gas_5
		ld		de,#230c
		call	standard_brillo
		ld		hl,color_mec_5
		ld		de,#2314
		jr.		standard_brillo
		
variante_6:
		
		ld		hl,color_gas_6
		ld		de,#230d
		call	standard_brillo
		ld		hl,color_mec_6
		ld		de,#2315
		jr.		standard_brillo
		
variante_7:
		
		ld		hl,color_gas_7
		ld		de,#230e
		call	standard_brillo
		ld		hl,color_mec_7
		ld		de,#2316
		jr.		standard_brillo
		
variante_8:
		
		ld		hl,$e5
		ld		de,#230f
		ld		bc,1
		call	GRABAVRAM
		ld		hl,$e5
		ld		de,#2317
		ld		bc,1
		jr.		GRABAVRAM
		
reinicia_brillo_items:

		xor		a
		ld		(posicion_brillo_items),a
		
		ret

standard_tiles_cambiantes:
		
		push	hl
		push	de
		ld		a,8
		ld		(valor_a_cambiar_en_tile_v),a
		jp		resto_de_standard

resto_de_standard:

		ld		bc,(valor_a_cambiar_en_tile_v)
		CALL	GRABAVRAM
		
		ld		bc,#800
		pop		hl
		adc		hl,bc
		push	hl
		pop		de
		pop		hl
		push	hl
		push	de
		ld		bc,(valor_a_cambiar_en_tile_v)
		CALL	GRABAVRAM
		
		ld		bc,#800
		pop		hl
		adc		hl,bc
		push	hl
		pop		de
		pop		hl
		ld		bc,(valor_a_cambiar_en_tile_v)
		jp		GRABAVRAM

standard_tiles_cambiantes_2:

		push	hl
		push	de
		ld		a,1
		ld		(valor_a_cambiar_en_tile_v),a
		jp		resto_de_standard

standard_tiles_cambiantes_3:

		push	hl
		push	de
		ld		a,16
		ld		(valor_a_cambiar_en_tile_v),a
		jp		resto_de_standard
		
standard_tiles_cambiantes_4:

		push	hl
		push	de
		ld		a,8*4
		ld		(valor_a_cambiar_en_tile_v),a
		jp		resto_de_standard
				
								
tiles_cambiantes:
		
		
				
		ld		a,(clock_1)
		dec		a
		ld		(clock_1),a
		or		a
		call	z,reset_clock
		cp		10
		call	nc,limpia_clock_a_10
		
		call	variantes_de_items
		
		ld		a,(posicion_brillo_items)
		cp		100
		call	z,reinicia_brillo_items
		
		ld		a,(tile_a_poner_agua)
		or		a
		jr.		nz,tiles_cambiantes_1
				
		ld		hl,agua_1
		ld		de,#570
		call	standard_tiles_cambiantes
				
		ld		hl,chorro_1
		ld		de,#5a8
		call	standard_tiles_cambiantes_3
								
		ld		hl,fuego_1_2
		ld		de,#4c0
		call	standard_tiles_cambiantes
						
		ld		hl,portal_1
		ld		de,#168
		call	standard_tiles_cambiantes_4
		
		ld		hl,cuchillo_1
		ld		de,#2302
		call	standard_tiles_cambiantes_2
								
		ld		hl,bomba_1
		ld		de,#231a
		call	standard_tiles_cambiantes_2
								
		ld		hl,salpic_1_1
		ld		de,#2c0
		call	standard_tiles_cambiantes
						
		ld		hl,salpic_1_2
		ld		de,#2d0
		jr.		standard_tiles_cambiantes
						
tiles_cambiantes_1:
		
		ld		hl,agua_2
		ld		de,#570
		call	standard_tiles_cambiantes
						
		ld		hl,chorro_2
		ld		de,#5a8
		call	standard_tiles_cambiantes_3
								
		ld		hl,fuego_2_2
		ld		de,#4c0
		call	standard_tiles_cambiantes
				
		ld		hl,portal_2
		ld		de,#168
		call	standard_tiles_cambiantes_4
						
		ld		hl,cuchillo_2
		ld		de,#2302
		call	standard_tiles_cambiantes_2
				
		ld		hl,bomba_2
		ld		de,#231a
		call	standard_tiles_cambiantes_2
						
		ld		hl,salpic_2_1
		ld		de,#2c0
		call	standard_tiles_cambiantes
						
		ld		hl,salpic_2_2
		ld		de,#2d0
		jr.		standard_tiles_cambiantes
				
reset_clock:
		
		ld		bc,10
		ld		(clock_1),bc
		
		ld		a,(tile_a_poner_agua)
		inc		a
		ld		(tile_a_poner_agua),a
		cp		2
		jr.		z,reset_clock_2
		
		ret

reset_clock_2:

		xor		a
		ld		(tile_a_poner_agua),a
		
		ret

limpia_clock_a_10:

		ld		bc,10
		ld		(clock_1),bc
		
		ret
		
diferencias_en_las_fases:
		
		ld		a,(nivel)
		or		a
		jr.		nz,diferencias_en_las_fases_2
		
		ld		a,(fase_en_la_que_esta)
		ld 		de,POINT_de_diferencias_fase_1
		jp		lista_de_opciones
		
final_diferencias_fase:
		
		ret

diferencias_en_las_fases_2:

		ld		a,(fase_en_la_que_esta)
		ld 		de,POINT_de_diferencias_fase_2
		jp		lista_de_opciones
		
POINT_de_diferencias_fase_1:
		
		dw		cambios_fase_1
		dw		cambios_fase_1
		dw		cambios_fase_3
		dw		cambios_fase_4
		dw		cambios_fase_5
		dw		cambios_fase_6
		dw		final_diferencias_fase
		dw		cambios_fase_8
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		cambios_fase_5
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		cambios_fase_17
		dw		final_diferencias_fase

POINT_de_diferencias_fase_2:
		
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		cambios_fase_7
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		cambios_fase_10
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		cambios_fase_13
		dw		final_diferencias_fase
		dw		cambios_fase_10
		dw		final_diferencias_fase
		dw		final_diferencias_fase
		dw		final_diferencias_fase
				
cambios_fase_1:

		ld		iy,variables_serpiente_1
		ld		a,2
		ld		(iy+7),a

		ret
		
cambios_fase_3:

		ld		hl,buffer_colisiones
		ld		a,41
		ld		bc,509
		adc		hl,bc
		ld		[hl],a
		inc		hl
		inc		a
		ld		[hl],a
		ld		bc,47
		adc		hl,bc
		ld		a,32
		ld		[hl],a
		inc		hl
		ld		[hl],a
		ld		bc,31
		adc		hl,bc
		ld		[hl],a
		inc		hl
		ld		[hl],a
		
		xor		a
		ld		(toca_bombero),a
		ret
		
cambios_fase_4:
		
		xor		a
		ld		(bombero_1),a
								
		ret
		
cambios_fase_5:

		ld		iy,bombero_control
		ld		a,2
		ld		(iy+2),a

		ret

cambios_fase_6:

		xor		a
		ld		(serp4),a
;		ld		iy,variables_serpiente_1
;		xor		a
;		ld		(iy+1),a
;		ld		(iy+4),a
;		ld		ix,atributos_sprite_general
;		ld		de,16
;		add		ix,de
;		jp		atributos_sprites

		ret
cambios_fase_7:
		
		ld		hl,buffer_colisiones
		ld		a,32
		ld		bc,167
		adc		hl,bc
		ld		[hl],a
		ld		bc,159
		adc		hl,bc
		ld		a,168
		ld		[hl],a
		
		ret
		
		
cambios_fase_8:

		xor		a
		ld		(serp4),a
		
		ld		hl,buffer_colisiones_2
		ld		a,96
		ld		bc,689
		adc		hl,bc
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		
		ret
		
cambios_fase_10:

		ld		iy,bombero_control
		ld		a,1
		ld		(iy+9),a
		ld		a,3
		ld		(iy+2),a
		ret

cambios_fase_13:

		ld		hl,buffer_colisiones
		ld		a,32
		ld		bc,100
		adc		hl,bc
		ld		[hl],a
		ld		bc,24
		adc		hl,bc
		ld		[hl],a
						
		ret
				
cambios_fase_14:
		
		ld		hl,buffer_colisiones
		ld		a,32
		ld		bc,134
		adc		hl,bc
		ld		[hl],a
		ld		bc,553
		adc		hl,bc
		ld		[hl],a
				
		ret
		
cambios_fase_17:

		ld		hl,buffer_colisiones
		ld		a,41
		ld		bc,282
		adc		hl,bc
		ld		[hl],a
		inc		hl
		inc		a
		ld		[hl],a

		ret
				
;cambios_fase_19:

;		ld		a,0
;		ld		(serp4),a
		
;		ret
														
vigila_si_cierra_puertas:
		
		ld		a,(puede_cambiar_de_direccion)
		cp		1
		ret		z
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		117
		jr.		z,recoloca_puerta_amarilla_izquierda
		cp		118
		jr.		z,recoloca_puerta_azul_izquierda
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		
		cp		117
		jr.		z,recoloca_puerta_amarilla_derecha
		cp		118
		jr.		z,recoloca_puerta_azul_derecha	
		
		ret
							
movimiento_forzado_en_puertas:

		ld		a,(puede_cambiar_de_direccion)
		cp		1
		ret		z
		
		ld		a,13													;efecto sonoro de puerta abierta
		call	efecto_sonido
					
		ld		a,(dir_prota)
		or		a
		jr.		z,(mueve_derecha_prota)
		cp		1														;va a la izquierda forzado
		jr.		z,(mueve_izquierda_prota)

recoloca_puerta_amarilla_derecha:
				
		ld		a,(dir_prota)
		or		a
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		ld		a,113
		ld		[hl],a
								
		call	menos_uno_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,113
		call	pinta_en_pantalla
		
		call	menos_uno_dos
		call	get_bloque_en_X_Y
		ld		a,113
		ld		[hl],a
								
		call	menos_uno_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,113
		jp		pinta_en_pantalla
		
recoloca_puerta_amarilla_izquierda:
		
		ld		a,(dir_prota)
		cp		1
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		ld		a,114
		ld		[hl],a
								
		call	dieciseis_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,114
		call	pinta_en_pantalla
		
		call	dieciseis_dos
		call	get_bloque_en_X_Y
		ld		a,114
		ld		[hl],a
								
		call	dieciseis_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,114
		jp		pinta_en_pantalla
				
recoloca_puerta_azul_derecha:
		
		
		ld		a,(dir_prota)
		or		a
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	menos_uno_quince
		call	get_bloque_en_X_Y
		ld		a,116
		ld		[hl],a
								
		call	menos_uno_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,116
		call	pinta_en_pantalla
		
		call	menos_uno_dos
		call	get_bloque_en_X_Y
		ld		a,116
		ld		[hl],a
								
		call	menos_uno_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,116
		jp		pinta_en_pantalla
				
recoloca_puerta_azul_izquierda:
		
		ld		a,(dir_prota)
		cp		1
		ret		nz
		
		ld		a,1
		ld		(puede_cambiar_de_direccion),a
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		ld		a,115
		ld		[hl],a
								
		call	dieciseis_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,115
		call	pinta_en_pantalla
		
		call	dieciseis_dos
		call	get_bloque_en_X_Y
		ld		a,115
		ld		[hl],a
								
		call	dieciseis_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,115
		jp		pinta_en_pantalla
		
grifos_balsa_bombero:
		
		
		ld		iy,bombero_control
		
		ld		a,(pantalla_activa)										;cambiamos circunstancialmente la pantalla activa por la del bombero para ver qué pasa
		push	af
		ld		a,(iy+12)
		ld		(pantalla_activa),a
		
		ld		a,(iy)													;comprobamos lo que tiene donde está					
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		178														;si el grifo ya está abierto, sigue la gran rutina
		jr.		nz,grifos_balsa_bombero_cierre
		
		ld		a,(pantalla_tile_grifo_balsa_1)
		cp		1
		jr.		nz,grifos_balsa_bombero_2
		
		ld		bc,(tile_grifo_balsa_1)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones
		jr.		grifos_balsa_bombero_3
		
grifos_balsa_bombero_2:
		
		ld		bc,(tile_grifo_balsa_1)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones_2

grifos_balsa_bombero_3:
		
		adc		hl,bc
		ld		bc,32
		sbc		hl,bc
		ld		a,179
		ld		[hl],a
				
		ld		a,(pantalla_tile_grifo_balsa_2)
		cp		1
		jr.		nz,grifos_balsa_bombero_4

		
		ld		bc,(tile_grifo_balsa_2)
		ld		hl,buffer_colisiones
		jr.		grifos_balsa_bombero_5
		
grifos_balsa_bombero_4:
		
		ld		bc,(tile_grifo_balsa_2)
		ld		hl,buffer_colisiones_2
		
grifos_balsa_bombero_5:
		
		adc		hl,bc
		ld		bc,32
		sbc		hl,bc
		ld		a,179
		ld		[hl],a
			
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,grifos_balsa_bombero_6
								
		ld		bc,(posicion_balsa_desde_grifo)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones
		jr.		grifos_balsa_bombero_7

grifos_balsa_bombero_6:

		ld		bc,(posicion_balsa_desde_grifo)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones_2
		
grifos_balsa_bombero_7:
		
		adc		hl,bc
		ld		bc,29
		adc		hl,bc
		ld		a,174
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		ld		bc,27
		adc		hl,bc
		ld		[hl],a
		inc		hl
		ld		[hl],a
[2]		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
[2]		dec		hl
		ld		a,175
		ld		[hl],a
		
		ld		a,16														;efecto sonoro de grifo de balsa cerrado
		call	efecto_sonido						

		pop		af
		ld		(pantalla_activa),a
		cp		a,1
		jr.		nz,grifos_balsa_bombero_8
		
		push	af
		ld		hl,buffer_colisiones
		call	copiamos_en_pantalla_lo_de_memoria
		jr.		grifos_balsa_bombero_9

grifos_balsa_bombero_8:
		
		push	af
		ld		hl,buffer_colisiones_2
		call	copiamos_en_pantalla_lo_de_memoria_tras_buffer

grifos_balsa_bombero_9:
				
		ld		a,1														; da valor a la variable para abrir el grifo de balsa
		ld		(grifos_balsa_cerrados),a
		ld		(balsa_bacia),a

grifos_balsa_bombero_cierre:

		pop		af
		ld		(pantalla_activa),a
		ret
		
grifo_bombero:

		ld		iy,bombero_control
		
		ld		a,(pantalla_activa)
		push	af
		ld		a,(iy+12)
		ld		(pantalla_activa),a
		
		ld		a,(iy)													;comprobamos lo que tiene donde está					
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y
		cp		a,119														;si el grifo ya está abierto, sigue la gran rutina
		jr.		nz,grifo_bombero_1
		
		ld		a,(iy)													;para buffer y vram moviendo 0,10						
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,87
		ld		[hl],a
		
		pop		af
		ld		(pantalla_activa),a
		ld		b,a
		push	af
		ld		a,(iy+12)
		cp		b
		jr.		nz,grifo_bombero_continua
								
		ld		a,(iy)													;para buffer y vram moviendo 0,10						
		ld		d,a
		ld		a,(iy+1)
		add		10
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		ld		a,87
		ld		[hl],a
		
grifo_bombero_continua:
		
		
		ld		a,87
		call	pinta_en_pantalla
		
		ld		a,10													;efecto sonoro de abrir grifo
		call	efecto_sonido
		
		ld		a,1														; da valor a la variable para dar por hecho que el grifo está abierto
		ld		(grifo_estado),a

grifo_bombero_1:

		pop		af
		ld		(pantalla_activa),a
		ret

que_pinto_de_la_balsa:
		
		ld		a,(vision_estado)										;si no se ve, no pinta nada
		or		a
		ret		z
		
		ld		a,(balsa_activa)										;no mira nada si la balsa no está activa
		or		a
		ret		z
		
		ld		a,(pantalla_balsa)										;si no estamos en la pantalla de la balsa, no pinta nada
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		ret		nz
		
		ld		a,(grifos_balsa_cerrados)
		cp		1
		jr.		z,balsa_a_pintar_si_abierto_grifo
		
balsa_a_pintar_si_cerrado_grifo:
		
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,balsa_a_pintar_si_cerrado_grifo_1
		
		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones
		jr.		balsa_a_pintar_si_cerrado_grifo_2
		
balsa_a_pintar_si_cerrado_grifo_1:

		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones_2

balsa_a_pintar_si_cerrado_grifo_2:
		
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,balsa_a_pintar_si_cerrado_grifo_3
		
		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones
		jr.		balsa_a_pintar_si_cerrado_grifo_4

balsa_a_pintar_si_cerrado_grifo_3:

		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones_2

balsa_a_pintar_si_cerrado_grifo_4:

		adc		hl,bc
		ld		a,32
		ld		[hl],a
		
		ld		a,(pantalla_activa)
		ld		b,a
		ld		a,(pantalla_balsa)
		cp		b
		ret		nz
										
		ld		hl,(posicion_balsa_desde_grifo)							;dibujamos en pantalla la cañeria cerrada
		ld		a,180
		call	pinta_en_pantalla
		
		ld		hl,(posicion_balsa_desde_grifo)	
		ld		bc,32
		adc		hl,bc
		ld		a,32
		jp		pinta_en_pantalla

balsa_a_pintar_si_abierto_grifo:
		
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,balsa_a_pintar_si_abierto_grifo_1
		
		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones
		jr.		balsa_a_pintar_si_abierto_grifo_2
		
balsa_a_pintar_si_abierto_grifo_1:

		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones_2

balsa_a_pintar_si_abierto_grifo_2:
		
		adc		hl,bc
		ld		bc,32
		sbc		hl,bc
		ld		a,182
		ld		[hl],a
		
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,balsa_a_pintar_si_abierto_grifo_3
				
		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones
		jr.		balsa_a_pintar_si_abierto_grifo_4
		
balsa_a_pintar_si_abierto_grifo_3:

		ld		bc,(posicion_balsa_desde_grifo)
		ld		hl,buffer_colisiones_2
		
balsa_a_pintar_si_abierto_grifo_4:
		
		adc		hl,bc
		ld		a,181
		ld		[hl],a
		
		ld		a,(pantalla_activa)
		ld		b,a
		ld		a,(pantalla_balsa)
		cp		b
		ret		nz
										
		ld		hl,(posicion_balsa_desde_grifo)							;dibujamos en pantalla ela cañeria abierta
		ld		a,182
		call	pinta_en_pantalla
		
		ld		hl,(posicion_balsa_desde_grifo)	
		ld		bc,32
		adc		hl,bc
		ld		a,181
		jp		pinta_en_pantalla
						
revisa_bombero:

		ld		a,(bombero_1)											;si no está activo, vuelve a la gran rutina
		or		a
		ret		z
						
		ld	    iy,bombero_control										;si no tiene orden de aparecer, reduce el tiempo y vuelve a la gran rutina
		ld		a,(iy+8)
		or		a
		jr.		z,se_activa_el_bombero
		
		dec		a
		ld		(iy+8),a
		
		ret		
		
se_activa_el_bombero:

		ld		a,(pantalla_activa)										;control de pantalla en la que está el bombero
		push	af
		ld		a,(iy+12)
		ld		(pantalla_activa),a
		
		ld		a,(iy+9)												;vuelve a darle un poco de retardo al personaje (esto es uno de los puntos que marca la velocidad del bombero)
		ld		(iy+8),a
		
		ld		a,(iy+11)												;si no está a cero, no puede ni subir ni bajar escaleras.
		or		a
		jr.		nz,resta_y_camina
		
		
		
		ld		a,(iy)													;comprobamos lo que tiene donde está					
		ld		d,a
		ld		a,(iy+1)
		add		2
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		41														;si es escalera 1, va a decidir si sube o baja
		call	z,estamos_en_escalera

		cp		42														;si es escalera 2, va a decidir si sube o baja
		call	z,estamos_en_escalera
		
		ld		a,(iy+7)												;mira en qué estado está para ir a la rutina adecuada
	
		or		a
		jr.		z,revisa_caida_bombero
		cp		1
		jr.		z,revisa_subida_bombero
		cp		2
		jr.		z,revisa_bajada_bombero

resta_y_camina:

		dec		a
		ld		(iy+11),a
		jr.		revisa_caida_bombero
		
revisa_subida_bombero:
				
		ld		a,(iy)													;comprobamos lo que tiene encima					
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y

		cp		42
		jr.		z,continua_rvb
		cp		41
		jr.		nz,sigue_andando

continua_rvb:
		
		ld		a,(iy)													;comprobamos si está centrado					
		dec		a
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		call	z,corrige_en_escalera_bombero
		cp		42
		call	z,corrige_en_escalera_bombero
		
		ld		a,(iy+1)												;sube por la coordenada y
		sub		2
		ld		(iy+1),a
		
		jr.		decide_paso_en_escalera
	
revisa_bajada_bombero:
				
		ld		a,(iy)													;comprobamos lo que tiene debajo de los pies					
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y

		cp		42
		jr.		z,continua_rbb
		cp		73
		jr.		z,continua_rbb
		cp		74
		jr.		z,continua_rbb
		cp		41
		jr.		nz,sigue_andando

continua_rbb:
		
		ld		a,(iy)													;comprobamos si está centrado					
		dec		a
		ld		d,a
		ld		a,(iy+1)
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y
		
;		cp		41														;si no está centrado va a centrarse
;		call	z,corrige_en_escalera_bombero
		
		cp		42														;si no está centrado va a centrarse
		call	z,corrige_en_escalera_bombero
		
		ld		a,(iy+1)												;baja por la variable y
		add		2
		ld		(iy+1),a
		
		jr.		decide_paso_en_escalera

corrige_en_escalera_bombero:

		ld		a,(iy)													;lo pone hacia la izquierda hasta que se centra
		sub		2
		ld		(iy),a
				
		ret
		
sigue_andando:

		xor		a														;da a la variable adecuada el valor de andando
		ld		(iy+7),a
		ld		a,15
		ld		(iy+11),a		
		jr.		revisa_caida_bombero

decide_paso_en_escalera:

		ld		a,(iy+5)												;decide el paso en el que está si no pasa por avanzar
		
		or		a
		jr.		z,paso_uno_escaleras
		
		cp		1
		jr.		z,paso_dos_escaleras

paso_uno_escaleras:

		ld		a,1														;cambia el paso para la siguiente									
		ld		(iy+5),a
		
		ld		a,55*4													;define los sprites adecuados
		ld		b,a
		ld		a,49*4
		jr.		ultimas_variables_bombero
		
paso_dos_escaleras:

		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
		
		ld		a,58*4													;define los sprites adecuados
		ld		b,a
		ld		a,56*4
		jr.		ultimas_variables_bombero
						
revisa_caida_bombero:
		
		call	hacia_donde_quiero_ir									;decide la variable para seguir al prota en las escaleras
			
		ld		a,(iy)													;comprobamos lo que tiene debajo de los pies	
		add		2											
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y

		cp		41														;si es escalera irá a mirar la dirección ppara seguir como si nada
		jr.		z,define_direccion_bombero
		cp		42
		jr.		z,define_direccion_bombero

		cp		32
		jr.		c,define_direccion_bombero								;si hay muro vamos a ver la direccion para seguir como si nada

		ld		a,(iy)
		add		14														;comprobamos lo que tiene debajo de los pies en la parte derecha					
		ld		d,a
		ld		a,(iy+1)
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		41														;si es escalera irá a mirar la dirección ppara seguir como si nada
		jr.		z,define_direccion_bombero
		cp		42
		jr.		z,define_direccion_bombero
		
		cp		32
		jr.		c,define_direccion_bombero								;si hay muro vamos a ver la direccion para seguir como si nada

		ld		a,(iy+1)												;cae dos pixeles
		add		2
		ld		(iy+1),a
				
		ld		a,51*4
		ld		(ix+18),a
		add		4
		ld		(ix+22),a
		add		4
		ld		(ix+26),a		
		
		ld		ix,atributos_sprite_general
		
		ld		a,(ix+26)												;define los sprites
		ld		b,a
		ld		a,(ix+18)
		
		ex		af,af'
		pop		af
		push	bc
		ld		(pantalla_activa),a
		ld		b,a
		ld		a,(iy+12)
		cp		b
		jr.		nz,bombero_variables_anuladas
		
		ex		af,af'
		pop		bc
		
		ld		ix,atributos_sprite_general
		
		ld		(ix+18),a												;patrones
		add		4
		ld		(ix+22),a
		ld		(ix+26),b
		
		ld		a,(iy+1)												;y
		ld		(ix+16),a
		sub		a,10
		ld		(ix+24),a
		add		a,16
		ld		(ix+20),a
		
		jr.		ultimas_variables_bombero_2
		
define_direccion_bombero:
		
		xor		a														;estado andando
		ld		(iy+7),a
		
		ld		a,(iy+6)
		or		a
		jr.		z,va_hacia_la_derecha

va_hacia_la_izquierda:

		ld		a,(iy)
		cp		2
		call	c,bombero_cambia_de_pantalla
		
		ld		a,(iy)													;comprobamos la que tiene a su izquierda
		add		2											
		ld		d,a
		ld		a,(iy+1)
		add		11
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		32														;si hay pared cambia la direccion
		jr.		c,cambia_la_direccion_bombero
		cp		113														;si hay muros de pinchos tambien
		jr.		z,cambia_la_direccion_bombero
		cp		115														
		jr.		z,cambia_la_direccion_bombero
		
		ld		a,(iy+2)												;va hacia la izquierda lo adecuado
		ld		b,a
		ld		a,(iy)
		sub		a,b
		
		ld		(iy),a
		
		ld		a,(iy+5)												;decide el paso que le toca
		or		a
		jr.		z,paso_quieto_izquierda									

paso_movido_izquierda:
		
		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
			
		ld		a,45*4													;da los sprites adecuados
		ld		b,a
		ld		a,31*4
		jr.		ultimas_variables_bombero
		
paso_quieto_izquierda:
		
		ld		a,1														;cambia el paso para la siguiente
		ld		(iy+5),a	
	
		ld		a,48*4													;da los sprites adecuados
		ld		b,a
		ld		a,46*4
		jr.		ultimas_variables_bombero

va_hacia_la_derecha:
		
		ld		a,(iy)
		cp		239
		call	nc,bombero_cambia_de_pantalla
		
		ld		a,(iy)													;comprobamos la que tiene a su derecha
		add		13											
		ld		d,a
		ld		a,(iy+1)
		add		11
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		32														;si hay pared cambia de dirección
		jr.		c,cambia_la_direccion_bombero
		cp		114														;si hay muros de pinchos tambien
		jr.		z,cambia_la_direccion_bombero
		cp		116														
		jr.		z,cambia_la_direccion_bombero
		ld		a,(iy+2)												;suma a x lo adecuado
		ld		b,a
		ld		a,(iy)
		add		a,b
		
		ld		(iy),a
		
		ld		a,(iy+5)												;mira el paso que le toca
		or		a
		jr.		z,paso_quieto_derecha

paso_movido_derecha:

		xor		a														;cambia el paso para la siguiente
		ld		(iy+5),a
		
		ld		a,30*4													;define los sprites adecuados
		ld		b,a
		ld		a,28*4
		jr.		ultimas_variables_bombero
		
paso_quieto_derecha:

		ld		a,1														;cambia el paso para la siguiente
		ld		(iy+5),a

		ld		a,27*4													;define los sprites adecuados
		ld		b,a
		ld		a,25*4
		jr.		ultimas_variables_bombero

cambia_la_direccion_bombero:		

		ld		a,(iy+6)												;mira cual es la direccion actual para cambiarla
		or		a
		jr.		z,cambia_a_izquierda

cambia_a_derecha:

		xor		a														;cambia a derecha
		ld		(iy+6),a
		
		pop		af
		ld		(pantalla_activa),a
				
		ret
		
cambia_a_izquierda:

		ld		a,1														;cambia a izquierda
		ld		(iy+6),a
		
		pop		af
		ld		(pantalla_activa),a
		
		ret

hacia_donde_quiero_ir:

		ld		a,(py)													;si prota está por encima querrá subir y si está por debajo querrá bajar
		sub		3
		ld		b,a
		ld		a,(iy+1)
		cp		b
		
		jr.		c,damos_valor_bajada_bombero
		
		ld		a,(py)													;si prota está por encima querrá subir y si está por debajo querrá bajar
		add		3
		ld		b,a
		ld		a,(iy+1)
		cp		b
		
		jr.		nc,damos_valor_subida_bombero
		
		xor		a
		ld		(iy+10),a
				
		ret

bombero_cambia_de_pantalla:

		ld		a,(iy+12)
		cp		2
		jr.		nz,bombero_cambia_de_pantalla_a_2

bombero_cambia_de_pantalla_a_1:

		ld		a,1
		ld		(iy+12),a
		ld		(pantalla_activa),a
		ld		a,238
		ld		(iy),a
				
		ret

bombero_cambia_de_pantalla_a_2:

		ld		a,2
		ld		(iy+12),a
		ld		(pantalla_activa),a
		ld		a,4
		ld		(iy),a
				
		ret
				
damos_valor_bajada_bombero:
				
		ld		a,2														; le damos valor a la variable adecuada de bajada
		ld		(iy+10),a
				
		ret

damos_valor_subida_bombero:

		ld		a,1														; le damos valor a la variable adecuada de subida
		ld		(iy+10),a
				
		ret

estamos_en_escalera:

		ld		a,(iy+10)
		ld		(iy+7),a
				
		ret
		
ultimas_variables_bombero:
		
		
		ex		af,af'
		pop		af
		push	bc
		ld		(pantalla_activa),a
		ld		b,a
		ld		a,(iy+12)
		cp		b
		jr.		nz,bombero_variables_anuladas
		
		ex		af,af'
		pop		bc
		
		ld		ix,atributos_sprite_general
		
		ld		(ix+18),a												;patrones
		add		4
		ld		(ix+22),a
		ld		(ix+26),b
		
		ld		a,(iy+1)												;y
		ld		(ix+16),a
		sub		a,6
		ld		(ix+20),a
		add		a,16
		ld		(ix+24),a
ultimas_variables_bombero_2:		
		ld		a,(iy)													;x
		ld		(ix+17),a
		ld		(ix+21),a
		ld		(ix+25),a
				
		ld		a,1														;colores_1
		ld		(ix+19),a
		ld		a,9
		ld		(ix+23),a
		ld		a,10
		ld		(ix+27),a
				
		ret

bombero_variables_anuladas:
		
		ex		af,af'
		pop		bc
		
		ld		ix,atributos_sprite_general
		
		ld		a,24*4
		ld		(ix+18),a												;patrones
		ld		(ix+22),a
		ld		(ix+26),a
						
		ret
		
revisa_escalera:

		ld		a,(escalera_activada)									;si la escalera no ha sido activada, vuelve a la rutina
		or		a
		ret		z
		
		ld		a,(contador_escalera)
		dec		a
		ld		(contador_escalera),a
		ld		a,(contador_escalera)
		or		a
		ret		nz
		
		ld		a,50
		ld		(contador_escalera),a

		ld		hl,(posicion_escalera)
		
		ld		a,(pantalla_escalera)
		cp		1
		jr.		nz,revisa_escalera_pantalla_2
		
		ld		de,buffer_colisiones
		jr.		revisa_escalera_continua
		
revisa_escalera_pantalla_2:

		ld		de,buffer_colisiones_2
		
revisa_escalera_continua:
			
		add		hl,de													;hl=buffer_colisiones + posicion escalera
		ld		bc,32
		sbc		hl,bc
		ld		a,43
		ld		[hl],a
		inc		hl
		ld		a,44
		ld		[hl],a
		ld		bc,31
		adc		hl,bc		
		ld		a,41
		ld		[hl],a
		inc		hl
		ld		a,42
		ld		[hl],a

		ld		a,(pantalla_activa)
		ld		b,a
		ld		a,(pantalla_escalera)
		cp		b
		jr.		nz,revisa_escalera_continua_2
				
		ld		hl,(posicion_escalera)
		ld		a,43
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		inc		hl
		ld		a,44
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		ld		bc,32
		adc		hl,bc
		ld		a,41
		call	pinta_en_pantalla
		
		ld		hl,(posicion_escalera)
		ld		bc,33
		adc		hl,bc
		ld		a,42
		call	pinta_en_pantalla

revisa_escalera_continua_2:
		
		ld		a,12													;efecto de escalera_activada
		call	efecto_sonido	
		
		ld		a,(posicion_escalera)
		ld		b,a
		ld		a,(limite_escalera)
		cp		b
		jr.		z,(se_acabo_la_escalera)
		
		ld		a,(posicion_escalera)
		sub		32
		ld		(posicion_escalera),a
		
		
		ret

se_acabo_la_escalera:

		xor		a
		ld		(escalera_activada),a
		
		ret
		
pulsa_una_tecla:
		
		ld		a,(petiso_que_toca)
		cp		0
		jp		z,pulsa_una_tecla_sigue

		dec		a
		ld		(petiso_que_toca),a
		
		ret
		
pulsa_una_tecla_sigue:
		
		ld		a,6
		call	SNSMAT
		bit		5,a
		jr.		z,pausa_el_juego
		bit		6,a
		jr.		z,musica_off_on
		bit		7,a														
		jr.		z,pasa_fase_con_trampa									
		
		ld		a,7
		call	SNSMAT
		bit		1,a
		jr.		z,una_vida_menos
				
		ret

pasa_fase_con_trampa:													
		
		ld		a,(trampa)												;poner ; para hacer trampa
		or		a														;poner ; para hacer trampa
		ret		z														;poner ; para hacer trampa
				
		dec		a
		ld		(trampa),a
		
		call	activa_mute												
		ld		a,1														
		ld		(pasamos_la_fase),a										
		
		ret																
	
una_vida_menos:
		
		call	activa_mute
		
		ld		a,8														;efecto muerte
		call	efecto_sonido

		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		jr.		repite_fase

musica_off_on:
		
		ld		a,10
		ld		(petiso_que_toca),a
		
		ld		a,(ESTADO_MUSICA)
		or		a
		jp		z,reconectamos_musica
		cp		1
		jp		z,reconectamos_musica_2
		xor		a
		ld		(ESTADO_MUSICA),a
		
		jp		activa_mute
		
reconectamos_musica:

		ld		a,1
		ld		(ESTADO_MUSICA),a
		
		call	activa_musica_fases										;inicia el reproductor de PT3
				
		ret
		
reconectamos_musica_2:

		ld		a,2
		ld		(ESTADO_MUSICA),a
		
		call	activa_musica_menu										;inicia el reproductor de PT3
						
		ret
		
pausa_el_juego:
		
		ld		a,5													;si se puede pulsar, pone el contador para evitar que se vuelva a pulsar
		ld		(petiso_que_toca),a
		
		call	activa_mute

		ld		hl,pause												;anunciamos pausa
		ld		de,#1ae2
		ld		bc,5
		call	GRABAVRAM
		
		ld		a,9														;efecto de pausa
		call	efecto_sonido	
		

		call	SPRITES_PAUSA
		
;		ld		a,100
;		push	af
		
;valor_anadido:
		
;		ld		a,255
		
;retardo_rutina_de_pausa:
		
;		dec		a
;		or		a
;		jr.		nz,retardo_rutina_de_pausa
;		pop		af
;		dec		a
;		push	af
;		or		a
;		jr.		nz,valor_anadido
;		pop		af
		
rutina_de_pausa:
	
		call	mira_si_aprieta_una_tecla
		jr.		Z,reconectamos
		
		ld		bc,10
		ld		(clock),bc
		
animacion_rutina_de_pausa_1:

		ld		ix,atributos_sprite_general
		
		ld		a,[ix]
		sub		5
		ld		[ix+8],a
		add		16
		ld		[ix+4],a
		
		xor		a
		ld		[ix+2],a
		add		4
		ld		[ix+6],a
		add		4
		ld		[ix+10],a

		call	atributos_sprites

animacion_rutina_de_pausa_2:

		halt
		ld		a,(clock)
		dec		a
		ld		(clock),a
		or		a
		jr.		nz,animacion_rutina_de_pausa_2
		
		call	mira_si_aprieta_una_tecla
		jr.		Z,reconectamos
		
		ld		bc,10
		ld		(clock),bc
		
		ld		a,12
		ld		[ix+2],a
		add		4
		ld		[ix+6],a
		add		4
		ld		[ix+10],a

		call	atributos_sprites

animacion_rutina_de_pausa_3:
		
		halt
		ld		a,(clock)
		dec		a
		ld		(clock),a
		or		a
		jr.		nz,animacion_rutina_de_pausa_3
		
		jr. 	rutina_de_pausa

mira_si_aprieta_una_tecla:
		
		ld		a,(petiso_que_toca)
		cp		0
		jp		z,mira_si_aprieta_una_tecla_dos

		dec		a
		ld		(petiso_que_toca),a
		or		11111111b
		ret
		
mira_si_aprieta_una_tecla_dos:
		
		ld		a,6
		call	SNSMAT
		bit		5,a
				
		ret
		
reconectamos:
		
		ld		a,10
		ld		(petiso_que_toca),a
		
		ld		hl,ladrillos											;recupera los ladrillos borrados
		ld		de,#1ae2
		ld		bc,5
		call	GRABAVRAM
		
		ld		a,9
		ld		[ix+11],a
		
		ld		a,(tiene_objeto)
		cp		1
		jr.		z,reconectamos_bomba
		cp		2
		jr.		z,reconectamos_cuchillo
		halt
		call	SPRITES_PROTA_NORMAL
		
		jr.		reconectamos_sigue
		
reconectamos_bomba:

		call	SPRITES_BOMBA
		jr.		reconectamos_sigue

reconectamos_cuchillo:

		call	SPRITES_CUCHILLO

reconectamos_sigue:
		
		ld		a,9														;efecto de pausa
		call	efecto_sonido
				
		ld		a,(ESTADO_MUSICA)
		cp		2
		jp		z,activa_musica_menu
		cp		1
		jp		z,activa_musica_fases
		
		ret
		
repite_fase:
		
		ld		ix,atributos_sprite_general
				
		call	limpia_sprites
		
		call	activa_musica_muerto
		call	puntuacion_vidas_fase
		call	SPRITES_UNO
		
		ld		a,(vidas_prota)
		or		a
		jr.		z,termina_partida_mal

buscando_la_fase:
		
		ld		a,(fase_en_la_que_esta)
		ld 		de,POINT_de_acceso_a_fases

lista_de_opciones:
		
		dec		a

		ld h,0
		ld l,a
		add hl,hl

		add hl,de														;hl ya esta apungando a la posicion correcta de la tabla
		
		ld e,(hl)														;extraemos la direccion de la etiqueta
		inc hl
		ld d,(hl)
		ex de,hl 														;hl ya tiene la direccion de salto!
		jp (hl)
								
POINT_de_acceso_a_fases:
		
		dw	bloque_sanctuary_1
		dw	bloque_sanctuary_2
		dw	bloque_sanctuary_3
		dw	bloque_sanctuary_4
	
						
termina_partida_mal:
		
		di
 		ld		sp,#F380												; colocmos la pila en esta posicion, que suele ser donde empieza las zona ram que usa el S.O. del MSX. Recuerda que la pila crece hacia abajo así que no pisaremos nada
		ei
		
		call	DISSCR	
		
		di
		
		ld		hl,blanco												;tiles de base de pantalla
		ld		de,#1820
		call	depack_VRAM
		
		ei
		
		LD		a,(idioma)
		or		a
		jr.		z,termina_en_castellano

termina_en_ingles:
		
		ld		hl,game_over											;anunciamos final malo
		ld		de,#198a
		ld		bc,11
		call	GRABAVRAM
		
		ld		hl,continua_i											;f5 continua
		ld		de,#19a9
		ld		bc,14
		call	GRABAVRAM
		
		jr.		termina_partida_mal_continua
		
termina_en_castellano:
		
		ld		hl,se__acabo											;anunciamos final malo
		ld		de,#198a
		ld		bc,11
		call	GRABAVRAM
		
		ld		hl,continua_e											;f5 continua
		ld		de,#19a9
		ld		bc,14
		call	GRABAVRAM
	
termina_partida_mal_continua:
		
		call	ENASCR
		call 	musica_sin_bucle
		
		ld		hl,GAME_OVER-99											;hl ahora vale la direccion donde se encuentra la cancion
		call	PT3_INIT												;inicia el reproductor de PT3
		
		ld		hl,750
		ld		(clock),hl
				
string_para_reiniciar_programa:

		halt
		ld		hl,(clock)
		ld		bc,1		
		sbc		hl,bc
		ld		(clock),hl
		jr.		z,inicio
		
		ld		a,7
		call	SNSMAT
		bit		1,a
		jr.		z,resetea_para_continue
		
		xor		a
		CALL	ONSTRIG
		or		a
		jr.		nz,inicio
		
		ld		a,1
		CALL	ONSTRIG
		or		a
		jr.		z,string_para_reiniciar_programa
		
		jr.		inicio
		
resetea_para_continue:

		call	datos_a_preparar
		
		jr.		repite_fase
inicio:
		
		call	activa_musica_menu
		jr.		MENU

musica_sin_bucle:
		
		di
		ld		a,[PT3_SETUP]											;musica sin bucle
		or		00000001b
		ld		[PT3_SETUP],a
		ei
		ret

musica_con_bucle:
		
		di
		ld		a,[PT3_SETUP]											;musica CON bucle
		and		11111110b
		ld		[PT3_SETUP],a        
		ei
		ret
		
colision_bombero_prota:
		
		ld		a,(inmune_bomb)											;si se ha activado el huevo adecuado, no hay colision
		cp		1
		ret		z
				
		ld		a,(bombero_1)											;si no está activo, no hay colision
		or		a
		ret		z
		
		ld	    iy,bombero_control										

		ld		a,(iy+8)												;si no está a vista, no hay colision
		or		a
		ret		nz

		
		call	coteja_colision_prota_bombero
		ld		a,(colision_bombero_prota_real)
		or		a
		ret		z
		
		xor		a
		ld		(colision_bombero_prota_real),a		
		
		ld		ix,atributos_sprite_general
					
		ld		a,(iy+1)												;posiciones y
		dec		a
		call	CERO_CUATRO_OCHO
		inc		a
		ld		(ix+16),a
		sub		6
		ld		(ix+8),a
		add		16
		ld		(ix+20),a
		
		ld		a,(iy)													;patrones x
		sub		8
		call	UNO_CINCO_NUEVE
		add		13
		ld		(ix+17),a
		ld		(ix+21),a
		ld		(ix+9),a		
		ld		a,59*4													;patrones
		call	DOS_SEIS_DIEZ
		ld		a,31*4
		ld		(ix+18),a
		ld		a,32*4
		ld		(ix+10),a
		ld		a,45*4
		ld		(ix+22),a
		
		ld		a,9														;colores
		ld		(ix+3),a												;cara prota
		ld		(ix+11),a												;cara bombero
		ld		a,1
		ld		(ix+19),a												;contorno bombero
		ld		a,15
		ld		(ix+7),a												;agua
		ld		a,10
		ld		(ix+23),a												;ropa bombero
				
		jr.		espera_por_muerte

muy_mojado_fin_partida:

		call	moja_prota
		ld		a,1
		ld		(muerto),a
		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		jr.		espera_por_muerte
		
colisiones_serpientes_prota_1:

		ld		a,(inmune_serp)
		cp		1
		ret		z
		
		ld		a,(serp1)
		or		a
		jr.		z,colisiones_serpientes_prota_2
		cp		3
		jr.		z,colisiones_serpientes_prota_2
		
		ld		iy,variables_serpiente_1								;está en la misma pantalla?
		call	comun_colision_serpentes_1
		jr.		nz,colisiones_serpientes_prota_2		
				
		call	comun_colision_serpentes_2

		jr.		z,colisiones_serpientes_prota_2
		
		call	comun_colision_serpentes_3
		ld		(ix+18),b
		ld		(ix+22),a	
		
comunes_muerte_por_serpiente:			
		
		ld		a,(iy+1)
		call	CERO_CUATRO_OCHO
		
		ld		a,(iy)
		call	UNO_CINCO_NUEVE
		
		ld		a,47*4
		call	DOS_SEIS_DIEZ
		
		ld		a,49*4
		ld		(ix+6),a
		
		ld		a,50*4
		ld		(ix+10),a
		
		
		ld		a,1
		ld		(ix+3),a
				
espera_por_muerte:

		call	atributos_sprites
	
		call	activa_mute
	
		ld		a,8						;efecto sonoro de muerte de prota
		call	efecto_sonido		
		
		xor		a
		ld		(muerto),a
		
		ld		hl,150
		ld		(clock),hl						
		jp		rutina_de_esperar_un_rato

comun_colision_serpentes_1:

		ld		a,(iy+9)												
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		
		ret

comun_colision_serpentes_2:
		
		call	coteja_colision_prota_serpiente
		ld		a,(colision_cuchillo_serp_real)
		or		a
		
		ret

comun_colision_serpentes_3:

		xor		a
		ld		(colision_cuchillo_serp_real),a		
		
		ld		ix,atributos_sprite_general
		
		ld		a,48*4
		ld		b,a
		ld		a,24*4
		
		ret
				
colisiones_serpientes_prota_2:

		ld		a,(serp2)
		or		a
		jr.		z,colisiones_serpientes_prota_3
		cp		3
		jr.		z,colisiones_serpientes_prota_3
		
		ld		iy,variables_serpiente_2								;está en la misma pantalla?
		call	comun_colision_serpentes_1
		jr.		nz,colisiones_serpientes_prota_3
		
		call	comun_colision_serpentes_2
		jr.		z,colisiones_serpientes_prota_3
		
		call	comun_colision_serpentes_3

		ld		(ix+26),b
		ld		(ix+30),a
						
		jr.		comunes_muerte_por_serpiente

colisiones_serpientes_prota_3:
		
		ld		a,(serp3)
		or		a
		jr.		z,colisiones_serpientes_prota_4
		cp		3
		jr.		z,colisiones_serpientes_prota_4
				
		ld		iy,variables_serpiente_3								;está en la misma pantalla?
		call	comun_colision_serpentes_1
		jr.		nz,colisiones_serpientes_prota_4
		
		ld		iy,variables_serpiente_3
	
		call	comun_colision_serpentes_2

		jr.		z,colisiones_serpientes_prota_4
		
		call	comun_colision_serpentes_3

		ld		(ix+34),b
		ld		(ix+38),a

		jr.		comunes_muerte_por_serpiente
		
colisiones_serpientes_prota_4:
		
		ld		a,(serp4)
		or		a
		ret		z
		cp		3
		ret		z
				
		ld		iy,variables_serpiente_4								;está en la misma pantalla?
		call	comun_colision_serpentes_1
		ret		nz
				
		call	comun_colision_serpentes_2

		ret		z
		
		call	comun_colision_serpentes_3

		ld		(ix+42),b
		ld		(ix+46),a
	
		jr.		comunes_muerte_por_serpiente

coteja_colision_prota_serpiente:

		ld		a,(pantalla_activa)
		ld		b,a
		ld		a,(iy+9)
		cp		b
		ret		nz
		
		ld		a,(px)
		sub		a,7														;coordenadas coincidentes
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		c
		
		ld		a,(px)
		add		a,10
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		ld		a,(py)
		sub		a,14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		c
		
		ld		a,(py)
		add		14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		nc
		
		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(colision_cuchillo_serp_real),a
		
		ret

coteja_colision_prota_bombero:
		
		ld		iy,bombero_control
		
		ld		a,(pantalla_activa)										;si no están en la misma pantalla, no hay colision
		ld		b,a
		ld		a,(iy+12)
		cp		b
		ret		nz
		
		ld		a,(px)													;coordenadas coincidentes
		cp		7
		jr.		c,coteja_colision_prota_bombero_menos_siete
		sub		a,7				
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		c
		jr.		coteja_colision_prota_bombero_sigue

coteja_colision_prota_bombero_menos_siete:

		xor		a
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		c

coteja_colision_prota_bombero_sigue:
		
		ld		a,(px)
		add		a,10
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		ld		a,(py)
		sub		a,14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		c
		
		ld		a,(py)
		add		14
		ld		b,a
		ld		a,(iy+1)
		cp		b
		ret		nc
		
		ld		a,(vidas_prota)
		dec		a
		ld		(vidas_prota),a
		
		ld		a,1
		ld		(colision_bombero_prota_real),a
		
		ret
		
colisiones_serpientes_cuchillos_comun_1:

		ld		a,(iy+9)
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		
		ret
colisiones_serpientes_cuchillos_comun_2:

		call	colision_cuchillo_serpiente
		ld		a,(colision_cuchillo_serp_real)
		or		a
		
		ret
colisiones_serpientes_cuchillos_comun_3:

		ld		ix,atributos_sprite_general
					
		xor		a
		ld		(colision_cuchillo_serp_real),a
		ld		a,3
		
		ret
				
colisiones_serpientes_cuchillos:

		ld		a,(momento_lanzamiento)									;mira si es posible que el cuchillo este volando
		cp		2
		ret		c
				
		ld		a,(serp1)												;¿está activa la sepriente 1?
		or		a
		jr.		z,colision_cuchillo_serp_2
		cp		3
		jr.		z,colision_cuchillo_serp_2
		
		ld		iy,variables_serpiente_1
		
		call	colisiones_serpientes_cuchillos_comun_1
		jr.		nz,colision_cuchillo_serp_2
		
colision_cuchillo_serp_1:
			
		call	colisiones_serpientes_cuchillos_comun_2
		jr.		z,colision_cuchillo_serp_2
		
		call	colisiones_serpientes_cuchillos_comun_3
		ld		(serp1),a

						
colision_cuchillo_serp_2:

		ld		a,(serp2)												;¿está activa la sepriente 1?
		or		a
		jr.		z,colision_cuchillo_serp_3
		cp		3
		jr.		z,colision_cuchillo_serp_3
		
		ld		iy,variables_serpiente_2
		
		call	colisiones_serpientes_cuchillos_comun_1
		jr.		nz,colision_cuchillo_serp_3
						
		call	colisiones_serpientes_cuchillos_comun_2
		jr.		z,colision_cuchillo_serp_3
		
		call	colisiones_serpientes_cuchillos_comun_3
		ld		(serp2),a
										
colision_cuchillo_serp_3:

		ld		a,(serp3)												;¿está activa la sepriente 1?
		or		a
		jr.		z,colision_cuchillo_serp_4
		cp		3
		jr.		z,colision_cuchillo_serp_4
		
		ld		iy,variables_serpiente_3
		
		call	colisiones_serpientes_cuchillos_comun_1
		jr.		nz,colision_cuchillo_serp_4
		
		call	colisiones_serpientes_cuchillos_comun_2
		jr.		z,colision_cuchillo_serp_4
		
		call	colisiones_serpientes_cuchillos_comun_3
		ld		(serp3),a
				
colision_cuchillo_serp_4:

		ld		a,(serp4)												;¿está activa la sepriente 1?
		or		a
		ret		z
		cp		3
		ret		z
		
		ld		iy,variables_serpiente_4
		
		call	colisiones_serpientes_cuchillos_comun_1
		ret		nz
		
		call	colisiones_serpientes_cuchillos_comun_2
		ret		z
		
		call	colisiones_serpientes_cuchillos_comun_3
		ld		(serp4),a
		
		ret

colision_cuchillo_serpiente:
		
		ld		a,(pantalla_cuchillo)
		ld		b,a
		ld		a,(iy+9)
		ret		nz
					
		ld		a,(cx)													;coordenadas coincidentes
		ld		b,a
		ld		a,(iy)
		cp		b
		ret		nc
		
		add		a,16
		cp		b
		ret		c
	
		ld		a,(cy)
		ld		b,a
		ld		a,(iy+1)
		sub		4
		cp		b
		ret		nc
				
		add		a,20
		cp		b
		ret		c
						
		xor		a
		ld		(momento_lanzamiento),a
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
				
		ld		a,[cx]													;recupera lo que habia en el tile anteriormente					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
				
		ld		a,7														;efecto sonoro de muerte
		call	efecto_sonido	
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,colision_cuchillo_serpiente_continua
		
		ld		a,[cx]													;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla

colision_cuchillo_serpiente_continua:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger mechero
		add		a,25
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,1
		ld		(colision_cuchillo_serp_real),a
		xor		a

		ret
		
atributos_sprites:

		ld		hl,atributos_sprite_general
		ld		de,#1B00
		ld		bc,48
		jp		GRABAVRAM		
		
estado_en_que_se_encuentra:

		call	seis_dos
		call	get_bloque_en_X_Y
		cp		45														;si esta en la salida revisamos si sale
		jr.		z,fase_superada
		
		ld		a,(estado_de_salto)										;no salta? vamos a comprovar si hace algo
		or		a
		jr.		z,continua_estado

		cp		3														;diferentes estados de salto
		jr.		c,salta_sube
		cp		19
		jr.		c,salta_sigue
		cp		21
		jr.		c,salta_baja
		cp		33
		jr.		c,salta_sube_izquierda
		cp		49
		jr.		c,salta_sigue_izquierda
		cp		51
		jr.		c,salta_baja_izquierda
		
continua_estado:		
		
		ld		a,(estado_prota)
		cp		4
		ret		z
				
		call	ocho_dieciocho
		call	get_bloque_en_X_Y
		
		cp		41														;no cae si hay escalera
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		42
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		73
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		74
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		cp		101
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		
		ld		a,[px]
		add		10
		ld		d,a
		ld		a,[py]
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,cambio_estado_a_subiendo_para_la_caida
		
		ld		a,[px]
		add		5
		ld		d,a	
		ld		a,[py]
		add		16
		ld		e,a
;		call	siete_dieciseis
		call	get_bloque_en_X_Y
		
		cp		31														;controla el bloque de ladrillos
		jr.		nc,segunda_comprovacion_caida
		
		ld		a,[px]
		add		7
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		
;		cp		31														;controla el bloque de ladrillos para no quedarse encallado en él
;		jr.		nc,final_rutina_sin_caida
		
;		ld		a,[py]
;		dec		a
;		ld		[py],a
		
		jr.		final_rutina_sin_caida

cambio_estado_a_subiendo_para_la_caida:

		ld		a,4
		ld		(estado_prota),a
		ret		
		
segunda_comprovacion_caida:
			
		ld		a,[px]
		add		11
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		nc,caigo

final_rutina_sin_caida:
		
		xor		a
		ld		(estado_prota),a
			
		ret

ultima_rectificacion_de_caida:

		xor		a
		ld		(estado_prota),a
		ld		a,(py)
		dec		a
		ld		(py),a
		
		ret
		
caigo:
		
		ld		a,3
		ld		(estado_prota),a
		
		ld		a,(py)
		add		a,2
		ld		(py),a
		
			
		ld		a,[px]
		add		8
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		call	get_bloque_en_X_Y
		cp		32
		jr.		c,ultima_rectificacion_de_caida
		
		ld		a,[px]													;observa si hay que rectificar la caida
		add		15
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		c,rectifico_caida_a_izquierda
		
		ld		a,[px]
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		jr.		c,rectifico_caida_a_derecha
		
		ret

rectifico_caida_a_izquierda:
		
		ld		a,[px]
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		ret		c
		
		ld		a,(px)
		dec		a
		ld		(px),a
		ret

rectifico_caida_a_derecha:

		ld		a,(px)
		inc		a
		ld		(px),a
		ret
				
mueve_prota:

		ld		a,(estado_prota)										;si esta en callendo no se mueve
		cp		3
		ret		z
		ld		a,(estado_de_salto)										;si esta saltando no se mueve
		or		a
		ret		nz
		ld		a,(momento_lanzamiento) 								;si está lanzando no se mueve
		cp		1
		ret		z
		cp		2
		ret		z
		ld		a,(puede_cambiar_de_direccion)							;si está en una puerta no puede moverse por su cuenta
		or		a
		ret		z
		
		xor		a

stick_mando:	

		ld		(sticky),a
		call	ONSTICK
		
		or		a
		jr.		z,stick_mando_2
		cp		1
		jr.		z,sube_escaleras
		cp		5
		jr.		z,baja_escaleras	
		cp		5
		jr.		c,mueve_derecha_prota
		cp		9
		jr.		c,mueve_izquierda_prota

stick_mando_2:
		
		ld		a,(sticky)
		cp		1
		ret		z
		ld		a,1
		jr.		stick_mando
			
sube_escaleras:

		push	af
		
		
		ld		a,[px]
		add		6
		ld		d,a
		ld		a,[py]
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,sube_escaleras_afirmativo
		cp		42
		jr.		z,sube_escaleras_afirmativo
		cp		103
		jr.		z,sube_escaleras_afirmativo
		cp		105
		jr.		z,sube_escaleras_afirmativo
		cp		106
		jr.		z,sube_escaleras_afirmativo
		
		ld		a,[px]
		add		9
		ld		d,a
		ld		a,[py]
		sub		2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,sube_escaleras_afirmativo
		
		call	seis_diez
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,sube_escaleras_afirmativo
		
		
		ld		a,[px]
		add		10
		ld		d,a
		ld		a,[py]
		add		1
		ld		e,a
		call	get_bloque_en_X_Y
		cp		101
		jr.		z,sube_escaleras_afirmativo
		
		jr.		set_parado
		
sube_escaleras_afirmativo:

		call	menos_uno_cero
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_izquierda
		cp		103
		jr.		z,a_mover_a_la_izquierda
		cp		101
		jr.		z,a_mover_a_la_izquierda
		cp		105
		jr.		z,a_mover_a_la_izquierda
		
		jr.		comprueba_derecha

a_mover_a_la_izquierda:
		
		ld		a,[px]
		dec		a
		ld		[px],a
		jr.		a_subir
		
comprueba_derecha:

		ld		a,[px]
		add		16
		ld		d,a
		ld		a,[py]
		ld		e,a
		call	get_bloque_en_X_Y
		cp		42
		jr.		z,a_mover_a_la_derecha
		cp		101
		jr.		z,a_mover_a_la_derecha
		cp		105
		jr.		z,a_mover_a_la_derecha
		jr.		a_subir

a_mover_a_la_derecha:
		
		ld		a,[px]
		inc		a
		ld		[px],a
				
a_subir:

		ld		a,4														;le da el valor 4 a la variable estado prota
		ld		(estado_prota),a
		
		ld		a,(py)
		dec		a
		ld		(py),a
		jr.		actualiza_el_paso_subiendo

baja_escaleras:

		push	af
		
		
		ld		a,[px]
		add		6
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		cp		33
		jr.		nc,baja_escaleras_afirmativo
		ld		a,[px]
		add		6
		ld		d,a
		ld		a,[py]
		add		16
		ld		e,a
		call	get_bloque_en_X_Y
		cp		33
		jr.		nc,baja_escaleras_afirmativo
		jr.		set_parado
		
baja_escaleras_afirmativo:

		call	menos_uno_dieciseis
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		103
		jr.		z,a_mover_a_la_izquierda_bajando
		cp		105
		jr.		z,a_mover_a_la_izquierda_bajando
		
		jr.		comprueba_derecha_bajando

a_mover_a_la_izquierda_bajando:
		
		ld		a,[px]
		dec		a
		ld		[px],a
		jr.		a_bajar
		
comprueba_derecha_bajando:

		call	dieciseis_dieciseis
		call	get_bloque_en_X_Y
		cp		42
		jr.		z,a_mover_a_la_derecha_bajando
		cp		101
		jr.		z,a_mover_a_la_derecha_bajando
		cp		103
		jr.		z,a_mover_a_la_derecha_bajando
		cp		106
		jr.		z,a_mover_a_la_derecha_bajando

		
		jr.		a_bajar

a_mover_a_la_derecha_bajando:
		
		ld		a,[px]
		inc		a
		ld		[px],a
				
a_bajar:

		ld		a,4														;le da el valor 4 a la variable estado prota
		ld		(estado_prota),a
		
		ld		a,(py)
		inc		a
		ld		(py),a
		jr.		actualiza_el_paso_subiendo
				
mueve_izquierda_prota:

		ld		a,1
		ld		(dir_prota),a
		
		ld		a,[px];													;controla_si_cambia_de_pantalla
		cp		1
		jr.		c,a_pantalla_1
		
		push	af
		
		;colision lateral con solido
				
		ld		a,[px]
		add		3
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		32														;hasta el 31 son solidos
		jr.		c,set_parado											;si es inferior, no hay acarreo 
		cp		113														;se para ante las puertas de pinchos
		jr.		z,set_parado
		cp		115
		jr.		z,set_parado
		
		call	tres_quince
		call	get_bloque_en_X_Y
		cp		114														;gira las puertas
		jr.		z,gira_puerta_izquierda_amarilla
		cp		116
		jr.		z,gira_puerta_izquierda_azul
		
		ld		a,1														;le da el valor 1 a la variable de estado prota
		ld		(estado_prota),a
				
		ld		a,(px)
		dec		a
		ld		(px),a
		ld		a,1
		ld		(dir_prota),a
		jr.		actualiza_el_paso

actualiza_el_paso_subiendo:

		ld		a,(retard_anim)
		inc		a
		cp		8
		jr		z,reset_retardo_y_cambia_paso_subiendo
		ld		(retard_anim),a
		jr.		end

reset_retardo_y_cambia_paso_subiendo:

		xor		a
		ld		(retard_anim),a
		ld		a,(paso)
		cpl								;le da la vuelta a todos los bits
		and		00000011b				;pone 1 en los dos primero, con lo que lo convierte en un 3 (01=1 10=2 11=3)
		ld		(paso),a
		jr.		end
		
gira_puerta_derecha_amarilla:
		
		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	catorce_dos
		call	get_bloque_en_X_Y
		ld		a,117
		ld		[hl],a
								
		call	catorce_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,117
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		
		pop		af
		
		ret
		
gira_puerta_izquierda_amarilla:

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	tres_dos
		call	get_bloque_en_X_Y
		
		ld		a,117
		ld		[hl],a
								
		call	tres_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		call	tres_quince
		call	get_bloque_en_X_Y
		
		ld		a,117
		ld		[hl],a
								
		call	tres_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,117
		call	pinta_en_pantalla
		
		pop		af
		
		ret
		
gira_puerta_derecha_azul:

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	catorce_dos
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	catorce_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
				
		ld		a,118
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		
		pop		af
		
		ret
		
gira_puerta_izquierda_azul:	

		xor		a
		ld		(puede_cambiar_de_direccion),a
		
		call	tres_dos
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	tres_dos
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
		
		call	tres_quince
		call	get_bloque_en_X_Y
		
		ld		a,118
		ld		[hl],a
								
		call	tres_quince
		call	get_bloque_en_X_Y_paravram
		
		ld		a,118
		call	pinta_en_pantalla
			
		pop		af
		
		ret

a_pantalla_2:

		call	limpia_sprites											;quitamos sprites de en medio
			
		ld		a,2														;activa la pantalla 2
		ld		(px),a
		ld		(pantalla_activa),a
		
		ld		a,(vision_estado)										;si no hay luz no pinta pantalla, sólo el mando y lo que se tercie
		or		a
		jr.		z,pinta_mando_de_luz_pantalla_2
		
		ld		hl,buffer_colisiones_2									;copia en vram para que lo vea el jugador
		ld		de,#1820
		ld		bc,736
		call	GRABAVRAM
		
		ret

a_pantalla_1:

		call	limpia_sprites
		
		ld		a,243
		ld		(px),a
		ld		a,1
		ld		(pantalla_activa),a
		
		ld		a,(vision_estado)
		or		a
		jr.		z,pinta_mando_de_luz_pantalla_1
		
		ld		hl,buffer_colisiones									;copia en vram para que lo vea el jugador
		ld		de,#1820
		ld		bc,736
		jp		GRABAVRAM

pinta_mando_de_luz_pantalla_1:

		ld		a,(fase_en_la_que_esta)
		cp		10
		jr.		z,cosas_a_pintar_en_pantalla_10_1
		cp		11
		jr.		z,cosas_a_pintar_en_pantalla_11_1
		
		ret	

cosas_a_pintar_en_pantalla_10_1:
		
		call	DISSCR
		
		di
		call	setrompage0
				
		ld		hl,paso_negro_izq
		ld		de,#1820
		call	depack_VRAM
			
		call	recbios
		ei
			
		ld		a,93
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		de,#1aa1
		ld		bc,1
		call	GRABAVRAM
		
		jp		ENASCR

cosas_a_pintar_en_pantalla_11_1:
		
		call	DISSCR
		
		di
		call	setrompage0
			
		ld		hl,paso_negro_izq
		ld		de,#1820
		call	depack_VRAM
				
		call	recbios
		ei
		
		ld		a,64
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		de,#1a41
		ld		bc,1
		call	GRABAVRAM
		
		jp		ENASCR

pinta_mando_de_luz_pantalla_2:

		ld		a,(fase_en_la_que_esta)
		cp		10
		jr.		z,cosas_a_pintar_en_pantalla_10_2
		cp		11
		jr.		z,cosas_a_pintar_en_pantalla_11_2
		
		ret
		
cosas_a_pintar_en_pantalla_10_2:
		
		call	DISSCR
		
		di
		call	setrompage0
		
		
		di
		ld		hl,paso_negro_izq
		ld		de,#1820
		call	depack_VRAM
		
				
		call	recbios
		ei
		
		ld		a,64
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		de,#1aa1
		ld		bc,1
		call	GRABAVRAM
		
		jp		ENASCR

cosas_a_pintar_en_pantalla_11_2:
		
		call	DISSCR
		
		di
		call	setrompage0
		
		
		di
		ld		hl,paso_negro_izq
		ld		de,#1820
		call	depack_VRAM
			
		call	recbios
		ei
		
		ld		a,93
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mando de la luz
		ld		de,#1a41
		ld		bc,1
		call	GRABAVRAM
		
		jp		ENASCR
			
mueve_derecha_prota:

		xor		a
		ld		(dir_prota),a
		
		ld		a,[px];													;controla_si_cambia_de_pantalla
		add		12
		cp		255
		jr.		nc,a_pantalla_2

		push	af				

		ld		a,[px]													;colision lateral con solido
		add		12
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		cp		32														;hasta el 31 son solidos
		jr.		c,set_parado											;si es inferior, no hay acarreo 
		cp		114														;se para ante las puertas de pinchos
		jr.		z,set_parado
		cp		116
		jr.		z,set_parado
				
		call	doce_diez
		call	get_bloque_en_X_Y
		cp		113														;gira las puertas
		jr.		z,gira_puerta_derecha_amarilla
		cp		115
		jr.		z,gira_puerta_derecha_azul
		
		ld		a,1														;le da el valor 1 a la variable de estado prota
		ld		(estado_prota),a
				
		ld		a,(px)
		inc		a
		ld		(px),a

actualiza_el_paso:

		ld		a,(retard_anim)
		inc		a
		cp		8
		jr		z,reset_retardo_y_cambia_paso
		ld		(retard_anim),a
		jr.		end

reset_retardo_y_cambia_paso:

		xor		a
		ld		(retard_anim),a
		ld		a,(paso)
		cpl																;le da la vuelta a todos los bits
		and		00000011b												;pone 1 en los dos primero, con lo que lo convierte en un 3 (01=1 10=2 11=3)
		ld		(paso),a
		jr.		end
		


actualiza_atributos_sprite:
		
		ld		ix,atributos_sprite_general
		
		ld		a,(py)													;valor y**
		ld		(ix),a
		add		a,9														;aquí controlamos la posicion de los sprites que se catrapean
		ld		(ix+4),a
		sub		a,16
		ld		(ix+8),a
		
		ld		a,(px)													;valor x**
		call	UNO_CINCO_NUEVE
			
		ld		a,(estado_prota)
		cp		4
		jr.		z,esta_subiendo_o_bajando_para_el_patron

		ld		a,(estado_prota)
		cp		2
		jr.		z,esta_cayendo_para_el_patron
				
		call	ocho_uno
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,esta_subiendo_o_bajando_para_el_patron
		
		ld		a,(estado_prota)
		cp		3
		jr.		z,esta_cayendo_para_el_patron
		
		ld		a,(dir_prota)											;valor de la direccion
		or		a
		jr		nz,mirando_izquierda
		
		ld		a,(momento_lanzamiento)									;mira si está lanzando
		cp		1
		jr.		z,lanza_derecha_1
		cp		2
		jr.		z,lanza_derecha_2
		
		ld		b,0*4													;mirando derecha
		jr		mirar_paso

lanza_derecha_1:
		
		ld		a,33*4													;mirando derecha pose 1 de lanzamiento
		jr.		ultimos_valores
		
lanza_derecha_2:
		
		ld		a,36*4													;mirando derecha pose 2 de lanzamiento
		jr.		ultimos_valores
		
mirando_izquierda:

		ld		a,(momento_lanzamiento)
		cp		1
		jr.		z,lanza_izquierda_1
		cp		2
		jr.		z,lanza_izquierda_2
		
		ld		b,6*4													;mirando izquierda
		jr.		mirar_paso
		
lanza_izquierda_1:

		ld		a,39*4													;mirando izquierda pose 1 de lanzamiento
		jr.		ultimos_valores
		
lanza_izquierda_2:

		ld		a,42*4													;mirando izquierda pose 2 de lanzamiento
		jr.		ultimos_valores
		
mirar_paso:
		
		ld		a,(estado_de_salto)										;paso abierto si esta saltando
		or		a
		jr.		z,todo_va_bien
		
		ld		a,3
[2]		sla		a
		add		a,b
		
		jr.		ultimos_valores
		
todo_va_bien:		
		ld		a,(paso)
[2]		sla		a														;multiplica x2 2 veces
		add		a,b														;le damos el patron definitivo

ultimos_valores:
		
		ld		ix,atributos_sprite_general
		
		call	DOS_SEIS_DIEZ
		
		ld		a,(color_lineas_prota)									;valor color**
		ld		(ix+3),a
		ld		a,(color_prota)
		ld		(ix+7),a
		ld		a,9
		ld		(ix+11),a
		
		ret

esta_cayendo_para_el_patron:

		ld		b,18*4
		ld		a,b
		jr.		ultimos_valores
		
esta_subiendo_o_bajando_para_el_patron:	

		ld		b,12*4
		jr.		mirar_paso
		
end:

		xor		a
		ld		[prev_dir_prota],a
		
		pop		af
		ret
		
set_parado:

		xor		a
		ld		[estado_prota],a
		jr.		end

get_bloque_en_X_Y:
																		;				(y/8)*32+(x/8)
		ld		a,e														;a=y
[3]		srl		a														;a=y/8
		ld		h,0
		ld		l,a														;hl=y/8
[5]		add		hl,hl													;*32			a=(y/8)*32
		
		ld		a,d														;a=x
[3]		srl		a														;a=x/8
		ld		d,0
		ld		e,a														;de=x/8
		add		hl,de													;hl=(y/8)*32+(x/8)

		ld		a,(pantalla_activa)
		cp		1
		jr.		nz,cargando_pantalla_2
		
		ld		de,buffer_colisiones
		jr.		get_bloque_en_X_Y_continua

cargando_pantalla_2:

		ld		de,buffer_colisiones_2
		
get_bloque_en_X_Y_continua:

		add		hl,de													;hl=buffer_colisiones + (y/8)*32+(x/8)
		ld		bc,32
		sbc		hl,bc		
		ld		a,[hl]
				
		ret

get_bloque_en_X_Y_paravram:

		ld		a,e														;a=y
[3]		srl		a														;a=y/8
		ld		h,0
		ld		l,a														;hl=y/8
[5]		add		hl,hl													;*32			a=(y/8)*32
		
		ld		a,d														;a=x
[3]		srl		a														;a=x/8
		ld		d,0
		ld		e,a														;de=x/8
		add		hl,de													;hl=(y/8)*32+(x/8)
		
		ret
		
pone_estado_prota_a_0:

		xor		a
		ld		(estado_prota),a
		
pose_si_esta_parado:
		call	cero_cero
		call	get_bloque_en_X_Y
		cp		41
		jr.		z,esta_en_escalera
		
		ld		a,(estado_prota)
		or		a
		ret		nz
		
		xor		a
		ld		(paso),a

		ret
		
esta_en_escalera:
		
		ld		a,4
		ld		(estado_prota),a
		ret
			
usa_objeto_o_salta:
		
		ld		a,(cont_no_salta_dos_seguidas)							;evita que se pulse el salto durante el salto
		or		a
		jr.		nz,(reduce_el_contador_de_salto)
		
		
		
		ld		a,(estado_de_salto)										;evita el string si ya está saltando
		or		a
		ret		nz
		
		ld		a,(estado_de_explosion)									;evita el string si hay una explosion
		or		a
		ret		nz
		
		ld		a,(momento_lanzamiento)									;evita el string si está lanzando
		cp		1
		ret		z
		cp		2
		ret		z
		
		ld		a,(tiene_objeto)										;si lleva el cuchillo le permitirá tirarlo en puerta o escalera (saltamos las dos siguientes prohibiciones)
		cp		2
		jr.		z,sigue_comprobando
				
		ld		a,(estado_prota)										;Evita string si está en escaleras
		cp		4
		ret		z

		call	dos_diez												;evita que salte si está en escalera
		call	get_bloque_en_X_Y
		cp		41
		ret		z
		cp		41
		ret		z
		cp		105
		ret		z
		cp		106
		ret		z
		cp		101
		ret		z
		cp		103
		ret		z
		
sigue_comprobando:	
			
		xor		a
		call	ONSTRIG
		cp		#FF
		jr.		z,decide_si_usa_o_salta
		
		ld		a,1
		call	ONSTRIG
		cp		#FF
		jr.		z,decide_si_usa_o_salta
				
		ret

reduce_el_contador_de_salto:

		dec		a
		ld		(cont_no_salta_dos_seguidas),a
		ret
		
decide_si_usa_o_salta:

		ld		a,(tiene_objeto)
		cp		1
		jr.		z,usa_bomba
		cp		2
		jr.		z,usa_cuchillo
		
		ld		a,[px]													;no salta si tiene techo (para evitar volar)
		ld		d,a
		ld		a,[py]
		sub		a,2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		31
		ret		c
		
		ld		a,[px]
		add		6														;no salta si esta en una escalera
		ld		d,a
		ld		a,[py]
		add		2
		ld		e,a
		call	get_bloque_en_X_Y
		cp		41
		ret		z
		cp		169
		ret		z
		cp		170
		ret		z
		cp		171
		ret		z
		cp		172
		ret		z

		call	dos_diez												
		call	get_bloque_en_X_Y
		cp		35														;evita que salte si está ante la puerta
		ret		z
		cp		36
		ret		z
		cp		47
		ret		z
		cp		48
		ret		z	

		call	cero_cero
		call	get_bloque_en_X_Y
		cp		33														;si esta en la salida revisamos si sale
		call	z,fase_superada
				
		ld		a,(estado_prota)										;si esta callendo, no salta
		cp		3
		ret		z
				
		jr.		ha_saltado
		
		ret

fase_superada:

		ld		a,(mechero)
		or		a
		ret		z
		
		ld		a,(gasolina)
		or		a
		ret		z
		
		ld		a,(color_prota)
		cp		7
		ret		z
		
		ld		a,1
		ld		(pasamos_la_fase),a
		
		ret

apaga_los_chorros:
	
		call	uno_menos_cuatro
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_encima_tuyo
	
		call 	menos_dos_diez
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_izquierda
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y	
		
		cp		89
		jr.		z,quita_a_tu_izquierda_2
			
		call	catorce_diez
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_derecha
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		
		cp		89
		jr.		z,quita_a_tu_derecha_2
		
		ret
			
quita_a_tu_derecha:

		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	veintidos_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	veintidos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla
		
quita_encima_tuyo:
		
		call	menos_dos_menos_cuatro
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	uno_menos_cuatro
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	nueve_menos_cuatro
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	menos_dos_menos_cuatro
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	uno_menos_cuatro
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	nueve_menos_cuatro
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla
		
quita_a_tu_izquierda:
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	menos_diez_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	menos_diez_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla
		
quita_a_tu_derecha_2:

		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		ld		a,[px]					;borra en buffer_colisiones el chorro						
		add		20
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		ld		a,[px]
		add		22
		ld		d,a
		ld		a,[py]
		add		18
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla

quita_a_tu_izquierda_2:
		
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y
		ld		a,86
		ld		[hl],a
		
		call	menos_diez_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,86
		call	pinta_en_pantalla
		
		call	menos_diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla

coge_algun_objeto:
		
		call	seis_dos
		call	get_bloque_en_X_Y
		
		cp		93														;si toca el interruptor, se da la luz
		jr.		z,damos_la_luz
				
		ld		a,(vision_estado)										;si está oscuro, no podrá coger nada más
		or		a
		ret		z
		
		call	seis_diez

		call	get_bloque_en_X_Y
		
;		cp		168														;si toca pinchos muere
;		jr.		z,muy_mojado_fin_partida

		cp		98
		jr.		z,coge_mechero_por_derecha
		
		cp		97
		jr.		z,coge_gasolina_por_izquierda

		cp		87
		jr.		z,cierra_grifo
		
		cp		107
		jr.		z,coge_toalla
		
		cp		187
		jr.		z,vida_extra
						
		cp		86
		jr.		z,activa_chorro_1
						
		cp		80
		jr.		z,activa_escalera_extra
		
		cp		179
		jr.		z,cierra_los_grifos_de_balsa
		
		cp		177
		jr.		z,quitamos_el_tapon
		
		call	diez_diez
		call	get_bloque_en_X_Y
		
		cp		168														;si toca pinchos muere
		jr.		z,muy_mojado_fin_partida
		
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		cp		86
		jr.		z,activa_chorro_2
		
		call	seis_dos
		call	get_bloque_en_X_Y
		
		cp		174
		jr.		z,muy_mojado_fin_partida
		
		call	seis_diez
		call	get_bloque_en_X_Y
		
		cp		174
		jr.		z,moja_prota
					
		call	seis_dieciocho
		call	get_bloque_en_X_Y
				
		ld		a,(tiene_objeto)
		or		a
		ret		nz
		
		call	seis_diez
		call	get_bloque_en_X_Y
		
		cp		99
		jr.		z,coge_la_bomba
		
		cp		96
		jr.		z,coge_cuchillo
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		cp		98
		jr.		z,coge_mechero_por_derecha
		
		cp		97
		jr.		z,coge_gasolina_por_derecha
				
		ret
		
quitamos_el_tapon:

		ld		a,(grifos_balsa_cerrados)
		cp		1
		ret		z
		
		ld		a,(balsa_bacia)
		or		a
		ret		z
		
		ld		a,(pantalla_balsa)
		cp		1
		jr.		nz,quitamos_el_tapon_en_2

quitamos_el_tapon_en_1:
		
		ld		bc,(posicion_balsa_desde_grifo)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones
		jr.		quitamos_el_tapon_continua

quitamos_el_tapon_en_2:

		ld		bc,(posicion_balsa_desde_grifo)									;pintamos en el buffer adecuado el grifo cerrado
		ld		hl,buffer_colisiones_2

quitamos_el_tapon_continua:

		adc		hl,bc
		ld		bc,29
		adc		hl,bc
		ld		a,32
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
		ld		bc,27
		adc		hl,bc
		ld		[hl],a
		inc		hl
		ld		[hl],a
[2]		inc		hl
		ld		[hl],a
		inc		hl
		ld		[hl],a
[2]		dec		hl
		ld		a,167
		ld		[hl],a

		ld		a,(pantalla_balsa)
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		jr.		nz,quitamos_el_tapon_final
		
		call	copiamos_en_pantalla_lo_de_memoria

quitamos_el_tapon_final:
		
		ld		a,10														;efecto sonoro de grifo de balsa cerrado
		call	efecto_sonido
		
		xor		a
		ld		(balsa_bacia),a
						
		ret
		
cierra_los_grifos_de_balsa:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por cerrar grifo de balsa
		add		a,3
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,(pantalla_tile_grifo_balsa_1)							;decide en que buffer cambia el grifo 1
		cp		2
		jr.		z,cierra_los_grifos_de_balsa_2

cierra_los_grifos_de_balsa_1:
		
		ld		bc,(tile_grifo_balsa_1)									;pintamos en el buffer 1 el grifo cerrado
		ld		hl,buffer_colisiones

		jr.		cierra_los_grifos_de_balsa_3

cierra_los_grifos_de_balsa_2:
	
		ld		bc,(tile_grifo_balsa_1)									;pintamos en el buffer  2 el grifo cerrado
		ld		hl,buffer_colisiones_2
		
cierra_los_grifos_de_balsa_3:

		adc		hl,bc
		ld		bc,33
		sbc		hl,bc
		ld		a,178
		ld		[hl],a

		ld		a,(pantalla_tile_grifo_balsa_2)
		cp		2
		jr.		z,cierra_los_grifos_de_balsa_5

cierra_los_grifos_de_balsa_4:
				
		ld		bc,(tile_grifo_balsa_2)
		ld		hl,buffer_colisiones
		dec		bc
		jr.		cierra_los_grifos_de_balsa_6

cierra_los_grifos_de_balsa_5:

		ld		bc,(tile_grifo_balsa_2)
		ld		hl,buffer_colisiones_2
		
cierra_los_grifos_de_balsa_6:
		
		adc		hl,bc
		ld		bc,32
		sbc		hl,bc
		ld		a,178
		ld		[hl],a

		ld		a,(pantalla_tile_grifo_balsa_1)
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		jr.		nz,cierra_los_grifos_de_balsa_8

cierra_los_grifos_de_balsa_7:
										
		ld		hl,(tile_grifo_balsa_1)									;dibujamos en pantalla el grifo cerrado
		ld		a,178
		call	pinta_en_pantalla

cierra_los_grifos_de_balsa_8:
		
		ld		a,(pantalla_tile_grifo_balsa_2)
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		jr.		nz,cierra_los_grifos_de_balsa_10
				
cierra_los_grifos_de_balsa_9:		

		ld		hl,(tile_grifo_balsa_2)
		ld		a,178
		call	pinta_en_pantalla

cierra_los_grifos_de_balsa_10:
		
		ld		a,16														;efecto sonoro de grifo de balsa cerrado
		call	efecto_sonido
		
		xor		a
		ld		(grifos_balsa_cerrados),a
				
		ret
				
activa_escalera_extra:

		ld		a,1
		ld		(escalera_activada),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,112
		ld		[hl],a
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,112
		call	pinta_en_pantalla
		
		ld		a,10													;efecto sonoro de activar
		jp		efecto_sonido
		
activa_chorro_1:

		ld		a,(grifo_estado)
		or		a
		ret		z
		
		call	menos_dos_diez
		call	get_bloque_en_X_Y
		
		ld		a,88
		ld		[hl],a
								
		call	menos_dos_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,88
		call	pinta_en_pantalla
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,89
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,89
		call	pinta_en_pantalla
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,90
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,90
		call	pinta_en_pantalla
		
		ld		a,11													;efecto sonoro agua (arreglar)
		call	efecto_sonido

		jr.		moja_prota

activa_chorro_2:

		ld		a,(grifo_estado)
		or		a
		ret		z
		
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y
		
		ld		a,88
		ld		[hl],a
								
		call	menos_dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,88
		call	pinta_en_pantalla
		
		call	seis_dieciocho
		call	get_bloque_en_X_Y
		ld		a,89
		ld		[hl],a
								
		call	seis_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,89
		call	pinta_en_pantalla
		
		call	catorce_dieciocho
		call	get_bloque_en_X_Y
		ld		a,90
		ld		[hl],a
								
		call	catorce_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,90
		call	pinta_en_pantalla
		
		ld		a,11													;efecto sonoro agua (arreglar)
		call	efecto_sonido

		jr.		moja_prota
										
moja_prota:

		ld		a,7
		ld		(color_prota),a
		ld		a,4
		ld		(color_lineas_prota),a
		
		ret
				
coge_toalla:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger toalla
		add		a,6
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,108
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,108
		call	pinta_en_pantalla
		
		ld		a,2														;efecto sonoro de toalla cogida
		call	efecto_sonido
		
		ld		a,2														; da valor a la variable para secar al prota
		ld		(color_prota),a
		ld		a,1
		ld		(color_lineas_prota),a
		
		ret

vida_extra:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger toalla
		add		a,10
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,15													;efecto sonoro de vida_extra
		call	efecto_sonido
		
		ld		a,(vidas_prota)											;aumenta la variable de vidas en uno
		inc		a
		ld		(vidas_prota),a
		
		ret
		
cierra_grifo:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger mechero
		add		a,10
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,119
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,119
		call	pinta_en_pantalla
		
		ld		a,10													;efecto sonoro de cerrar grifo
		call	efecto_sonido
		
		xor		a														; da valor a la variable para dar por hecho que el grifo está cerrado
		ld		(grifo_estado),a
		
		ret

coge_mechero_por_derecha:

		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla	
		
coge_mechero_por_izquierda:

		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
								
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla		

coge_mechero:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger mechero
		add		a,50
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		

		
		ld		a,203
		ld		[#eeee],a
		ld		hl,#eeee												;pinta el mechero  a color
		ld		de,#181c
		ld		bc,1
		call	GRABAVRAM
		
		ld		a,2														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1														; da valor a la variable para adeptar que la tienes
		ld		(mechero),a
		
		ret

damos_la_luz:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por dar la luz
		add		a,75
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	seis_dos
		call	get_bloque_en_X_Y
		ld		a,125
		ld		[hl],a
								
		call	copiamos_en_pantalla_lo_de_memoria
		
		ld		a,2														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1
		ld		(vision_estado),a										;damos acceso a los objetos que ya se ven
				
		ret

coge_gasolina_por_derecha:
		
		call	catorce_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
				
		call	catorce_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		jr.		coge_gasolina
		
coge_gasolina_por_izquierda:		
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
				
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
coge_gasolina:	
	
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger gasolina
		add		a,50
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,202													;pinta la gasolina  a color
		ld		de,#181a
		call	pinta_algo_solo
		
		ld		a,2														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1														;da valor a la variable para adeptar que la tienes
		ld		(gasolina),a			
		
		ret

pinta_algo_solo:
		
		ld		[#eeee],a
		ld		hl,#eeee												;pinta la gasolina  a color
		ld		bc,1
		jr.		GRABAVRAM
					
coge_la_bomba:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger la bomba
		add		a,5
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	SPRITES_BOMBA
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		ld		a,[hl]													;borra de pantalla la bomba cogida												
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,204													;pinta la bomba a color
		ld		de,#181e
		call	pinta_algo_solo
		
		xor		a														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,1														; da el valor interno a tiene_objeto
		ld		(tiene_objeto),a
		
		ret

coge_cuchillo:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por coger cuchillo
		add		a,1
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	SPRITES_CUCHILLO
		
		call	seis_diez
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	seis_diez
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		ld		a,209													;pinta la espada a color
		ld		de,#1818
		call	pinta_algo_solo
		
		xor		a														;efecto sonoro de coger
		call	efecto_sonido
		
		ld		a,2														; da el valor interno a tiene_objeto
		ld		(tiene_objeto),a
		
		ret
		
usa_bomba:
		
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		cp		31
		jr.		c,continuamos

		call	segunda_comprovacion_de_agujeros
		
continuamos:

		call	SPRITES_PROTA_NORMAL		
		
		ld		a,(px)													;situamos la explosion
		sub		a,4
		ld		(x_explosion),a
		ld		a,(py)
		add		a,10
		ld		(y_explosion),a
		
		ld		a,207													;pinta la bomba a blanco y negro
		ld		de,#181e
		call	pinta_algo_solo
	
		xor		a
		ld		(tiene_objeto),a
		
		ld		a,1
		ld		(estado_de_explosion),a									;activamos los sprites de explosion
		
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		cp		20
		jr.		nz,continuamos_2

		ld		a,19														;efecto sonoro de bomba fallida
		call	efecto_sonido
		jr.		continuamos_3
		
continuamos_2:
		
		ld		a,3														;efecto sonoro de bomba
		call	efecto_sonido	

continuamos_3:
		
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		cp		20														;si hay suelo irrompible, gasta bomba pero no agujerea
		jr.		z,segunda_comprovacion_de_agujeros
		jr.		c,hace_agujero_1

		cp		23
		jr.		c,hace_agujero_2
		
		cp		25
		jr.		c,hace_agujero_3
		ret

segunda_comprovacion_de_agujeros:

		call	diez_dieciocho 
		call	get_bloque_en_X_Y
		cp		20
		ret		z
		jr.		c,hace_agujero_1_2

		cp		23
		jr.		c,hace_agujero_2_2
	
		cp		25
		jr.		c,hace_agujero_3_2
		ret
hace_agujero_1:
		
		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por perforar suelo
		add		a,5
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
													
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		ld		a,21
		ld		[hl],a
				
		call	dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,21
		call	pinta_en_pantalla		
		
		jr.		segunda_comprovacion_de_agujeros

hace_agujero_1_2:

		call	diez_dieciocho
		call	get_bloque_en_X_Y
		ld		a,22
		ld		[hl],a
		
		call	diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,22
		jp		pinta_en_pantalla
		
hace_agujero_2:

		ld		a,(cuanto_sumamos_a_score)								;puntos ganados por perforar suelo
		add		a,10
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		ld		a,[hl]												;pone en buffer_colisiones el suelo 3										
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		ld		a,23
		ld		[hl],a
				
		call	dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,23
		call	pinta_en_pantalla
		
		jr. 	segunda_comprovacion_de_agujeros
		
hace_agujero_2_2:
		
		call	diez_dieciocho
		call	get_bloque_en_X_Y
		ld		a,24
		ld		[hl],a
		
		call	diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,24
		jp		pinta_en_pantalla

hace_agujero_3:
		
		ld		a,(cuanto_sumamos_a_score)				;puntos ganados por perforar suelo
		add		a,15
		ld		(cuanto_sumamos_a_score),a
		ld		a,1
		ld		(cuenta_puntos_o_no),a
		
		call	dos_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a
		
		call	dos_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		call	diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		call	pinta_en_pantalla
		
		jr.		segunda_comprovacion_de_agujeros
		
hace_agujero_3_2:

		call	diez_dieciocho
		call	get_bloque_en_X_Y
		ld		a,32
		ld		[hl],a

		call	diez_dieciocho
		call	get_bloque_en_X_Y_paravram
		
		ld		a,32
		jp		pinta_en_pantalla
			
usa_cuchillo:

		ld		a,(momento_lanzamiento)
		or		a
		ret		nz
		
		ld		a,208													;pinta el cuchillo a blanco y negro
		ld		de,#1818
		call	pinta_algo_solo
	
		xor		a														;le quita el cuchillo
		ld		(tiene_objeto),a
		
		call	SPRITES_PROTA_NORMAL	
		
		ld		a,(pantalla_activa)
		ld		(pantalla_cuchillo),a		
		ld		a,1														;activa las poses de lanzamiento
		ld		(momento_lanzamiento),a
		
		ret
		
rutina_cuchillo_volador:
		
		ld		a,(momento_lanzamiento)
		or		a
		ret		z
		cp		3						
		jr.		z,comprueba_lugar_cuchillo
		jr.		nc,avanza_cuchillo
		ld		b,a
		ld		a,(contador_poses_lanzar)
		dec		a
		ld		(contador_poses_lanzar),a
		or		a
		ret		nz
		ld		a,5
		ld		(contador_poses_lanzar),a
		ld		a,b
		
		inc		a
		ld		(momento_lanzamiento),a
		
		ret

comprueba_lugar_cuchillo:

		ld		a,6														;efecto sonoro de lanzar
		call	efecto_sonido
				
		ld		a,(dir_prota)											;vemos direccion en la que lanza
		cp		1
		jr.		z,lanzamos_a_la_izquierda

lanzamos_a_la_derecha:

		ld		(dir_cuchillo),a										;guardamos la dirección para poder seguirla con el cuchillo

		call	ocho_cuatro
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		call	get_bloque_en_X_Y
		ld		a,[hl]													;gaurdamos en memoria lo que hay debajo del cuchillo
				
		ld		(recordar_lo_que_habia),a
		ld		a,100													;pintamos el cuchillo
		ld		[hl],a
		
		ex		af,af'
		ld		(pantalla_activa),a	
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,lanzamos_a_la_derecha_final
			
		ld		a,[px]													;a vram
		add		8
		ld		[cx],a
		ld		d,a
		ld		a,[py]
		add		4
		ld		[cy],a
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,100
		call	pinta_en_pantalla

lanzamos_a_la_derecha_final:
		
		ld		a,4														;pasamos el estado a movimiento
		ld		(momento_lanzamiento),a
		
		ret

lanzamos_a_la_izquierda:

		ld		(dir_cuchillo),a										;guardamos la dirección para poder seguirla con el cuchillo
				
		ld		a,[px]					
		add		4
		ld		d,a
		ld		a,[py]
		add		4
		ld		e,a
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		call	get_bloque_en_X_Y
		ld		a,[hl]
		
		ld		(recordar_lo_que_habia),a
		ld		a,102
		ld		[hl],a
		
		ex		af,af'
		ld		(pantalla_activa),a	
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,lanzamos_a_la_izquierda_final
				
		ld		a,[px]													;a vram
		add		4
		ld		[cx],a
		ld		d,a
		ld		a,[py]
		add		4
		ld		[cy],a
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,102
		call	pinta_en_pantalla

lanzamos_a_la_izquierda_final:
		
		ld		a,4														;pasamos el estado a movimiento
		ld		(momento_lanzamiento),a
		
		ret
		
avanza_cuchillo:

		ld		a,(dir_cuchillo)
		cp		1
		jr.		z,avanza_hacia_la_izquierda

avanza_hacia_la_derecha:

		ld		a,[cx]
		cp		250
		call	nc,cuchillo_cambia_a_pantalla_dos						;cambiamos de pantalla
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		ld		a,[cx]
		add		4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,(clava_a_la_derecha)
		
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a

		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,avanza_hacia_la_derecha_continua
								
		ld		a,[cx]													;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
avanza_hacia_la_derecha_continua:				

		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		ld		a,[cx]													;salva lo que hay en el tile destino
		add		4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		ld		(recordar_lo_que_habia),a
		
		ld		[hl],100												;pone el cuchillo en el nuevo tile
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,avanza_hacia_la_derecha_continua_2
		
		ld		a,[cx]
		add		4														;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,100
		call	pinta_en_pantalla

avanza_hacia_la_derecha_continua_2:
							
		ld		a,[cx]													;nuevo valor para las coordenadas x e y
		add		4
		ld		[cx],a
		
		ret		

cuchillo_cambia_a_pantalla_dos:

		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
												
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
		ld		a,2
		ld		(pantalla_cuchillo),a
		
		ld		a,5
		ld		(cx),a
		
		ret
		
clava_a_la_derecha:
		
		ld		a,(recordar_lo_que_habia)								;si está en escalera, tile especial
		cp		42
		jr.		nz,continua_clava_derecha_normal
		
		ld		a,5														;efecto sonoro de clavar
		call	efecto_sonido	
		
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		ld		[hl],106
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,fin_de_secuencia_cuchillo
				
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y_paravram
				
		ld		a,106
		call	pinta_en_pantalla
		
		jr.		fin_de_secuencia_cuchillo
		
continua_clava_derecha_normal:

		ld		a,5														;efecto sonoro de clavar
		call	efecto_sonido	
				
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		ld		[hl],101
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,fin_de_secuencia_cuchillo
		
		ld		a,[cx]													;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,101
		call	pinta_en_pantalla
		
		jr.		fin_de_secuencia_cuchillo
		
avanza_hacia_la_izquierda:

		ld		a,[cx]
		cp		5
		call	c,cuchillo_cambia_a_pantalla_uno						;cambiamos de pantalla
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
							
		ld		a,[cx]													;si en el siguiente tile hay ladrillo, va a clavar
		sub		a,4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		cp		32
		jr.		c,clava_a_la_izquierda
	
		ld		a,[cx]													;recupera lo que habia en el tile anteriormente					
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a

		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,avanza_hacia_la_izquierda_continua
			
		ld		a,[cx]													;recupera tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla

avanza_hacia_la_izquierda_continua:
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		ld		a,[cx]													;salva lo que hay en el tile destino
		sub		a,4
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,[hl]
		ld		(recordar_lo_que_habia),a
		
		ld		[hl],102												;pone el cuchillo en el nuevo tile

		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,avanza_hacia_la_izquierda_continua_2
						
		ld		a,[cx]
		sub		a,4														;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		call	get_bloque_en_X_Y_paravram
		
		ld		a,102
		call	pinta_en_pantalla

avanza_hacia_la_izquierda_continua_2:
							
		ld		a,[cx]													;nuevo valor para las coordenadas x e y
		sub		a,4
		ld		[cx],a
		
		ret

cuchillo_cambia_a_pantalla_uno:

		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		
		ld		a,(recordar_lo_que_habia)
		ld		[hl],a
												
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y_paravram
		
		ld		a,(recordar_lo_que_habia)
		call	pinta_en_pantalla
		
		ld		a,1
		ld		(pantalla_cuchillo),a
		
		ld		a,250
		ld		(cx),a
		
		ret
				
clava_a_la_izquierda:
		
		ld		a,(recordar_lo_que_habia)								;si está en escalera, tile especial
		cp		41
		jr.		nz,continua_clava_izquierda_normal
		
		ld		a,5														;efecto sonoro de clavar
		call	efecto_sonido	
		
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		ld		[hl],105

		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,fin_de_secuencia_cuchillo
				
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y_paravram
				
		ld		a,105
		call	pinta_en_pantalla
		
		jr.		fin_de_secuencia_cuchillo
				
continua_clava_izquierda_normal:

		ld		a,5														;efecto sonoro de clavar
		call	efecto_sonido
		
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y
		ld		[hl],103
		
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		b,a
		ld		a,(pantalla_cuchillo)
		cp		b
		jr.		nz,fin_de_secuencia_cuchillo
		
		
		call	reclamo_posicion_cuchillo
		call	get_bloque_en_X_Y_paravram
		
		ld		a,103
		call	pinta_en_pantalla

fin_de_secuencia_cuchillo:
				
		xor		a
		ld		(momento_lanzamiento),a

		ret

trabajamos_en_pantalla_cuchillo:
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_cuchillo)
		ld		(pantalla_activa),a
		
		ret

reclamo_posicion_cuchillo:

		ld		a,[cx]													;tambien en vram
		ld		d,a
		ld		a,[cy]
		ld		e,a
		
		ret
		
actualiza_la_puerta:
		
		ld		a,(ya_ha_cambiado_puerta)
		or		a
		ret		nz
		
		ld		a,(mechero)
		or		a
		ret		z
		ld		a,(gasolina)
		or		a
		ret		z
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(pantalla_puerta)
		ld		(pantalla_activa),a
		
		ld		a,[px_salida]										
		ld		d,a
		ld		a,[py_salida]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,45
		ld		[hl],a
		
		ld		a,[px_salida]
		add		8										
		ld		d,a
		ld		a,[py_salida]
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,46
		ld		[hl],a
		
		ld		a,[px_salida]										
		ld		d,a
		ld		a,[py_salida]
		add		8
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,48
		ld		[hl],a
		
		ld		a,[px_salida]
		add		8										
		ld		d,a
		ld		a,[py_salida]
		add		8
		ld		e,a
		call	get_bloque_en_X_Y
		ld		a,47
		ld		[hl],a
				
		ex		af,af'
		ld		(pantalla_activa),a
		ld		b,a
		ld		a,(pantalla_puerta)
		cp		b
		jr.		nz,final_actualiza_puerta
					
		ld		hl,(posicion_puerta)
		ld		a,45
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		1
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,46
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		31
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,48
		call	pinta_en_pantalla
		
		ld		a,(posicion_puerta)
		add		1
		ld		(posicion_puerta),a
		ld		hl,(posicion_puerta)
		
		ld		a,47
		call	pinta_en_pantalla

final_actualiza_puerta:
		
		ld		a,1
		ld		(ya_ha_cambiado_puerta),a		
		
		ld		a,255
		
alegria_de_color:

		push	af
				
		xor		a
		ld		[COLLETRA],a											;aunque sólo quieras cambiar uno de los colores, tienes que volver a definir los otros dos para que te acepte un cambio
		xor		a
		ld		[COLFONDO],a
		ld		a,4
		ld		[COLBORDE],a
		call	COLOR
		ld		a,7
		ld		[COLBORDE],a
		call	COLOR
		ld		a,15
		ld		[COLBORDE],a
		call	COLOR
		ld		a,9
		ld		[COLBORDE],a
		call	COLOR
		
		pop		af
		dec		a
		or		a
		jr.		nz,alegria_de_color
		
		ld		a,1
		ld		[COLBORDE],a
		call	COLOR
		
		ld		a,1
		ld		(ya_ha_cambiado_puerta),a
		
		ret

comprueba_estado_de_explosion:

		ld		a,(estado_de_explosion)
		or		a
		ret		z
				
		ld		ix,atributos_sprite_general
		
		ld		a,(y_explosion)			;valor y**
		ld		(ix+12),a
			
		ld		a,(x_explosion)			;valor x**
		ld		(ix+13),a
		
		ld		a,(estado_de_explosion)	;SPRITE
		add		a,20
[2]		add		a,a
		ld		(ix+14),a
		
		ld		a,15					;COLOR EXPLOSION
		ld		(ix+15),a
		
		ld		a,(contador_retardo_explosion)
		inc		a
		ld		(contador_retardo_explosion),a
		cp		5
		ret		nz
		xor		a
		ld		(contador_retardo_explosion),a
		ld		a,(estado_de_explosion)
		inc		a
		ld		(estado_de_explosion),a
		cp		4
		jr.		z,finalizamos_la_explosion
		
		ret
		
finalizamos_la_explosion:
		
		ld		ix,atributos_sprite_general
		
		xor		a
		ld		(estado_de_explosion),a
		ld		(ix+12),a
		ld		(ix+13),a
		ld		(ix+15),a
		ld		a,24*4
		ld		(ix+14),a

		ret

puntuacion_vidas_fase:
		
		ld		a,(vidas_prota)						;pinta vidas
		cp		10
		call	nc,pon_vidas_a_maximo
		
		add		a,192
		ld		de,#1803
		call	pinta_algo_solo
		
		ld		a,(fase_en_la_que_esta)									;pinta fase
;		cp		20
;		jr.		nc,fase_superior_a_veinte
		cp		10
		call	nc,fase_superior_a_diez
		
puntuacion_vidas_fase_2:		
		
		add		a,192
		ld		de,#1816
		call	pinta_algo_solo
								
		ld		a,(cuenta_puntos_o_no)				;decide si pasa a poner puntos
		or		a
		ret		z
				
		ld		a,(cuanto_sumamos_a_score)
		ld		b,a
		ld		a,(score)
		add		a,b
		ld		(score),a
		xor		a
		ld		(cuanto_sumamos_a_score),a
		ld		a,(score)
		ld		b,a
		ld		a,(contador_para_puntuacion)
		cp		b
		jr.		nz,rutina_de_puntos
		xor		a
		ld		(cuenta_puntos_o_no),a
		ret

pon_vidas_a_maximo:
		
		ld		a,9
		ld		(vidas_prota),a
		
		ret
		
fase_superior_a_diez:

		sub		10
		
		push	af
		
		ld		a,193
		ld		de,#1815
		call	pinta_algo_solo
				
		pop		af
		
		ret

;fase_superior_a_veinte:
		
;		sub		20
		
;		push	af
		
;		ld		a,194
;		ld		[#eeee],a
;		ld		hl,#eeee
;		ld		de,#1815
;		ld		bc,1
;		call	GRABAVRAM
				
;		pop		af
		
;		jr.		puntuacion_vidas_fase_2
				
rutina_de_puntos:

		ld		a,(contador_para_puntuacion)
		inc		a
		ld		(contador_para_puntuacion),a
				
		ld		a,(posicion_del_punto_unidades)
		inc		a
		ld		(posicion_del_punto_unidades),a
		cp		202
		call	z,resetea_los_numeros
			
		jr.		termina_de_contar_puntuacion
		
resetea_los_numeros:
		
		ld		a,192								;limpia unidades
		ld		(posicion_del_punto_unidades),a
		
		ld		a,(posicion_del_punto_decenas)		;aumenta decenas
		inc		a
		ld		(posicion_del_punto_decenas),a		
		cp		202									;comprueba decenas
		ret		nz

		ld		a,192								;limpia decenas
		ld		(posicion_del_punto_decenas),a
		
		ld		a,(posicion_del_punto_centenas)		;aumenta centenas
		inc		a
		ld		(posicion_del_punto_centenas),a
		cp		202									;comprueba centenas
		ret		nz

		ld		a,192								;limpia centenas
		ld		(posicion_del_punto_centenas),a
		
		ld		a,(posicion_del_punto_millares)		;aumenta millares
		inc		a
		ld		(posicion_del_punto_millares),a
		cp		202									;comprueba millares
		ret		nz			
		
		ld		a,192								;limpia millares
		ld		(posicion_del_punto_millares),a
		
		ret
		
termina_de_contar_puntuacion:

		ld		a,(posicion_del_punto_millares)
		ld		de,#180b
		call	pinta_algo_solo
		
		ld		a,(posicion_del_punto_centenas)
		ld		de,#180c
		call	pinta_algo_solo
		
		ld		a,(posicion_del_punto_decenas)
		ld		de,#180d
		call	pinta_algo_solo
		
		ld		a,(posicion_del_punto_unidades)
		ld		de,#180e
		jp		pinta_algo_solo

ha_saltado:

		xor		a
		ld		(estado_prota),a
		
		ld		a,(dir_prota)
		or		a
		jr.		z,salta_hacia_la_derecha
		cp		1
		jr.		z,salta_hacia_la_izquierda
		
salta_hacia_la_derecha:
			
		call	dieciseis_dos
		call	get_bloque_en_X_Y
		cp		31
		ret		c
		
		ld		a,1
		ld		(estado_de_salto),a
		ret

salta_hacia_la_izquierda:

		call	menos_uno_dos
		call	get_bloque_en_X_Y
		cp		31
		ret		c
		
		ld		a,31
		ld		(estado_de_salto),a
		ret

salta_sube:
		
		xor		a
		ld		(estado_prota),a
						
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,la_y_a_la_derecha
		
		call	uno_menos_cuatro
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		cp		77
		jr.		z,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a

		ld		a,4														;efecto de saltar
		call	efecto_sonido

la_y_a_la_derecha:

		ld		a,[py]
		sub		a,4
		ld		[py],a
		
salta_resolucion:
		
		call	atributos_sprites
		ld		a,(estado_de_salto)
		inc		a
		ld		(estado_de_salto),a
		cp		21
		jr.		z,resetea_el_salto
		cp		51
		jr.		z,resetea_el_salto
		ret

resetea_el_salto:

		xor		a
		ld		(estado_de_salto),a
		ld		a,5
		ld		(cont_no_salta_dos_seguidas),a
		ret
		
salta_sube_izquierda:	


		call	menos_uno_quince
		call	get_bloque_en_X_Y
				
		cp		31
		jr.		c,la_y_a_la_izquierda
		
		ld		a,[px]													;mira si tiene techo
		dec		a														
		ld		d,a
		ld		a,[py]
		sub		4
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		cp		77
		jr.		z,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a

		ld		a,4														;efecto de saltar
		call	efecto_sonido

la_y_a_la_izquierda:
		
		ld		a,[py]
		sub		a,4														
		ld		[py],a
		
salta_sigue:
		
		call	dieciseis_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a
		
		jr.		salta_resolucion

salta_sigue_izquierda:

		call	menos_uno_quince
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a
		
		jr.		salta_resolucion

salta_baja:

		ld		a,[px]													;mira si tiene suelo
		add		15																	
		ld		d,a
		ld		a,[py]
		add		15
		ld		e,a	
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
				
		ld		a,[px]													;mira si tiene suelo
		add		15																	
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]													;mira si tiene suelo
		add		8																	
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		add		1
		ld		[px],a
		
		ld		a,[py]
		add		4
		ld		[py],a
		
		jr.		salta_resolucion
		
salta_baja_izquierda:

		call	menos_uno_dieciseis
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]													;mira si tiene suelo
		sub		15														
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]													;mira si tiene suelo
		sub		8														
		ld		d,a
		ld		a,[py]
		add		19
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,resetea_el_salto
		
		ld		a,[px]
		dec		a
		ld		[px],a
		
		ld		a,[py]
		add		4
		ld		[py],a
		
		jr.		salta_resolucion

animacion_entre_fases:

		call 	limpia_sprites
		call	SPRITES_UNO
		call	activa_mute
		ld		a,10													;las veces que se repite la secuencia de quemado
							
quemando_al_prota:
		
		halt
		ld		ix,atributos_sprite_general
		
		push	af
		ld		a,(py)
		call	CERO_CUATRO_OCHO
		ld		a,(px)
		call	UNO_CINCO_NUEVE	
		ld		a,51*4
		call	DOS_SEIS_DIEZ
		ld		a,15
		ld		(ix+3),a
		ld		a,6
		ld		(ix+7),a
		ld		a,10
		ld		(ix+11),a
				
		call	atributos_sprites
		ld		a,10
		
rutina_espera_quemando_1:
		
		halt		
		dec		a
		or		a
		jr.		nz,rutina_espera_quemando_1	
		
		halt
		ld		a,11													;efecto sonoro de quemar
		call	efecto_sonido
		
		ld		ix,atributos_sprite_general
		
		ld		a,54*4
		call	DOS_SEIS_DIEZ
				
		call	atributos_sprites		
		ld		a,10
		
rutina_espera_quemando_2:
		
		halt	
		dec		a
		or		a
		jr.		nz,rutina_espera_quemando_2	
		
		pop		af
		
		dec		a
		or		a
		jr.		nz,quemando_al_prota
		
		call	limpia_sprites
		
		ld		a,(fase_en_la_que_esta)
		inc		a
		ld		(fase_en_la_que_esta),a
		
		call	puntuacion_vidas_fase
		
		ld		a,128
		ld		(py),a
		ld		a,24
		ld		(px),a
		
		call	DISSCR	
		
		di
		call	setrompage0	
		ld		hl,entre_fases											;las dos puertas entre fases
		ld		de,#1820
		call	depack_VRAM
		call	recbios
		ei
		
		ld		a,(idioma)
		or		a
		jr.		nz,completamos_la_frase_en_ingles
		
		ld		hl,camino_a
		ld		de,#1aa2
		ld		bc,28
		call	GRABAVRAM
		jp		ha_saltado_la_rutina_anterior
		
completamos_la_frase_en_ingles:

		ld		hl,camino_a_ing
		ld		de,#1ac6
		ld		bc,20
		call	GRABAVRAM
				
ha_saltado_la_rutina_anterior:
		
		call	rutina_pone_consejo
		jr.		rutina_espera_quemando_2_cont
		
rutina_pone_consejo:		
		
		ld		de,#18a1
		ld		bc,30
		
		ld		a,(fase_en_la_que_esta)
		cp		2
		jr.		z,consejos_fase_2
		cp		3
		jr.		z,consejos_fase_3
		cp		4
		jr.		z,consejos_fase_4
		cp		5
		jr.		z,consejos_fase_7
		cp		9
		jr.		z,consejos_fase_9
		cp		11
		jr.		z,consejos_fase_8
		cp		12
		jr.		z,consejos_fase_5
		cp		13
		jr.		z,consejos_fase_6		
		ret

consejos_fase_2:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_2

consejo_ing_fase_2:

		ld		hl,advice_2
		ld		de,#18a7
		ld		bc,18
		jp		GRABAVRAM

consejo_esp_fase_2:
				
		ld		hl,consejo_2
		ld		de,#18a7
		ld		bc,18
		jp		GRABAVRAM

consejos_fase_3:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_3

consejo_ing_fase_3:

		ld		hl,advice_3
		ld		de,#18a0
		ld		bc,32
		jp		GRABAVRAM

consejo_esp_fase_3:
				
		ld		hl,consejo_3
		ld		de,#18a0
		ld		bc,32
		jp		GRABAVRAM

consejos_fase_4:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_4

consejo_ing_fase_4:

		ld		hl,advice_4
;		ld		de,#18a1
;		ld		bc,30
		jp		GRABAVRAM

consejo_esp_fase_4:
				
		ld		hl,consejo_4
;		ld		de,#18a1
;		ld		bc,30
		jp		GRABAVRAM
				
consejos_fase_5:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_5

consejo_ing_fase_5:

		ld		hl,advice_5
		ld		de,#18a0
		ld		bc,32
		jp		GRABAVRAM

consejo_esp_fase_5:
				
		ld		hl,consejo_5
		ld		de,#18a0
		ld		bc,31
		jp		GRABAVRAM

consejos_fase_6:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_6

consejo_ing_fase_6:

		ld		hl,advice_6
		ld		de,#18a2
		ld		bc,29
		jp		GRABAVRAM

consejo_esp_fase_6:
				
		ld		hl,consejo_6

		jp		GRABAVRAM
			
consejos_fase_7:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_7

consejo_ing_fase_7:

		ld		hl,advice_7
		ld		de,#18a0
		ld		bc,32
		jp		GRABAVRAM

consejo_esp_fase_7:
				
		ld		hl,consejo_7
		jp		GRABAVRAM

consejos_fase_8:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_8

consejo_ing_fase_8:

		ld		hl,advice_8
		ld		de,#18a0
		ld		bc,32
		jp		GRABAVRAM

consejo_esp_fase_8:
				
		ld		hl,consejo_8
		ld		de,#18a4
		ld		bc,24
		jp		GRABAVRAM

consejos_fase_9:
		
		ld		a,(idioma)
		or		a
		jr.		z,consejo_esp_fase_9

consejo_ing_fase_9:

		ld		hl,advice_9
		ld		de,#18a1
		ld		bc,30
		call	GRABAVRAM
		ld		hl,advice_9_1
		ld		de,#18d0
		ld		bc,3
		jp		GRABAVRAM

consejo_esp_fase_9:
				
		ld		hl,consejo_9

		jp		GRABAVRAM


										
rutina_espera_quemando_2_cont:

		call	ENASCR
		
		call	activa_musica_entre_fases
				
		ld		ix,atributos_sprite_general

		ld		a,(fase_en_la_que_esta)
		cp		19
		ret		z

paseito_entre_fases:			

[3]		halt
		
		call	atributos_sprites
		call	tiles_cambiantes_entre_fases
		
		ld		a,2
		ld		(ix+7),a
		ld		a,1
		ld		(ix+3),a
		ld		a,9
		ld		(ix+11),a
		
		ld		a,(py)
		ld		(ix),a
		add		a,9														;para que cuadren los sprites muevo esta
		ld		(ix+4),a
		sub		a,16
		ld		(ix+8),a
		xor		a
		call	DOS_SEIS_DIEZ
		ld		a,(px)
		add		a,4
		call	UNO_CINCO_NUEVE
		ld		(px),a
		
		
		
[3]		halt
		call	atributos_sprites
		call	tiles_cambiantes_entre_fases
			
		ld		a,(velocidad_paseo_fases)
		ld		b,a
		ld		a,(px)
		add		a,b
		ld		(px),a
		call	UNO_CINCO_NUEVE
		ld		a,12
		call	DOS_SEIS_DIEZ		
		ld		a,(px)
		cp		216
		jr.		c,paseito_entre_fases
				
		call	limpia_sprites
		
		ld		a,(toca_bombero)
		cp		1
			
		ret		nz
				
aparece_el_bombero:
		
		ld		a,20
		ld		(clock),a
		halt
		call	SPRITES_BOMBERO_PERSIGUE
		call	SPRITES_DOS
	

		ld		a,111
		call	CERO_CUATRO_OCHO
		ld		a,120
		call	UNO_CINCO_NUEVE
		xor		a
		call	DOS_SEIS_DIEZ
		ld		a,9
		ld		(ix+7),a
		ld		a,10
		ld		(ix+11),a
		ld		a,1
		ld		(ix+3),a
		ld		a,120
		ld		(ix+1),a
	
		call	atributos_sprites
		ld		a,1														;efecto sonoro de aparece bombero
		call	efecto_sonido

aparece_el_bombero_2:

		call 	espera_de_animaciones
		
		ld		bc,20
		ld		(clock),bc		
		
		xor		3*4
		call	DOS_SEIS_DIEZ
		
		ld		a,1														;efecto sonoro de aparece bombero
		call	efecto_sonido
		
		call	atributos_sprites

aparece_el_bombero_3:

		call 	espera_de_animaciones
		
		ld		bc,20
		ld		(clock),bc		
		
		xor		6*4
		call	DOS_SEIS_DIEZ
		
		ld		a,1														;efecto sonoro de aparece bombero
		call	efecto_sonido
		
		call	atributos_sprites

aparece_el_bombero_4:

		call 	espera_de_animaciones
		
		ld		bc,10
		ld		(clock),bc		
		
		xor		9*4
		call	DOS_SEIS_DIEZ
		
		ld		a,1														;efecto sonoro de aparece bombero
		call	efecto_sonido
		
		call	atributos_sprites

aparece_el_bombero_5:

		call 	espera_de_animaciones
		
		ld		bc,5
		ld		(clock),bc		
		
		xor		12*4
		call	DOS_SEIS_DIEZ
		
		ld		a,1														;efecto sonoro de aparece bombero
		call	efecto_sonido
		
		call	atributos_sprites
		
aparece_el_bombero_6:

		call 	espera_de_animaciones
		
		call	tiles_cambiantes_entre_fases
		
		ld		a,120
		ld		(py),a
		ld		a,114
		ld		(px),a
				
		ld		a,5
		ld		(clock),a
		
				
aparece_el_bombero_7:
		
		call 	espera_de_animaciones
		
		call	tiles_cambiantes_entre_fases
		
		ld		a,5
		ld		(clock),a
		
		ld		a,(py)
		ld		(ix),a
		sub		6
		ld		(ix+4),a
		add		16
		ld		(ix+8),a
		ld		a,(px)
		call	UNO_CINCO_NUEVE	
		ld		a,25*4
		call	DOS_SEIS_DIEZ
				
		call	atributos_sprites
		
aparece_el_bombero_8:

		call 	espera_de_animaciones
		
		call	tiles_cambiantes_entre_fases
		
		ld		bc,5
		ld		(clock),bc
		
		ld		a,(py)
		cp		130
		call	c,suma_a_y
		
		ld		a,(px)
		cp		210
		jr.		nc,aparece_el_bombero_9
		
		add		a,10
		ld		(px),a
		
		ld		a,(py)
		ld		(ix),a
		sub		6
		ld		(ix+4),a
		add		16
		ld		(ix+8),a
		ld		a,(px)
		call	UNO_CINCO_NUEVE	
		ld		a,28*4
		call	DOS_SEIS_DIEZ
				
		call	atributos_sprites
		
		jr.		aparece_el_bombero_7

aparece_el_bombero_9:
		
		call	limpia_sprites										
		call	SPRITES_UNO
		jp		SPRITES_DOS

tiles_cambiantes_entre_fases:
		
		ld		a,(clock_1)
		dec		a
		ld		(clock_1),a
		or		a
		call	z,reset_clock
		cp		2
		call	nc,limpia_clock_a_10_entre_fases
		
		ld		a,(tile_a_poner_agua)
		or		a
		jr.		nz,tiles_cambiantes_1_entre_fases
						
		ld		hl,fuego_1_2
		ld		de,#c8
		jp		standard_tiles_cambiantes

tiles_cambiantes_1_entre_fases:
		
		ld		hl,fuego_2_2
		ld		de,#c8
		jp		standard_tiles_cambiantes

limpia_clock_a_10_entre_fases:

		ld		bc,2
		ld		(clock_1),bc
		
		ret
						
espera_de_animaciones:

		halt
		ld		a,(clock)
		dec		a
		ld		(clock),a
		or		a
		jr.		nz,espera_de_animaciones
		
		ret
		
suma_a_y:

		inc		a
		ld		(py),a
		ret
		
movimiento_serpientes:
		
		ld		ix,atributos_sprite_general
		
analiza_serpiente_1:
		
		ld		a,(serp1)
		or		a
		jr.		z,analiza_serpiente_2
		cp		3
		jr.		z,pinta_muerta_1
				
		ld		iy,variables_serpiente_1
		
		call	rutina_de_movimiento_serpientes
			
		ld		ix,atributos_sprite_general
		ld		de,16
		call	atributos_serpiente_detallados
		
analiza_serpiente_2:

		
		ld		a,(serp2)
		or		a
		jr.		z,analiza_serpiente_3
		cp		3
		jr.		z,pinta_muerta_2
						
		ld		iy,variables_serpiente_2
		
		call	rutina_de_movimiento_serpientes
			
		ld		ix,atributos_sprite_general
		ld		de,24
		call	atributos_serpiente_detallados
		
analiza_serpiente_3:		
		
		ld		a,(serp3)
		or		a
		jr.		z,analiza_serpiente_4
		cp		3
		jr.		z,pinta_muerta_3
				
		ld		iy,variables_serpiente_3
		
		call	rutina_de_movimiento_serpientes
			
		ld		ix,atributos_sprite_general
		ld		de,32
		call	atributos_serpiente_detallados
		
analiza_serpiente_4:
	
		ld		a,(serp4)
		or		a
		ret		z
		cp		3
		jr.		z,pinta_muerta_4
				
		ld		iy,variables_serpiente_4
		
		call	rutina_de_movimiento_serpientes
			
		ld		ix,atributos_sprite_general
		ld		de,40
		jp		atributos_serpiente_detallados

atributos_serpiente_detallados:

		add		ix,de
		ex		af,af'
		ld		(ix+2),a
		ld		(ix+6),b
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a
		ld		a,(iy+1)
		ld		(ix),a
		ld		(ix+4),a
		ld		a,(iy+4)
		ld		(ix+3),a
		
		ld		a,1
		ld		(ix+7),a
		
		ex		af,af'
		ld		(pantalla_activa),a
		
		ld		a,(iy+9)
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		ret		z
		
no_Esta_en_pantalla:
		
		xor		a
		ld		(ix),a
		ld		(ix+4),a
		ld		a,24*4
		ld		(ix+2),a
		ld		(ix+6),a
		
		ret
		
pinta_muerta_1:
		
		ld		ix,atributos_sprite_general
		ld		de,16
		add		ix,de
		ld		iy,variables_serpiente_1
		
		call	pintamos_serpiente_muerta
		
		jr.		analiza_serpiente_2
		
pinta_muerta_2:

		ld		ix,atributos_sprite_general
		ld		de,24
		add		ix,de
		ld		iy,variables_serpiente_2
		
		call	pintamos_serpiente_muerta
		
		jr.		analiza_serpiente_3

pinta_muerta_3:

		ld		ix,atributos_sprite_general
		ld		de,32
		add		ix,de
		ld		iy,variables_serpiente_3
		
		call	pintamos_serpiente_muerta
		
		jr.		analiza_serpiente_4
		
pinta_muerta_4:

		ld		ix,atributos_sprite_general
		ld		de,40
		add		ix,de
		ld		iy,variables_serpiente_4

		jp		pintamos_serpiente_muerta

pintamos_serpiente_muerta:		
		
		ld		a,(iy+9)
		ld		b,a
		ld		a,(pantalla_activa)
		cp		b
		jr.		nz,no_Esta_en_pantalla
			
		ld		a,(iy+1)
		ld		(ix+),a
		ld		(ix+4),a
		ld		a,(iy)
		ld		(ix+1),a
		ld		(ix+5),a	
		ld		a,180
		ld		(ix+2),a
		ld		a,184
		ld		(ix+6),a
		
		ret
		
rutina_de_movimiento_serpientes:
		
		ld		a,(pantalla_activa)
		ex		af,af'
		ld		a,(iy+9)
		ld		(pantalla_activa),a
		
		ld		a,(iy+2)
		or		a
		jr.		nz,suma_x_serpiente

resta_x_serpiente:
				
		ld		a,(iy)
		cp		3
		jr.		c,va_a_pantalla_1
		
		ld		a,(iy+8)
		dec		a
		ld		(iy+8),a
		or		a
		jr.		nz,pose_serp
		
		ld		a,(iy+7)
		ld		(iy+8),a
				
		ld		a,[iy]
		dec		a														
		ld		d,a
		ld		a,[iy+1]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
				
		cp		31
		jr.		c,serp_cambia_paso_a_derecha
		
		ld		a,[iy]
		dec		a														
		ld		d,a
		ld		a,[iy+1]
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		cp		77
		jp		z,resta_x_serpiente_final
		cp		41
		jp		z,resta_x_serpiente_final
		cp		42
		jp		z,resta_x_serpiente_final		
		cp		31
		jr.		nc,serp_cambia_paso_a_derecha

resta_x_serpiente_final:
		
		ld		a,(iy)
		dec		a
		ld		(iy),a
		jr.		pose_serp
		
suma_x_serpiente:
		
		ld		a,(iy)
		cp		237
		jr.		nc,va_a_pantalla_2
		
		ld		a,(iy+8)
		dec		a
		ld		(iy+8),a
		or		a
		jr.		nz,pose_serp
		
		ld		a,(iy+7)
		ld		(iy+8),a
		
		ld		a,[iy]
		add		16														
		ld		d,a
		ld		a,[iy+1]
		add		15
		ld		e,a
		call	get_bloque_en_X_Y
		
		cp		31
		jr.		c,serp_cambia_paso_a_izquierda
		
		ld		a,[iy]
		add		16														
		ld		d,a
		ld		a,[iy+1]
		add		17
		ld		e,a
		call	get_bloque_en_X_Y
		cp		77
		jp		z,suma_x_serpiente_final
		cp		41
		jp		z,suma_x_serpiente_final
		cp		42
		jp		z,suma_x_serpiente_final
		
		cp		31
		jr.		nc,serp_cambia_paso_a_izquierda

suma_x_serpiente_final:
		
		ld		a,(iy)
		inc		a
		ld		(iy),a
		jr.		pose_serp

va_a_pantalla_1:

		ld		a,236
		ld		(iy),a
		ld		a,1
		ld		(iy+9),a
		
		ex		af,af'
		ret

va_a_pantalla_2:

		ld		a,4
		ld		(iy),a
		ld		a,2
		ld		(iy+9),a
		
		ex		af,af'
		ret
				
serp_cambia_paso_a_derecha:

		ld		a,1
		ld		(iy+2),a
		jr.		pose_serp
		
serp_cambia_paso_a_izquierda:

		xor		a
		ld		(iy+2),a
		jr.		pose_serp
		
pose_serp:

		ld		a,(iy+6)
		dec		a
		ld		(iy+6),a
		or		a
		jr.		nz,elegir_sprite_serp

		ld		a,(iy+5)
		ld		(iy+6),a
		
		ld		a,(iy+3)
		or		a
		jr.		nz,paso_2_serp
		
paso_1_serp:

		ld		a,1
		ld		(iy+3),a
		
		jr.		elegir_sprite_serp
		
paso_2_serp:

		xor		a
		ld		(iy+3),a
		
elegir_sprite_serp:

		ld		a,(iy+2)
		or		a
		jr.		nz,suma_direccion_1_serp
		
suma_direccion_0_serp:

		ld		a,(iy+3)
		or		a
		jr.		nz,suma_paso_01_serp
		
suma_paso_00_serp:

		ld		a,25*4
		ld		b,29*4
		ex		af,af'
		ret

suma_paso_01_serp:
		
		ld		a,26*4
		ld		b,30*4
		ex		af,af'
		ret
		
suma_direccion_1_serp:

		ld		a,(iy+3)
		or		a
		jr.		nz,suma_paso_11_serp

suma_paso_10_serp:

		ld		a,27*4
		ld		b,31*4
		ex		af,af'
		ret

suma_paso_11_serp:

		ld		a,28*4
		ld		b,32*4
		ex		af,af'
		ret	

; partes repetidas de los motores de vram
uno_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		1
		ld		d,a
		jp		x_diez
		
seis_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a

x_diez:

		ld		a,[py]
		add		10
		ld		e,a
		
		ret	
		
dos_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		2
		ld		d,a
		jr.		x_diez	

menos_dos_diez:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		2
		ld		d,a
		jr.		x_diez	

seis_dos:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a
		
x_dos:
		
		ld		a,[py]
		add		2
		ld		e,a
		
		ret

cero_cero:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		ld		d,a

x_cero:

		ld		a,[py]
		ld		e,a
		
		ret

menos_uno_cero:

		ld		a,[px]
		sub		1														;para buffer y vram moviendo -1 y 0					
		ld		d,a
		jr.		x_cero
		
siete_dieciseis:
		
		ld		a,[px]
		add		7					;para buffer y vram moviendo 6 y 10						
		ld		d,a

x_dieciseis:

		ld		a,[py]
		add		16
		ld		e,a
		
		ret
		
menos_uno_dieciseis:
		
		ld		a,[px]
		dec		a					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		jr.		x_dieciseis
		
dieciseis_dieciseis:
		
		ld		a,[px]
		add		16					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		jr.		x_dieciseis
		
menos_dos_dieciocho:
		
		ld		a,[px]
		sub		2					;para buffer y vram moviendo -2 y 18						
		ld		d,a

x_dieciocho:

		ld		a,[py]
		add		18
		ld		e,a
		
		ret
				
catorce_diez:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 10						
		ld		d,a
		jr.		x_diez

diez_diez:

		ld		a,[px]
		add		10					;para buffer y vram moviendo 14 y 10						
		ld		d,a
		jr.		x_diez
		
doce_diez:
		
		ld		a,[px]
		add		12					;para buffer y vram moviendo 12 y 10						
		ld		d,a
		jr.		x_diez
		
catorce_dos:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 22						
		ld		d,a
		jr.		x_dos
				
catorce_dieciocho:
		
		ld		a,[px]
		add		14					;para buffer y vram moviendo 14 y 18						
		ld		d,a
		jr.		x_dieciocho
		
veinte_diez:
		
		ld		a,[px]
		add		20					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		jr.		x_diez
		
		ret

veintidos_diez:
		
		ld		a,[px]
		add		22					;para buffer y vram moviendo 6 y 10						
		ld		d,a
		jr.		x_diez
				
menos_diez_diez:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		10
		ld		d,a
		jr.		x_diez
		
seis_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		6
		ld		d,a
		jr.		x_dieciocho

menos_diez_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		sub		10
		ld		d,a
		jr.		x_dieciocho

tres_quince:
		
		ld		a,[px]					;para buffer y vram moviendo 3 y 15	
		add		3
		ld		d,a


x_quince:

		ld		a,[py]
		add		15
		ld		e,a
		
		ret

tres_dos:
		ld		a,[px]					;para buffer y vram moviendo 3 y 2
		add		3
		ld		d,a
		jr.		x_dos
				

		
dos_dieciocho:
		
		ld		a,[px]					;para buffer y vram moviendo 6 y 10		
		add		2				
		ld		d,a
		jr.		x_dieciocho
		
ocho_dieciocho:
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		8
		ld		d,a
		jr.		x_dieciocho
		
diez_dieciocho:
		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		10
		ld		d,a
		jr.		x_dieciocho
		
ocho_uno:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		8
		ld		d,a

x_uno:

		ld		a,[py]
		inc		a
		ld		e,a
		
		ret
ocho_cuatro:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		add		8
		ld		d,a
		jr.		x_cuatro_mas
						
dieciseis_quince:

		ld		a,[px]					;para buffer y vram moviendo 16 y 15						
		add		16
		ld		d,a
		jr.		x_quince

dieciseis_dos:

		ld		a,[px]					;para buffer y vram moviendo 16 y 2						
		add		16
		ld		d,a
		jr.		x_dos

menos_dos_menos_cuatro:
		
		ld		a,[px]													;para buffer y vram moviendo -2 y menos 4						
		sub		2
		ld		d,a
		jr.		x_cuatro

nueve_menos_cuatro:

		ld		a,[px]													;para buffer y vram moviendo 9 y menos 4						
		add		9
		ld		d,a
		jr.		x_cuatro
						
uno_menos_cuatro:

		ld		a,[px]													;para buffer y vram moviendo 1 y -4					
		inc		a
		ld		d,a

x_cuatro:

		ld		a,[py]
		sub		4
		ld		e,a
		
		ret

x_cuatro_mas:

		ld		a,[py]
		add		4
		ld		e,a
		
		ret
				
menos_uno_quince:

		ld		a,[px]					;para buffer y vram moviendo 6 y 10						
		dec		a
		ld		d,a
		jr.		x_quince

menos_uno_dos:

		ld		a,[px]					;para buffer y vram moviendo -1 y 2						
		dec		a
		ld		d,a
		jr.		x_dos

pinta_en_pantalla:

		ld		de,#1800												;pinta en pantalla lo especificado anteriormente
		add		hl,de
		push	hl
		ld		[#eeee],a
		ld		hl,#eeee
		pop		de
		ld		bc,1
		jp		GRABAVRAM
	
efecto_sonido:
		
		ld		c,a
		jp		ayFX_INIT

; partes repetidas de los motores de sprites

CERO_CUATRO_OCHO:

		ld		(ix),a
		ld		(ix+4),a
		ld		(ix+8),a
		
		ret
		
UNO_CINCO_NUEVE:

		ld		(ix+1),a
		ld		(ix+5),a
		ld		(ix+9),a
		
		ret

DOS_SEIS_DIEZ:

		ld		(ix+2),a
		add		4
		ld		(ix+6),a
		add		4
		ld		(ix+10),a
		
		ret
		
		;DESCOMPRESORES

depack_VRAM:		

		include "PL_VRAM_Depack_SJASM.asm"						; hl=ram/rom fuente de=vram destino

depack:

		include	"unpack.asm"									; hl=ram/rom fuente de=ram destino

		;la instrucción que dejaremos en lugar del gancho
		
nuestra_isr:

		call	PT3_ROUT												;envia los datos a los registros del PSG
		call	PT3_PLAY												;calcula el siguiente trozo de música que será enviado la próxima vez
		call	ayFX_PLAY												;calcula el siguiente trozo de efecto que será enviado la próxima vez
;		jp		VIEJA_INTERR											;ahora se va a ejecutar la original que había en el gancho
		ret
		;gancho area salvada
		
		;MUSICA Y EFECTOS
		
		include 	"PT3-ROM_sjasm.asm"									;incluye el codigo del reproductor de PT3 (musica)
		include		"ayFX-ROM_sjasm.asm"								;incluye el codigo del reproductor AY (efectos)
		
	;Variables del replayer... las coloco desde aqui.
	;mirar que hace la directiva MAP del SJASM
	map		#f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PT3 REPLAYER

PT3_SETUP:			#1	;set bit0 to 1, if you want to play without looping
					;bit7 is set each time, when loop point is passed
PT3_MODADDR:		#2
PT3_CrPsPtr:		#2
PT3_SAMPTRS:		#2
PT3_OrnPtrs:		#2
PT3_PDSP:			#2
PT3_CSP:			#2
PT3_PSP:			#2
PT3_PrNote:			#1
PT3_PrSlide:		#2
PT3_AdInPtA:		#2
PT3_AdInPtB:		#2
PT3_AdInPtC:		#2
PT3_LPosPtr:		#2
PT3_PatsPtr:		#2
PT3_Delay:			#1
PT3_AddToEn:		#1
PT3_Env_Del:		#1
PT3_ESldAdd:		#2
PT3_NTL3:			#2	; AND A / NOP (note table creator)

VARS:				#0

ChanA:				#29			;CHNPRM_Size
ChanB:				#29			;CHNPRM_Size
ChanC:				#29			;CHNPRM_Size

;GlobalVars
DelyCnt:			#1
CurESld:			#2
CurEDel:			#1
Ns_Base_AddToNs:	#0
Ns_Base:			#1
AddToNs:			#1

NT_:				#192	; Puntero a/tabla de frecuencias

AYREGS:				#0
VT_:				#14
EnvBase:			#2
VAR0END:			#0

T1_:				#0		
T_NEW_1:			#0
T_OLD_1:			#24
T_OLD_2:			#24
T_NEW_3:			#0
T_OLD_3:			#2
T_OLD_0:			#0
T_NEW_0:			#24
T_NEW_2:			#166
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PT3 REPLAYER END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ayFX REPLAYER 
ayFX_MODE:			#1			; ayFX mode
ayFX_BANK:			#2			; Current ayFX Bank
ayFX_PRIORITY:		#1			; Current ayFX stream priotity
ayFX_POINTER:		#2			; Pointer to the current ayFX stream
ayFX_TONE:			#2			; Current tone of the ayFX stream
ayFX_NOISE:			#1			; Current noise of the ayFX stream
ayFX_VOLUME:		#1			; Current volume of the ayFX stream
ayFX_CHANNEL:		#1			; PSG channel to play the ayFX stream

	;IF (AYFXRELATIVE == 1 ) 
;ayFX_VT:	ds	2			; ayFX relative volume table pointer
	;ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ayFX REPLAYER END
																
;CONSTANTES

EFECTOS_BAN_P:	incbin	"efectos_PLETTER.afb"								;incluye el banco de efectos

sanctuary_x:	db	242,224,237,226,243,244,224,241,248,64
sanctuary_1:	db	192,193
sanctuary_2:	db	192,194
sanctuary_3:	db	192,195
sanctuary_4:	db	192,196
sanctuary_5:	db	192,197
sanctuary_6:	db	192,198
sanctuary_7:	db	192,199
sanctuary_8:	db	192,200
sanctuary_9:	db	192,201
sanctuary_10:	db	193,192
sanctuary_11:	db	193,193
sanctuary_12:	db	193,194
sanctuary_13:	db	193,195
sanctuary_14:	db	193,196
sanctuary_15:	db	193,197
sanctuary_16:	db	193,198
sanctuary_17:	db	193,199
sanctuary_18:	db	193,200
santuario_x:	db	242,224,237,243,244,224,241,232,238,64

consejo_2:		db	195,64,225,238,236,225,224,242,64,64,193,64,242,244,228,235,238,251
consejo_3:		db	244,242,224,64,209,64,227,228,64,228,242,226,224,235,74,237,64,242,232,64,41,42,64,228,242,243,8,64,241,238,243,224
consejo_4:		db 	64, 64, 236, 238, 233, 224, 227, 238, 64, 237, 238, 64, 224, 241, 227, 228, 241, 8, 242, 251, 64, 64, 242, 9, 226, 224, 243, 228, 64, 64
consejo_5:		db 	64, 237, 238, 64, 243, 238, 227, 238, 242, 64, 235, 238, 242, 64, 236, 244, 241, 238, 242, 64, 242, 238, 237, 64, 232, 230, 244, 224, 235, 228, 242, 64
consejo_6:		DB  224,226,243,232,245,224, 64,64,235,224,64, 64, 64,228,242,226,224,235,228,241,224, 64, 64,242,228,226,241,228,243,224
consejo_7:		db	228, 235, 64, 225, 238, 236, 225, 228, 241, 238, 64, 243, 228, 64, 236, 238, 233, 224, 241, 8, 64, 227, 228, 236, 224, 242, 232, 224, 227, 238
consejo_8:		DB  64,64,64,64,64,245,224,226,73,224, 64,235,224, 64,225,224,235,242,224, 64,64, 64, 64,64
consejo_9:		db	228, 237, 226, 232, 228, 237, 227, 228, 64, 235, 224, 64, 235, 244, 249, 64, 239, 224, 241, 224, 64, 239, 238, 227, 228, 241, 64, 245, 228, 241
advice_2:		db	195,64,225,238,236,225,242,64,64,64,64,193,64,229,235,238,238,241
advice_3:		db	244,242,228,64,209,64,224,242,64,224,64,242,243,228,239,64,64,232,229,64,41,42,64,232,242,64,225,241,238,234,228,237
advice_4:		db 	232,229,64,248,238,244,64,224,241,228,64,246,228,243,251,64,248,238,244,64,246,238,237,120,243,64,225,244,241,237
advice_5:		db 	64,237, 238, 243, 64, 224, 235, 235, 64, 243,231,228,64,246, 224, 235, 235, 242, 64, 224, 241, 228, 64, 243, 231, 228, 64, 242, 224, 236, 228,64
advice_6:		db	224, 226, 243, 232, 245, 224, 243, 228, 64, 64, 243, 231, 228, 64, 64, 242, 228, 226, 241, 228, 243, 64, 64, 235, 224, 227, 227, 228, 241, 242
advice_7:		db	243,231,228,64,229, 232, 241, 228, 236, 224, 237, 64, 246, 232, 235, 235, 64, 230, 228, 243, 64, 248, 238, 244, 64, 243, 238, 238, 64, 246, 228, 243
advice_8:		DB  228,236,239,243,248, 64,243,231,228, 64,239,238,237,227,64,64,243,238,64,230,228,243,64,224,226,241,238,242,242,64,232,243
advice_9:		db	243, 244, 241, 237, 64, 243, 231, 228, 64, 235, 232, 230, 231, 243, 242,64,238, 237, 64, 242, 238, 64, 248,238,244,64,64,226,224,237
advice_9_1:		db	242,228,228
lo_has_logrado:	db	235,238,64,231,224,242,64,235,238,230,241,224,227,238,251,64,228,242,243,224,242,64,236,244,241,232,228,237,227,238,252
felicidades:	db	212,64,212,64,229,64,228,64,235,64,232,64,226,64,232,64,227,64,224,64,227,64,228,64,242,64,252,64,252,64
camino_a:		db	236,232,228,237,243,241,224,242,251,64,228,237,64,238,243,241,238,64,64,242,224,237,243,244,224,241,232,238
camino_a_ing:	db	232,237,64,224,237,238,243,231,228,241,64,242,224,237,226,243,244,224,241,248
fin_nivel_1_1:	DB 	237,238, 64,231,228, 64,224,241,227,232,227,238, 64, 64,235,238, 64, 64,242,244,229,232,226,232,228,237,243,228,251
fin_nivel_1_2:	DB  227,224,236,228,227,244,241,232,242, 64,239,232,227,228, 64,240,244,228, 64, 64,233,244,228,230,244,228
fin_nivel_1_3:	DB  224,235, 64,237,232,245,228,235, 64,227,232,229,73,226,232,235
end_level_1_1:	DB  232, 64,231,224,245,228, 64,237,238,243, 64,225,244,241,237,228,227, 64,228,237,238,244,230,231,251
end_level_1_2:	DB  230,232,245,228,236,228,231,224,241,227, 64,224,242,234,242, 64,236,228, 64,243,238, 64,239,235,224,248
end_level_1_3:	DB  243,231,228,64,231,224,241,227,64,235,228,245,228,235

col_letras_5:	db	97,97,113,97
col_letras_7:	db	129,129,113,129
col_letras_8:	db	145,145,113,145
col_letras_9:	db	161,161,113,161
col_letras_10:	db	177,177,113,177
col_letras_12:	db	209,209,113,209

blanco:			incbin	"BLANCO_pletter.DAT"
mas_blanco:		incbin	"BLANCO_mas_pletter.DAT"
marcador:		incbin	"marcador_pletter.dat"
trofeos:		incbin	"trofeos_pletter.dat"
sprites:		; --- prota derecha quieto
				; color 1
sprites13:		DB $00,$0F,$1F,$1F,$36,$34,$7C,$3E
				DB $1E,$3F,$49,$28,$1F,$10,$07,$00
				DB $00,$F0,$F8,$98,$50,$50,$08,$08
				DB $10,$E0,$A0,$50,$F0,$90,$C0,$00
				; color 2
				DB $00,$36,$17,$00,$0F,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$40,$A0,$00,$60,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$09,$0B,$03,$01,$01
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$60,$A0,$A0,$F0,$F0,$E0
				; 
				; --- prota derecha andando
				; color 1
sprites14:		DB $07,$0F,$0F,$1B,$1B,$3F,$1F,$0F
				DB $1F,$24,$14,$0F,$08,$18,$1E,$00
				DB $F8,$FC,$8C,$58,$58,$04,$84,$88
				DB $F8,$D8,$24,$FC,$66,$AE,$1C,$00
				; color 2
				DB $1B,$0B,$00,$07,$07,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $20,$D8,$00,$98,$10,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$04,$04,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$70,$A0,$A0,$F8,$78,$70,$00
				; 
				; --- prota izquierda quieto
				; color 1
sprites15:		DB $00,$0F,$1F,$19,$0A,$0A,$10,$10
				DB $08,$07,$05,$0A,$0F,$09,$03,$00
				DB $00,$F0,$F8,$F8,$6C,$2C,$3E,$7C
				DB $78,$FC,$92,$14,$F8,$08,$E0,$00
				; color 2
				DB $00,$02,$05,$00,$06,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$6C,$E8,$00,$F0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$06,$05,$05,$0F,$0F,$07
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$90,$D0,$C0,$80,$80
				; 
				; --- prota izquierdo andando
				; color 1
sprites16:		DB $1F,$3F,$31,$1A,$1A,$20,$21,$11
				DB $1F,$1B,$24,$3F,$66,$75,$38,$00
				DB $E0,$F0,$F0,$D8,$D8,$FC,$F8,$F0
				DB $F8,$24,$28,$F0,$10,$18,$78,$00
				; color 2
				DB $04,$1B,$00,$19,$08,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $D8,$D0,$00,$E0,$E0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$0E,$05,$05,$1F,$1E,$0E,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$20,$20,$00,$00,$00,$00
				; 
				; --- subiendo 1
				; color 1
				DB $00,$07,$0F,$1F,$1F,$3F,$5F,$4F
				DB $7F,$5D,$4B,$28,$1C,$17,$10,$00
				DB $00,$E0,$F0,$F8,$F8,$F8,$F8,$F0
				DB $F8,$FC,$D4,$14,$38,$E8,$08,$70
				; color 6
				DB $22,$34,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$28,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$20,$30,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- subiendo 2
				; color 1
				DB $00,$07,$0F,$1F,$1F,$1F,$1F,$0F
				DB $1F,$3F,$2B,$28,$1C,$17,$10,$0E
				DB $00,$E0,$F0,$F8,$F8,$FC,$FA,$F2
				DB $FE,$BA,$D2,$14,$38,$E8,$08,$00
				; color 6
				DB $00,$14,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $44,$2C,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$04,$0C,$00
				; 
				; --- prota cae
				; color 1
				DB $17,$1F,$3F,$3E,$2C,$2A,$3A,$18
				DB $0C,$1F,$16,$11,$31,$AF,$E2,$72
				DB $E0,$E8,$F8,$3C,$14,$54,$5C,$18
				DB $30,$F8,$68,$88,$8D,$F7,$87,$0E
				; color 2
				DB $00,$09,$0E,$0E,$10,$1C,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$90,$70,$70,$08,$78,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$01,$13,$15,$05,$07,$03
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$C0,$E8,$A8,$A0,$E0,$C0
				; 
				; --- explosion 1
				; color 1
				DB $60,$57,$65,$57,$60,$10,$09,$07
				DB $03,$03,$05,$01,$01,$00,$00,$00
				DB $0C,$0C,$0C,$00,$0C,$10,$A0,$E0
				DB $F8,$E0,$50,$00,$00,$00,$00,$00
				; 
				; --- explosion 2
				; color 1
				DB $60,$57,$65,$57,$60,$08,$0E,$07
				DB $07,$3F,$07,$0F,$13,$00,$00,$00
				DB $06,$76,$56,$70,$06,$10,$78,$F0
				DB $E0,$F0,$C0,$E0,$F0,$C8,$80,$00
				; 
				; --- explosion 3
				; color 1
				DB $60,$57,$65,$57,$60,$0D,$FD,$1D
				DB $3C,$39,$0C,$06,$0F,$13,$21,$01
				DB $05,$77,$57,$75,$05,$B0,$B6,$B8
				DB $3C,$9F,$38,$70,$E8,$E6,$42,$00
				; SPRITE EN BLANCO
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				;
				; --- Serpiente izquierda 1
				; color 5
				DB $00,$00,$1F,$3F,$7F,$7E,$3A,$12
				DB $7E,$3D,$00,$07,$0F,$00,$0F,$00
				DB $00,$00,$C0,$E0,$F0,$F0,$F0,$F0
				DB $F0,$F0,$20,$C0,$B0,$2E,$DE,$00
				; --- Serpìente izquierda 2
				; color 5
				DB $00,$00,$0F,$1F,$1F,$0E,$04,$1F
				DB $0F,$00,$0F,$1F,$00,$1F,$1F,$00
				DB $00,$00,$E0,$F0,$B8,$B8,$B8,$B8
				DB $38,$F0,$60,$80,$60,$5C,$BC,$00
				; --- Serpiente derecha 1
				; color 5
				DB $00,$00,$03,$07,$0F,$0F,$0F,$0F
				DB $0F,$0F,$04,$03,$0D,$74,$7B,$00
				DB $00,$00,$F8,$FC,$FE,$7E,$5C,$48
				DB $7E,$BC,$00,$E0,$F0,$00,$F0,$00
				; --- Serpiente derecha 2
				; color 5
				DB $00,$00,$07,$0F,$1D,$1D,$1D,$1D
				DB $1C,$0F,$06,$01,$06,$3A,$3D,$00
				DB $00,$00,$F0,$F8,$F8,$70,$20,$F8
				DB $F0,$00,$F0,$F8,$00,$F8,$F8,$00
				; --- Serpiente izquierda 1
				; color 1
				DB $00,$1F,$20,$40,$80,$81,$C5,$ED
				DB $81,$42,$3F,$08,$10,$1F,$10,$0F
				DB $00,$C0,$20,$10,$08,$08,$08,$08
				DB $08,$08,$D0,$30,$4E,$D1,$21,$FF
				; --- Serpìente izquierda 2
				; color 1
				DB $00,$0F,$10,$20,$20,$31,$3B,$20
				DB $10,$0F,$10,$20,$3F,$20,$20,$1F
				DB $00,$E0,$10,$08,$44,$44,$44,$44
				DB $C4,$08,$90,$60,$9C,$A2,$42,$FE
				; --- Serpiente derecha 1
				; color 1
				DB $00,$03,$04,$08,$10,$10,$10,$10
				DB $10,$10,$0B,$0C,$72,$8B,$84,$FF
				DB $00,$F8,$04,$02,$01,$81,$A3,$B7
				DB $81,$42,$FC,$10,$08,$F8,$08,$F0
				; --- Serpiente derecha 2
				; color 1
				DB $00,$07,$08,$10,$22,$22,$22,$22
				DB $23,$10,$09,$06,$39,$45,$42,$7F
				DB $00,$F0,$08,$04,$04,$8C,$DC,$04
				DB $08,$F0,$08,$04,$FC,$04,$04,$F8		
				; --- Prota derecha lanza 1
				; color 1
				DB $0F,$1F,$1F,$2D,$2C,$7C,$3E,$1E
				DB $FF,$A3,$D1,$79,$0F,$10,$31,$3C
				DB $F0,$F8,$18,$90,$B0,$08,$C8,$10
				DB $F0,$A8,$14,$14,$F8,$CC,$5C,$38
				; color 6
				DB $5C,$2E,$06,$00,$0F,$0E,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $50,$E8,$E8,$00,$30,$20,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$12,$13,$03,$01,$01,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$E0,$60,$40,$F0,$30,$E0,$00
				; 
				; --- Prota derecha lanza 2
				; color 1
				DB $00,$07,$0F,$0F,$1B,$1B,$3F,$1F
				DB $0F,$1F,$2A,$24,$2F,$18,$30,$3C
				DB $00,$F8,$FC,$CC,$6C,$28,$04,$94
				DB $88,$FC,$42,$82,$7E,$F8,$88,$7C
				; color 6
				DB $00,$15,$1B,$10,$07,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$BC,$7C,$80,$00,$70,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$04,$04,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$30,$90,$D0,$F8,$68,$70
				; 
				; --- Prota izquierda lanza 1
				; color 1
				DB $0F,$1F,$18,$09,$0D,$10,$13,$08
				DB $0F,$15,$28,$28,$1F,$33,$3A,$1C
				DB $F0,$F8,$F8,$B4,$34,$3E,$7C,$78
				DB $FF,$C5,$8B,$9E,$F0,$08,$8C,$3C
				; color 6
				DB $0A,$17,$17,$00,$0C,$04,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $3A,$74,$60,$00,$F0,$70,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$07,$06,$02,$0F,$0C,$07,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$48,$C8,$C0,$80,$80,$00 
				; --- Prota izquierda lanza 2
				; color 1
				DB $00,$1F,$3F,$33,$36,$14,$20,$29
				DB $11,$3F,$42,$41,$7E,$1F,$11,$3E
				DB $00,$E0,$F0,$F0,$D8,$D8,$FC,$F8
				DB $F0,$F8,$54,$24,$F4,$18,$0C,$3C
				; color 6
				DB $00,$3D,$3E,$01,$00,$0E,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$A8,$D8,$08,$E0,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$0C,$09,$0B,$1F,$16,$0E
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$20,$20,$00,$00,$00
				; 
				; --- Serpiente muerta
					; color 5
				DB $00,$00,$00,$00,$03,$0F,$1E,$3F
				DB $38,$3D,$3D,$3D,$3F,$1D,$0D,$00
				DB $00,$00,$00,$00,$E0,$F8,$FC,$7A
				DB $16,$82,$CE,$D6,$DA,$DA,$B8,$00
				; color 1
				DB $00,$00,$00,$03,$0C,$10,$21,$40
				DB $47,$42,$42,$42,$40,$22,$12,$0F
				DB $00,$00,$00,$E0,$18,$04,$02,$85
				DB $E9,$7D,$31,$29,$25,$25,$46,$FC
			
				; 
				; --- Serpiente mata prota
				; color 1
				DB $0F,$10,$20,$20,$31,$3B,$60,$B0
				DB $5F,$BC,$19,$F4,$43,$A4,$54,$2F
				DB $E0,$18,$04,$52,$75,$79,$79,$9D
				DB $7F,$1D,$18,$37,$D1,$09,$0A,$FC
				; color 3
				DB $00,$0F,$1F,$1F,$0E,$04,$1F,$4F
				DB $20,$00,$00,$08,$3C,$1B,$0B,$00
				DB $00,$E0,$F8,$AC,$8A,$86,$86,$02
				DB $00,$00,$00,$08,$2E,$F6,$F4,$00
				; color 4
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$40,$20,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$43,$E6,$03,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$60
				DB $80,$E2,$E7,$C0,$00,$00,$00,$00
				; --- incendio izquierda
				; color 1
				DB $AD,$A9,$ED,$49,$4D,$00,$0F,$0E
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $D5,$55,$DD,$54,$55,$00,$E0,$E0
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 6
				DB $00,$00,$02,$16,$32,$1F,$10,$11
				DB $1F,$3F,$3F,$3C,$1E,$98,$D0,$F0
				DB $00,$00,$00,$28,$A8,$F8,$18,$18
				DB $F4,$F6,$7E,$FE,$77,$77,$23,$1F
				; color 10
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$03,$01,$07,$2F,$0F
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$80,$00,$88,$88,$DC,$E0
				; 
				; --- incendio derecha
				; color 1
				DB $00,$00,$0F,$0E,$00,$01,$01,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$E0,$E0,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 6
				DB $06,$0F,$10,$11,$5F,$5E,$1E,$3F
				DB $1F,$1F,$0F,$4D,$1E,$18,$98,$FC
				DB $F8,$F2,$16,$10,$F8,$F2,$E0,$F2
				DB $72,$F2,$F9,$F1,$E8,$68,$7C,$2C
				; color 10
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$02,$01,$07,$07,$03
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $80,$00,$00,$00,$10,$90,$80,$D0

sprites2:		; --- BOMBERO DERECHA QUIETO
				; color 1
				DB $00,$03,$05,$0A,$0F,$40,$7F,$0A
				DB $0A,$0F,$37,$49,$59,$2F,$1A,$03
				DB $00,$F0,$50,$D0,$F0,$02,$FE,$50
				DB $70,$90,$F0,$7E,$42,$FE,$60,$F0
				; color 4
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $02,$05,$00,$3F,$00,$05,$05,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $A0,$20,$00,$FC,$00,$A0,$80,$60
				; color 11
				DB $00,$36,$26,$10,$03,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$80,$BC,$00,$60,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO DERECHA ANDANDO
				; color 1
				DB $01,$02,$05,$07,$20,$3F,$05,$05
				DB $07,$1B,$24,$2C,$17,$0C,$0E,$07
				DB $F8,$A8,$68,$F8,$01,$FF,$28,$38
				DB $C8,$F8,$BF,$A1,$FF,$6C,$DC,$38
				; color 4
				DB $00,$00,$00,$00,$00,$00,$00,$01
				DB $02,$00,$1F,$00,$02,$02,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$50
				DB $90,$00,$FE,$00,$D0,$C0,$30,$00
				; color 11
				DB $1B,$13,$08,$03,$01,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $40,$5E,$00,$B0,$20,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO IZQUIERDA QUIETO
				; color 1
				DB $00,$0F,$0A,$0B,$0F,$40,$7F,$0A
				DB $0E,$09,$0F,$7E,$42,$7F,$06,$0F
				DB $00,$C0,$A0,$50,$F0,$02,$FE,$50
				DB $50,$F0,$EC,$92,$9A,$F4,$58,$C0
				; color 4
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $05,$04,$00,$3F,$00,$05,$01,$06
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $40,$A0,$00,$FC,$00,$A0,$A0,$00

				; color 9
sprites3:		DB $00,$01,$3D,$00,$06,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$6C,$64,$08,$C0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO IZQUIERDA ANDANDO
				; color 1
				DB $1F,$15,$16,$1F,$80,$FF,$14,$1C
				DB $13,$1F,$FD,$85,$FF,$36,$3B,$1C
				DB $80,$40,$A0,$E0,$04,$FC,$A0,$A0
				DB $E0,$D8,$24,$34,$E8,$30,$70,$E0
				; color 4
				DB $00,$00,$00,$00,$00,$00,$00,$0A
				DB $09,$00,$7F,$00,$0B,$03,$0C,$00
				DB $00,$00,$00,$00,$00,$00,$00,$80
				DB $40,$00,$F8,$00,$40,$40,$00,$00
				; color 11
				DB $02,$7A,$00,$0D,$04,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $D8,$C8,$10,$C0,$80,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO SUBIENDO 1
				; color 1
				DB $07,$0C,$37,$54,$54,$54,$2D,$1A
				DB $0F,$1f,$2F,$2A,$1A,$0F,$12,$1E
				DB $E0,$30,$EC,$2A,$2A,$2A,$B4,$5C
				DB $F2,$fE,$F2,$5C,$58,$E8,$78,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$03
				DB $08,$2B,$2B,$2B,$12,$05,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$C0
				DB $10,$D4,$D4,$D4,$48,$A0,$00,$00
spritescaebom:	; --- BOMBERO CIRCUNSATANCIAL CAYENDO
				; color 1
				DB $38,$67,$6A,$1F,$66,$E5,$3E,$AA
				DB $59,$0A,$7F,$40,$0A,$0A,$06,$03
				DB $1C,$E6,$56,$F8,$66,$A7,$7C,$55
				DB $9A,$50,$FE,$02,$50,$50,$60,$C0
				; color 4
				DB $C1,$45,$06,$15,$00,$3F,$05,$05
				DB $01,$00,$00,$00,$00,$00,$00,$00
				DB $83,$A2,$60,$A8,$00,$FC,$A0,$A0
				DB $80,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$18,$15,$00,$19,$1A
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$18,$A8,$00,$98,$58				
				;SIGUE BOMBERO SUBIENDO 1
				; color 13
sprites4:		DB $10,$15,$05,$00,$0C,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $0C,$A0,$A0,$10,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- BOMBERO SUBIENDO 2
				; color 1
				DB $07,$0C,$37,$54,$54,$54,$2D,$3A
				DB $4F,$7f,$4F,$3A,$1A,$17,$1E,$00
				DB $E0,$30,$EC,$2A,$2A,$2A,$B4,$58
				DB $F0,$f8,$F4,$54,$58,$F0,$48,$78
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$03
				DB $08,$2B,$2B,$2B,$12,$05,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$C0
				DB $10,$D4,$D4,$D4,$48,$A0,$00,$00
				; color 11
				DB $30,$05,$05,$08,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $08,$A8,$A0,$00,$30,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				
				; --- CHORRO IZQUIERDA
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$10,$11,$02,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$40,$20,$00,$18,$00
				; color 15
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$01,$07,$0E,$0C,$1F,$7F,$FF
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$FC,$FF,$BC,$90,$F0,$E0,$F8
				; 
				; --- CHORRO DERECHA
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$02,$04,$00,$18,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$08,$88,$40,$00,$00,$00
				; color 15
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$3F,$FF,$3D,$09,$0F,$07,$1F
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$80,$E0,$70,$30,$F8,$FE,$FF
				; --- prota quieto derecha bomba
				; color 1
sprites5:		DB $00,$0F,$1F,$5F,$B7,$4E,$A6,$87
				DB $4F,$3F,$44,$34,$0F,$08,$03,$00
				DB $00,$F8,$FC,$CC,$28,$28,$04,$04
				DB $08,$F0,$D0,$28,$F8,$48,$E0,$00
				; color 2
				DB $00,$3B,$0B,$00,$07,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$20,$D0,$00,$B0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$48,$31,$59,$78,$30
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$30,$D0,$D0,$F8,$F8,$F0
								; 
				; --- prota andando derecha bomba
				; color 1
sprites6:		DB $07,$0F,$2F,$5B,$27,$53,$43,$27
				DB $1F,$22,$12,$0F,$08,$18,$1E,$00
				DB $F8,$FC,$8C,$58,$58,$04,$84,$88
				DB $F8,$D8,$24,$FC,$66,$AE,$1C,$00
				; color 5
				DB $1D,$0D,$00,$07,$07,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $20,$D8,$00,$98,$10,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$24,$18,$2C,$3C,$18,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$70,$A0,$A0,$F8,$78,$70,$00
				; 
				; --- prota quieto izquierda bomba
				; color 1
sprites7:		DB $00,$1F,$3F,$33,$14,$14,$20,$20
				DB $10,$0F,$0B,$14,$1F,$12,$07,$00
				DB $00,$F0,$F8,$FA,$ED,$72,$65,$E1
				DB $F2,$FC,$22,$2C,$F0,$10,$C0,$00
				; color 2
				DB $00,$04,$0B,$00,$0D,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$DC,$D0,$00,$E0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$0C,$0B,$0B,$1F,$1F,$0F
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$12,$8C,$9A,$1E,$0C
				; 
				; --- prota andando izquierda bomba
				; color 1
sprites8:		DB $1F,$3F,$31,$1A,$1A,$20,$21,$11
				DB $1F,$1B,$24,$3F,$66,$75,$38,$00
				DB $E0,$F0,$F4,$DA,$E4,$CA,$C2,$E4
				DB $F8,$44,$48,$F0,$10,$18,$78,$00
				; color 5
				DB $04,$1B,$00,$19,$08,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $B8,$B0,$00,$E0,$E0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$0E,$05,$05,$1F,$1E,$0E,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$24,$18,$34,$3C,$18,$00
				;
sprites17:		; --- altern prota subir bomba uno
				; color 1
				DB $00,$07,$BF,$4F,$97,$87,$4F,$9F
				DB $7F,$5D,$4B,$28,$1C,$17,$10,$00
				DB $00,$E0,$F0,$F8,$F8,$F8,$F8,$F0
				DB $F8,$FC,$D4,$14,$38,$E8,$08,$70
				; color 2
				DB $22,$34,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$28,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$30,$68,$78,$30,$60,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- altern prota subir bomba dos
				; color 1
				DB $00,$03,$07,$BF,$4F,$97,$87,$4F
				DB $7F,$3D,$2B,$28,$1C,$17,$10,$0E
				DB $00,$E0,$F0,$F8,$F8,$FC,$FA,$F2
				DB $FE,$FA,$D2,$14,$38,$E8,$08,$00
				; color 2
				DB $02,$14,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $04,$2C,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$30,$68,$78,$30,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$04,$0C,$00
				; 
				; --- prota quieto derecha cuchillo
				; color 1
sprites9:		DB $00,$07,$0F,$17,$23,$23,$23,$7F
				DB $4B,$3F,$22,$24,$1F,$08,$03,$00
				DB $00,$F8,$FC,$CC,$A8,$28,$04,$84
				DB $88,$F0,$D0,$28,$F8,$48,$E0,$00
				; color 5
				DB $00,$1D,$1B,$00,$07,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$20,$D0,$00,$B0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$08,$1C,$1C,$1C,$00,$34
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$30,$50,$D0,$F8,$78,$70
				; 
				; --- prota andando derecha cuchillo
				; color 1
sprites10:		DB $07,$0F,$17,$23,$23,$23,$7F,$45
				DB $3F,$22,$24,$1F,$08,$18,$1E,$00
				DB $F8,$FC,$8C,$58,$58,$04,$84,$88
				DB $F8,$C8,$44,$FC,$66,$AE,$1C,$00
				; color 5
				DB $1D,$1B,$00,$07,$07,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $30,$B8,$00,$98,$50,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$08,$1C,$1C,$1C,$00,$3A,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$70,$A0,$A0,$F8,$78,$70,$00
				; 
				; --- prota quieto izquierda cuchillo
				; color 1
sprites11:		DB $00,$1F,$3F,$33,$15,$14,$20,$21
				DB $11,$0F,$0B,$14,$1F,$12,$07,$00
				DB $00,$E0,$F0,$E8,$C4,$C4,$C4,$FE
				DB $D2,$FC,$44,$24,$F8,$10,$C0,$00
								; color 5
				DB $00,$04,$0B,$00,$0D,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$B8,$D8,$00,$E0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$0C,$0A,$0B,$1F,$1E,$0E
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$10,$38,$38,$38,$00,$2C
				; 
				; --- prota andando izquierda cuchillo
				; color 1
sprites12:		DB $1F,$3F,$31,$1A,$1A,$20,$21,$11
				DB $1F,$13,$22,$3F,$66,$75,$38,$00
				DB $E0,$F0,$E8,$C4,$C4,$C4,$FE,$A2
				DB $FC,$44,$24,$F8,$10,$18,$78,$00
								; color 5
				DB $0C,$1D,$00,$19,$0A,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $B8,$D8,$00,$E0,$E0,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$0E,$05,$05,$1F,$1E,$0E,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$10,$38,$38,$38,$00,$5C,$00
sprites18:		; --- altern prota subir cuchillo uno
				; color 1
				DB $00,$27,$5F,$9F,$9F,$9F,$FF,$AF
				DB $7F,$5D,$4B,$28,$1C,$17,$10,$00
				DB $00,$E0,$F0,$F8,$F8,$F8,$F8,$F0
				DB $F8,$FC,$D4,$14,$38,$E8,$08,$70
				; color 2
				DB $22,$34,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$28,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$20,$60,$60,$60,$00,$50,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- altern prota subir cuchillo dos
				; color 1
				DB $00,$07,$0F,$1F,$3F,$5F,$5F,$5F
				DB $7F,$7D,$2B,$28,$1C,$17,$10,$0E
				DB $00,$E0,$F0,$F8,$F8,$FC,$FA,$F2
				DB $FE,$FA,$D2,$14,$38,$E8,$08,$00
				; color 2
				DB $02,$14,$17,$03,$08,$0F,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $04,$2C,$E8,$C0,$10,$F0,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$20,$20,$20,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$04,$0C,$00
			
				; --- petiso quieto
				; color 1
sprites_pet:	DB $01,$02,$04,$04,$0F,$10,$10,$0F
				DB $08,$10,$10,$10,$14,$0C,$13,$0C
				DB $C0,$30,$08,$08,$08,$90,$B0,$18
				DB $08,$44,$2C,$14,$04,$38,$E4,$38
				; color 4
				DB $00,$00,$00,$02,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$80,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 10
				DB $00,$00,$03,$01,$00,$00,$0E,$00
				DB $07,$0F,$0F,$0F,$0B,$03,$08,$00
				DB $00,$00,$C0,$60,$E0,$60,$40,$C0
				DB $E0,$B0,$C0,$E0,$E0,$00,$10,$00
				; color 11
				DB $00,$01,$00,$00,$00,$0F,$01,$00
				DB $00,$00,$00,$00,$00,$00,$04,$00
				DB $00,$C0,$30,$10,$10,$00,$00,$20
				DB $10,$08,$10,$08,$18,$C0,$08,$00
				; 
				; --- petiso salto
				; color 1
				DB $01,$02,$04,$04,$0F,$10,$10,$0F
				DB $08,$10,$10,$30,$48,$3C,$07,$00
				DB $C0,$30,$08,$08,$08,$96,$B9,$02
				DB $04,$1C,$04,$0C,$12,$3C,$C0,$00
				; color 4
				DB $00,$00,$00,$02,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$80,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 10
				DB $00,$00,$03,$01,$00,$08,$0E,$00
				DB $07,$0F,$0F,$0F,$27,$03,$00,$00
				DB $00,$00,$C0,$60,$E0,$60,$44,$F8
				DB $F0,$E0,$F0,$E0,$C8,$00,$00,$00
				; color 11
				DB $00,$01,$00,$00,$00,$07,$01,$00
				DB $00,$00,$00,$00,$10,$00,$00,$00
				DB $00,$C0,$30,$10,$10,$00,$02,$04
				DB $08,$00,$08,$10,$24,$C0,$00,$00
				; --- exp 1
				; color 1
sprites_exp:	DB $78,$84,$9C,$AA,$99,$A4,$9A,$84
				DB $79,$0A,$04,$00,$00,$00,$00,$00
				DB $1E,$21,$2D,$5D,$91,$2E,$68,$28
				DB $90,$52,$25,$02,$00,$00,$00,$00
				; color 6
				DB $00,$70,$60,$00,$44,$03,$61,$73
				DB $04,$00,$00,$00,$00,$00,$00,$00
				DB $00,$1C,$00,$00,$4C,$80,$00,$C0
				DB $40,$00,$02,$00,$00,$00,$00,$00
				; color 9
				DB $00,$08,$00,$44,$22,$40,$00,$08
				DB $02,$04,$00,$00,$00,$00,$00,$00
				DB $00,$02,$12,$22,$22,$50,$90,$10
				DB $20,$20,$00,$00,$00,$00,$00,$00
				; --- exp 2
				; color 1
				DB $1C,$22,$2E,$24,$2D,$22,$2D,$22
				DB $1D,$04,$02,$00,$00,$00,$00,$00
				DB $38,$44,$54,$34,$A4,$58,$50,$50
				DB $A0,$22,$45,$02,$00,$00,$00,$00
				; color 6
				DB $00,$18,$10,$00,$12,$01,$10,$19
				DB $02,$00,$00,$00,$00,$00,$00,$00
				DB $00,$30,$00,$00,$10,$80,$00,$80
				DB $00,$00,$02,$00,$00,$00,$00,$00
				; color 9
				DB $00,$04,$00,$12,$00,$10,$00,$04
				DB $00,$02,$00,$00,$00,$00,$00,$00
				DB $00,$08,$28,$48,$48,$20,$A0,$20
				DB $40,$40,$00,$00,$00,$00,$00,$00
				; --- exp 3
				; color 1
				DB $01,$02,$02,$02,$02,$02,$02,$02
				DB $02,$02,$01,$00,$00,$00,$00,$00
				DB $80,$40,$40,$40,$40,$40,$40,$40
				DB $40,$42,$85,$02,$00,$00,$00,$00
				; color 6
				DB $00,$01,$01,$01,$01,$01,$01,$01
				DB $01,$01,$00,$00,$00,$00,$00,$00
				DB $00,$80,$00,$00,$00,$00,$00,$00
				DB $00,$80,$02,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$80,$80,$80,$80,$80,$80
				DB $80,$00,$00,$00,$00,$00,$00,$00
				; --- exp 4
				; color 1
				DB $1C,$22,$2A,$2C,$25,$1A,$0A,$0A
				DB $05,$04,$02,$00,$00,$00,$00,$00
				DB $38,$44,$74,$24,$B4,$44,$B4,$44
				DB $B8,$22,$45,$02,$00,$00,$00,$00
				; color 6
				DB $00,$0C,$00,$00,$08,$01,$00,$01
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$18,$08,$00,$48,$80,$08,$98
				DB $40,$00,$02,$00,$00,$00,$00,$00
				; color 9
				DB $00,$10,$14,$12,$12,$04,$05,$04
				DB $02,$02,$00,$00,$00,$00,$00,$00
				DB $00,$20,$00,$48,$00,$08,$00,$20
				DB $00,$40,$00,$00,$00,$00,$00,$00
				; --- exp 5
				; color 1
				DB $78,$84,$B4,$BA,$89,$74,$16,$14
				DB $09,$0A,$04,$00,$00,$00,$00,$00
				DB $1E,$21,$39,$55,$99,$25,$59,$21
				DB $9E,$52,$25,$02,$00,$00,$00,$00
				; color 6
				DB $00,$38,$00,$00,$32,$01,$00,$03
				DB $02,$00,$00,$00,$00,$00,$00,$00
				DB $00,$0E,$06,$00,$22,$C0,$86,$CE
				DB $20,$00,$02,$00,$00,$00,$00,$00
				; color 9
				DB $00,$40,$48,$44,$44,$0A,$09,$08
				DB $04,$04,$00,$00,$00,$00,$00,$00
				DB $00,$10,$00,$22,$44,$02,$00,$10
				DB $40,$20,$00,$00,$00,$00,$00,$00

sprites_bomb_a:	; --- bombero mano 1
				; color 1
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$18,$24
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $60,$50,$C8,$88,$78,$48,$88,$90
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$18
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$20,$30,$70,$00,$00,$00,$00
				; color 11
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$30,$70,$60
				; 
				; --- bombero mano 2
				; color 1
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$18,$24
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$60,$90
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$18
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$60
				; color 13
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- bombero mano 3
				; color 1
				DB $00,$00,$00,$00,$01,$02,$06,$0A
				DB $17,$2E,$3D,$2E,$1E,$13,$2E,$31
				DB $00,$00,$00,$00,$C0,$20,$30,$28
				DB $F4,$3A,$DE,$3A,$3C,$E4,$3A,$C6
				; color 9
				DB $00,$00,$00,$00,$00,$01,$01,$05
				DB $08,$11,$02,$11,$01,$00,$00,$0E
				DB $00,$00,$00,$00,$00,$C0,$C0,$D0
				DB $08,$C4,$20,$C4,$C0,$00,$00,$38
				; color 11
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$0C,$10,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$18,$04,$00
				; 
				; --- bombero mano 4
				; color 1
				DB $00,$00,$00,$00,$01,$02,$06,$0A
				DB $17,$2E,$3D,$2E,$1E,$13,$2E,$31
				DB $00,$00,$00,$00,$C0,$20,$30,$28
				DB $F4,$3A,$DE,$3A,$3C,$E4,$3A,$C6
				; color 9
				DB $00,$00,$00,$00,$00,$01,$01,$05
				DB $08,$11,$02,$11,$01,$00,$00,$0E
				DB $00,$00,$00,$00,$00,$C0,$C0,$D0
				DB $08,$C4,$20,$C4,$C0,$00,$00,$38
				; color 11
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$0C,$10,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$00,$18,$04,$00
				; 
				; --- bombero mano 5
				; color 1
				DB $00,$01,$02,$06,$0E,$12,$2F,$3C
				DB $2E,$1D,$1E,$27,$1E,$13,$3E,$3E
				DB $00,$C0,$20,$30,$38,$24,$FA,$1E
				DB $3A,$DC,$38,$E8,$24,$E4,$B8,$C4
				; color 9
				DB $00,$00,$01,$01,$01,$0D,$10,$03
				DB $11,$02,$01,$18,$00,$00,$00,$00
				DB $00,$00,$C0,$C0,$C0,$D8,$04,$E0
				DB $C4,$20,$C0,$00,$00,$00,$00,$38
				; color 11
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$00,$01,$0C,$01,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$10,$D8,$18,$44,$00
quemado_esp:	; --- ALTERN QUEMANDOSE UNO ESPAÑOL
				; color 1
				DB $EE,$8A,$AA,$AA,$EE,$00,$0F,$0E
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $EE,$2A,$4A,$8A,$EE,$00,$E0,$E0
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 6
				DB $00,$00,$00,$14,$10,$1F,$10,$11
				DB $1F,$3F,$3F,$3C,$1E,$98,$D0,$F0
				DB $00,$00,$00,$20,$10,$F8,$18,$1C
				DB $F6,$F6,$7E,$FE,$77,$77,$23,$1F
				; color 10
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$03,$01,$07,$2F,$0F
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$80,$00,$88,$88,$DC,$E0
pausa_sprit:	; --- pausa prota uno
				; color 1
				DB $00,$60,$A3,$A7,$AF,$AD,$AD,$AC
				DB $FC,$9E,$BF,$77,$24,$1C,$3F,$39
				DB $00,$00,$F0,$F8,$9C,$AC,$2C,$0C
				DB $CC,$1C,$F8,$F4,$CC,$88,$FE,$8E
				; color 2
				DB $08,$1B,$03,$00,$06,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $08,$30,$70,$00,$70,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$00,$40
				DB $40,$40,$42,$42,$43,$03,$61,$40
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $00,$60,$50,$D0,$F0,$30,$E0,$00
				; 
				; --- pausa prota dos
				; color 1
				DB $50,$A8,$53,$27,$06,$0D,$0B,$16
				DB $3E,$27,$37,$1B,$12,$0E,$3F,$39
				DB $20,$EC,$FC,$7E,$CF,$07,$9F,$26
				DB $27,$0C,$F8,$F4,$CC,$8C,$FE,$8E
				; color 2
				DB $04,$0D,$01,$00,$06,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $08,$30,$70,$00,$70,$00,$00,$00
				DB $00,$00,$00,$00,$00,$00,$00,$00
				; color 9
				DB $00,$00,$00,$00,$00,$00,$50,$20
				DB $00,$01,$02,$04,$09,$01,$18,$08
				DB $00,$00,$00,$00,$00,$00,$00,$00
				DB $80,$30,$F8,$60,$D8,$D8,$F0,$00
	;
sprites_ojos:	; --- ojo izquierda 1
				; color 8
				DB $00,$00,$14,$0A,$1B,$0E,$1F,$0D
				DB $01,$00,$00,$00,$00,$00,$00,$00
				DB $00,$00,$00,$A0,$60,$48,$A0,$90
				DB $E0,$E0,$40,$00,$00,$00,$00,$00
				; 
				; --- ojo izquierda 2
				; color 8
				DB $0A,$04,$19,$0E,$1D,$0E,$1F,$0F
				DB $07,$03,$00,$00,$00,$00,$00,$00
				DB $00,$00,$40,$E0,$40,$AC,$D8,$A0
				DB $E0,$E0,$40,$00,$00,$00,$00,$00
				; 
				; --- ojo derecha 1
				; color 8
				DB $00,$00,$00,$05,$06,$12,$05,$09
				DB $07,$07,$02,$00,$00,$00,$00,$00
				DB $00,$00,$28,$50,$D8,$70,$F8,$B0
				DB $80,$00,$00,$00,$00,$00,$00,$00
				; 
				; --- ojo derecha 2
				; color 8
				DB $00,$00,$02,$07,$02,$35,$1B,$05
				DB $07,$07,$02,$00,$00,$00,$00,$00
				DB $50,$20,$98,$70,$B8,$70,$F8,$F0
				DB $E0,$C0,$00,$00,$00,$00,$00,$00
				
;sprites_oniric:	; 
				; --- oniric 1
				; color 1
;				DB $00,$00,$03,$0F,$1F,$1E,$1F,$0F
;				DB $1F,$1C,$19,$39,$3D,$37,$25,$2E
;				DB $00,$00,$80,$00,$00,$F8,$5D,$A7
;				DB $F2,$F8,$2D,$3F,$1A,$87,$ED,$F8
				; 
				; --- oniric 2
				; color 1
;				DB $00,$00,$0E,$07,$07,$FB,$D7,$2F
;				DB $7F,$FB,$A4,$E4,$D5,$0F,$BD,$FB
;				DB $00,$00,$00,$80,$C0,$C0,$C0,$80
;				DB $C0,$C0,$C0,$E0,$E0,$60,$20,$A0	
				; --- oniric 3
				; color 1
;				DB $39,$33,$17,$0E,$06,$02,$01,$20
;				DB $70,$D8,$CB,$CB,$CB,$CB,$73,$20
;				DB $D0,$98,$35,$7A,$70,$E0,$B0,$7A
;				DB $1F,$07,$C0,$2F,$2A,$22,$2A,$4F
				; 
				; --- oniric 4
				; color 1
;				DB $5C,$CE,$67,$F3,$73,$3A,$6C,$F0
;				DB $C1,$01,$3C,$B2,$B2,$3C,$B2,$84
;				DB $E0,$60,$40,$80,$00,$00,$80,$98
;				DB $BC,$B4,$30,$B0,$B0,$B4,$B4,$18
							
				
game_over:		db	64,230,224,236,228,64,64,238,245,228,241
se__acabo:		db	64,242,228,64,64,64,224,226,224,225,238
continua_i:		db	229,197,64,64,64,64,226,238,237,243,232,237,244,228
continua_e:		db	229,197,64,64,64,64,226,238,237,243,232,237,244,224
pause:			db	239,224,244,242,228
;test_version:	db	243,228,242,243,64,245,228,241,242,232,238,237		;para version test
ladrillos:		db	20,20,20,20,20										;ladrillos en la zona donde se escribe el pause


										
empresa:		db	28,"CARAMBALpN STUDIOS  PRESENTS"					;PANTALLA DE MENU
empresa_e:		db	28,"CARAMBALpN STUDIOS  PRESENTA"
titulo_1:		db	224,"hih  i  h iih  hih i   h  i hiihxzy  y  x yzx  xzx y   x  y xzzyk k  k  k k k  k k k   k  k k   ajjl k  k ajjl k k k   k  k mjjlk  k k  k k  k k k k   k  k    kk  k k  k k  k k k k   k  k    kmjjb mjjb e  e e mjb   mjjb fjjb"
mensaje:		db	4,"MENr"
mensaje_ING:		db	4,"MENU"
teclado:		db	6,"- EASY"
mando:			db	6,"- HARD"
instrucciones:	db	10,"- LANGUAGE"
teclado_e:		db	7,"- FpCIL"
mando_e:		db	9,"- DIFqCIL"
instruccion_e:	db	8,"- IDIOMA"
salir:			db	12,"- COVER PAGE"
salir_e:		db	9,"- PORTADA"
copyright:		db	28,"(C)  VERSION DEMO DEL  JUEGO"

serp_1:			db	1,"n"
nada:			db	1," "

;programacion:	db	12,"PROGRAMMING:"
;musica:			db	6,"MUSIC:"
;graficos:		db	9,"GRAPHICS:"
;programacion_e:	db	13,"PROGRAMACIsN:"
;musica_e:		db	7,"MtSICA:"
;graficos_e:		db	9,"GRpFICOS:"
;benja:			db	15,"BENJAMrN MIGUEL"
;jorge:			db	12,"JORGE ROMERO"
;mis_chicos:		db	30,"A MIS CHICOS/A DE ASM MSX TEAM"
;ilustraciones:	db	14,"ILUSTRACIONES:"
;salguero:		db	16,"JOSq L. SALGUERO"
;ilustrations:	db	14,"ILLUSTRATIONS:"
;tromax:			db	19,"DAVID F.G. (TROMAX)"
;john:			db	12,"JOHN HASSINK"
;mano_derecha:	db	13,"MANO DERECHA:"
;mano_derecha_e:	db	11,"RIGHT HAND:"
;agradecido:		db	32,"GRACIAS A:        Y RAFA BOLLERO"
;thanks:			db	32,"THANKS TO:      AND RAFA BOLLERO"

letras_A:		DB $00,$3C,$42,$42,$7E,$42,$24,$00
				DB $00,$78,$44,$7C,$42,$42,$7C,$00
				DB $00,$3C,$42,$40,$40,$42,$3C,$00
				DB $00,$78,$44,$42,$42,$44,$38,$00
letras_E:		DB $00,$3C,$42,$40,$78,$42,$3C,$00
				DB $00,$7C,$42,$40,$58,$40,$20,$00
				DB $00,$3C,$42,$40,$4E,$42,$3C,$00
				DB $00,$24,$42,$42,$7E,$42,$24,$00
letras_I:		DB $00,$3C,$52,$10,$10,$52,$3C,$00
				DB $00,$7E,$08,$04,$02,$42,$3C,$00
letras_K:		DB $00,$44,$42,$5C,$42,$42,$24,$00
letras_L:		DB $00,$20,$40,$40,$40,$42,$3C,$00
				DB $00,$24,$5A,$42,$42,$42,$24,$00
letras_N:		DB $00,$24,$52,$52,$4A,$4A,$24,$00
letras_O:		DB $00,$3C,$42,$42,$42,$42,$3C,$00
				DB $00,$7C,$42,$42,$7C,$40,$20,$00
				DB $00,$3C,$42,$42,$4A,$44,$3A,$00
				DB $00,$7C,$42,$42,$3C,$42,$44,$00
letras_S:		DB $00,$3C,$42,$30,$04,$42,$3C,$00
				DB $00,$3C,$42,$10,$10,$08,$08,$00
				DB $00,$24,$42,$42,$42,$42,$3C,$00
				DB $00,$24,$42,$42,$42,$24,$18,$00
letras_W:		DB $00,$24,$42,$42,$42,$5A,$24,$00
				DB $00,$42,$24,$18,$24,$42,$42,$00
				DB $00,$44,$42,$24,$08,$10,$10,$00
				DB $00,$3C,$42,$08,$20,$42,$3C,$00


titulo_centro1:	; --- este/sur, noerte/este, fin oeste, fin sur, fin norte, fin este
				DB $00,$3F,$7F,$7F,$7F,$7C,$7B,$7A
				DB $7A,$FA,$FA,$FA,$FA,$06,$FC,$00
				DB $00,$FC,$FE,$FE,$FA,$06,$FC,$00
				DB $00,$3C,$76,$7A,$7A,$7A,$7A,$7A
				DB $7A,$7A,$7A,$7A,$7A,$76,$3C,$00
				DB $00,$3F,$7F,$7F,$5F,$60,$3F,$00
				DB $00,$7F,$FF,$FF,$FF,$FC,$FB,$FA

fueguito_1:		DB 	$82,$10,$03,$58,$04,$52,$22,$7C
fueguito_2:		DB 	$01,$88,$0A,$94,$11,$8A,$60,$5A
				; --- horizontal, vertical, oeste/sur, noerte/este
				DB 	$00,$FF,$FF,$FF,$FF,$00,$FF,$00
				DB 	$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A
				DB 	$00,$FC,$F6,$FA,$FA,$FA,$FA,$7A
				DB 	$7A,$7B,$7D,$7F,$7F,$7F,$3F,$00


flame_1:		DB 	$08,$1C,$3E,$7F,$7F,$7F,$3E,$1C
flame_2:		DB 	$00,$08,$1C,$3E,$7F,$7F,$3E,$1C
letras_A_acen:	DB 	$0C,$00,$3C,$42,$7E,$42,$24,$00
;				DB 	$0C,$00,$3C,$42,$78,$42,$3C,$00
				DB 	$0C,$00,$3C,$52,$10,$52,$3C,$00
;				DB 	$0C,$00,$3C,$42,$42,$42,$3C,$00
letras_U_acen:	DB 	$0C,$00,$24,$42,$42,$42,$3C,$00

fuego_quema:	DB 	$65,$90,$2A,$55,$A2,$DD,$7A,$7B
				DB 	$2A,$C9,$16,$A4,$5A,$5D,$BE,$7A
				DB 	$82,$D4,$A7,$DA,$0D,$D2,$2B,$7C
fuego_quema_2:	DB 	$79,$65,$7A,$90,$dd,$2a,$a2,$55
				DB 	$7a,$5a,$c9,$be,$2A,$16,$5d,$be
				DB 	$d3,$82,$7c,$D4,$7c,$a7,$0d,$2b
				
parentesis_a:	db	#02,#04,#04,#08,#04,#04,#02,#00						;DEFINICION DE PARENTESIS, GUION Y PUNTO
parentesis_c:	db	#80,#40,#40,#20,#40,#40,#80,#00
guion:			db	#00,#00,#00,#82,#7C,#00,#00,#00
punto:			db	#00,#00,#00,#00,#00,#60,#60,#00

numero0:		DB 	$00,$3C,$42,$10,$4A,$42,$3C,$00
				DB 	$00,$02,$02,$00,$02,$02,$02,$00
				DB 	$00,$7C,$02,$3C,$40,$40,$3E,$00
				DB 	$00,$3C,$02,$3C,$02,$02,$3C,$00
numero4:		DB 	$00,$42,$42,$3C,$02,$02,$02,$00
				DB 	$00,$7C,$80,$7C,$02,$02,$7C,$00
				DB 	$00,$3C,$40,$7C,$42,$42,$3C,$00
				DB 	$00,$7C,$02,$02,$00,$02,$02,$00
numero8:		DB	$00,$3C,$42,$3C,$42,$42,$3C,$00
				DB	$00,$3C,$42,$42,$3C,$02,$3C,$00
dospuntos:		db	#00,#00,#60,#60,#00,#60,#60,#00

agua_1:			DB 	$20,$40,$60,$A3,$1C,$04,$04,$18
chorro_1:		DB 	$2A,$54,$2A,$55,$AA,$55,$AA,$55	
grifo_1:		DB 	$3A,$3C,$7F,$14,$2A,$54,$2A,$55
fuego_1_2:		DB 	$10,$30,$6C,$5E,$3E,$7C,$7A,$34
portal_1:		DB 	$81,$7E,$41,$40,$48,$40,$42,$40
				DB 	$81,$7E,$02,$02,$02,$82,$02,$12
				DB 	$02,$22,$32,$78,$7A,$30,$02,$FA
				DB 	$40,$48,$4C,$1E,$5E,$0C,$40,$5F
cuchillo_1:		db	$a5
bomba_1:		db	$85
salpic_1_1:		db $78,$D0,$C0,$7F,$7F,$C0,$D0,$78
salpic_1_2:		db $1E,$0B,$03,$FE,$FE,$03,$0B,$1E

agua_2:			DB 	$20,$C0,$B0,$09,$0A,$1C,$20,$20
chorro_2:		DB 	$54,$2A,$54,$AA,$55,$AA,$55,$AA
grifo_2:		DB 	$3A,$3C,$7F,$28,$54,$2A,$54,$AA
fuego_2_2:		DB 	$08,$0C,$36,$7A,$7C,$3E,$5E,$2C
portal_2:		DB 	$81,$7E,$40,$50,$42,$40,$40,$41
				DB 	$81,$7E,$02,$22,$02,$22,$02,$02
				DB 	$02,$12,$32,$78,$7A,$30,$02,$FA	
				DB 	$40,$44,$4C,$1E,$5E,$0C,$40,$5F	
cuchillo_2:		db	$f5	
bomba_2:		db	$e5
salpic_2_1:		db $1E,$34,$30,$1F,$1F,$30,$34,$1E
salpic_2_2:		db $78,$2C,$0C,$F8,$F8,$0C,$2C,$78

color_gas_1:	db 	$15,$F5
color_mec_1:	db 	$B5,$f5
color_gas_2:	db 	$65,$F5
color_mec_2:	db 	$95,$f5
color_gas_3:	db 	$F5,$F5
color_mec_3:	db 	$85,$F5
color_gas_4:	db 	$E5,$F5
color_mec_4:	db 	$65,$F5
color_gas_5:	db 	$E5,$F5
color_mec_5:	db 	$F5,$F5
color_gas_6:	db 	$E5,$F5
color_mec_6:	db 	$E5,$F5
color_gas_7:	db 	$15,$F5
color_mec_7:	db 	$E5,$f5
color_gas_8:	db 	$E5
color_mec_8:	db 	$E5











;48KB routines

; ------------------------------
; SETROMPAGE0			
; Posiciona nuestro cartucho en 
; Pagina 0
; -----------------------------

setrompage0:			
				
        				ld		a,(SLOTVAR)		
				        jr		setslotpage0	
				
			
			
; ------------------------------
; RECBIOS
; Posiciona la bios ROM
; -------------------------------
					
recbios:		
        				ld		a,(EXPTBL)
				
			

; ---------------------------
; SETSLOTPAGE0
; Posiciona el slot pasado 
; en pagina 0 del Z80
; A: Formato FxxxSSPP
; ----------------------------
            
setslotpage0:       
	di

	ld      b,a                 ; B = Slot param in FxxxSSPP format                


	in      a,(0A8h)
	and     011111100b
	ld      d,a                 ; D = Primary slot value

	ld      a,b         

	and     03  
	or      d
	ld      d,a                 ; D = Final Value for primary slot 


	out     (0A8h),a

	; Check if expanded
	ld      a,b
	bit     7,a
	ret     z   

	and     03h                             
	rrca
	rrca
	and     011000000b
	ld      c,a                 
	ld      a,d
	and     00111111b
	or      c
	ld      c,a                 ; Primary slot value with main slot in page 3  

	ld      a,b
	and     00001100b
	rrca
	rrca    
	and     03h
	ld      b,a                 ; B = Expanded slot in page 3
	ld      a,c
	out     (0A8h),a            ; Slot : Main Slot, xx, xx, Main slot
	ld      a,(0FFFFh)
	cpl
	and     011111100b
	or      b
	ld      (0FFFFh),a          ; Expanded slot selected 

	ld      c,a

								; Slot Final. Ram, rom c, rom c, Main
	ld      a,d                 ; A = Final value
	out     (0A8h),a

	and     3                   ; Set value in STLTBL 
	ld      de,SLTTBL    
	add     a,e
	ld      e,a
	jr      nc,.nocarry
	inc     d
.nocarry:
	ld      a,c
	ld      (de),a

	ret

COLOR_FINAL:	incbin	"TILES_FINAL.col"
TILES_FINAL:	incbin	"TILES_FINAL.til"
                    
setslotpage0_end:
                
;paso_negro_der:	incbin	"PASO_NEGRO_DERECHA_PLETTER.DAT"
paso_negro_izq:	incbin	"PASO_NEGRO_IZQUIERDA_PLETTER.DAT"				;paso oscuro de 2 pantallas cuando no hay luz
entre_fases:	incbin	"ENTRESAN.DAT"
fase_17:		incbin	"FASE_17_pletter.dat"							
fase_18:		incbin	"FASE_18_pletter.dat"
;fase_19:		incbin	"FASE_19_pletter.dat"   						;por si se libera memoria
FINAL_ING:		incbin	"FINAL_TEMPLO_ingles.dat"
FINAL:			incbin	"FINAL_TEMPLO.dat"

		ds		#C000-$													;rellena hasta fin de la aplicacion
		
		
;VARIABLES						DONDE SE SITUAN							OCUPAN	DESCRIPCION

inicio_ram:						equ	#c000								;0		describe el inicio de variables
		
idioma:							equ	inicio_ram+1						;1		0 ingles 1 castellano 2 catalán

petiso_que_toca:				equ	idioma+1							;1		0 quieto 1 saltando
petisox:						equ	petiso_que_toca+1					;1
petisoy:						equ	petisox+1							;1
espera_petiso:					equ	petisoy+1							;1
espera_petiso_resta:			equ	espera_petiso+1						;1
espera_petiso_resta_2:			equ	espera_petiso_resta+1				;1
y_exp:							equ	espera_petiso_resta_2+1				;1		y de la posicion de exp
valor_suma_resta_exp:			equ	y_exp+1								;1		para sumar y restar a y y crear el efecto de movimiento
direccion_exp:					equ	valor_suma_resta_exp+1				;1		para saber si lo suma o si lo resta
cuenta_gira_exp:				equ	direccion_exp+1						;1		para darle la vuelta
retardo_exp:					equ	cuenta_gira_exp+1					;1		hacer más lenta la secuencia de exp

VIEJA_INTERR:					EQU	retardo_exp+1						;5		le damos 5 bytes para guardar la información que había en la interrupción
fuego_cambia:					equ	VIEJA_INTERR+5						;2		dos posiciones del fuego del menu 1 y 2
fuego_cambiante:				equ	fuego_cambia+2						;1		
y_serp:							equ	fuego_cambiante+1					;1		coordenada y de la sepiente de menu

nivel:							equ	y_serp+1							;1		0 nevel 1 - 1 nivel 2

clock:							equ	nivel+1								;2		variables de tiempo para intercalar menu y creditos
CLOCK:							equ	clock+2								;2		variable de tiempo para cuando hay 2 necearias
px:								equ	CLOCK+2								;1		x prota
py:								equ	px+1								;1		y prota
puede_cambiar_de_direccion:		equ	py+1								;1		0 - no 1 - si
vidas_prota:					equ	puede_cambiar_de_direccion+1		;1		vidas del protagonista
color_prota:					equ	vidas_prota+1						;1		7 - mojado		8 - seco
color_lineas_prota:				equ	color_prota+1						;1		1 - seco		14 - moojado
muerto:							equ	color_lineas_prota+1				;1		0 muerto - 1 vivo
fase_en_la_que_esta:			equ	muerto+1							;1		fase en la que jugamos
estado_prota:					equ	fase_en_la_que_esta+1				;1		0=quieto 1=andando 2=saltando 3=cayendo 4=subiendo/bajando
prev_dir_prota:					equ	estado_prota+1						;1		hacia qué lado miraba antes el prota
salto_pulsado:					equ	prev_dir_prota+1					;1		para que no se pueda saltar mientras se cae o ya se está saltando
pasos_de_salto:					equ	salto_pulsado+1						;1		si está saltando indica cuánto le queda para dejar de saltar
dir_prota:						equ	pasos_de_salto+1					;1		0 derecha 1 izquierda
paso:							equ	dir_prota+1							;1		0 recto 1 andando 2 subiendo A 3 subiendo B
retard_anim:					equ	paso+1								;1		entre 0 y 9
atributos_sprite_general:		equ	retard_anim+1						;48		4 bytes y,x,patron,color PARA 4 SPRITES
tiene_objeto:					equ	atributos_sprite_general+48			;1		0=no 1=bomba 2=cuchillo
px_salida:						equ	tiene_objeto+1						;1		para recordar el punto de la puerta
py_salida:						equ	px_salida+1							;1

x_explosion:					equ	py_salida+1							;1		posición de la explosión al explotar la bomba
y_explosion:					equ	x_explosion+1						;1
estado_de_explosion:			equ	y_explosion+1						;1		0=no 1,2,3 sprites 22,23,24
contador_retardo_explosion:		equ	estado_de_explosion+1				;1

buffer_colisiones:				equ	contador_retardo_explosion+1		;736	para leer las colisiones en RAM ya que es mucho más ràpido
buffer_colisiones_2:			equ	buffer_colisiones+736				;736	la segunda pantalla
pantalla_activa:				equ	buffer_colisiones_2+736				;1		1 = patnalla 1 - 2 = pantalla 2

estado_de_salto:				equ	pantalla_activa+1					;1		1a8-9a20-21a28 salto derecha - 31a38-39a50-51a58 salto izquierda
mechero:						equ	estado_de_salto+1					;1		0 no lo tienes 1 lo tienes
gasolina:						equ	mechero+1							;1		0 no lo tienes 1 lo tienes
posicion_puerta:				equ	gasolina+1							;2		posicion de la puerta
pantalla_puerta:				equ	posicion_puerta+2					;1		pantalla en la que se encuentra 1 o 2
ya_ha_cambiado_puerta:			equ	pantalla_puerta+1					;1		0 está cerrada 1 está abierta
increm:							equ	ya_ha_cambiado_puerta+1				;1		para borrado concreto de vram

tile_a_poner_agua:				equ	increm+1							;1		decide el tile que toca en el agua

score:							equ	tile_a_poner_agua+1					;2		puntos
contador_para_puntuacion:		equ	score+2								;2		compara con score para controlar los tiles a pintar en puntuacion
posicion_del_punto_unidades:	equ contador_para_puntuacion+2			;1		control tile unidades
posicion_del_punto_decenas:		equ	posicion_del_punto_unidades+1		;1		control tile decenas
posicion_del_punto_centenas:	equ	posicion_del_punto_decenas+1		;1		control tile centenas
posicion_del_punto_millares:	equ	posicion_del_punto_centenas+1		;1		control tile unidades de millar
cuenta_puntos_o_no:				equ	posicion_del_punto_millares+1		;1		0 no cuenta 1 si cuenta
cuanto_sumamos_a_score:			equ	cuenta_puntos_o_no+1				;1		para el contador evolutivo

variables_serpiente_1:			equ	cuanto_sumamos_a_score+1			;10		0	-	serp_x_1
																		;		1	-	serp_y_1
																		;		2	-	serp_direcion_1
																		;		3	-	serp_paso_1
																		;		4	-	color_serp_1
																		;		5	-	cont_retardo_serp_1
																		;		6	-	cont_retardo_serp_1_mobil
																		;		7	-	retardo_veloc_serp_1
																		;		8	-	retardo_veloc_serp_1_mobil
																		;		9	-	PANTALLA EN LA QUE ESTA
variables_serpiente_2:			equ	variables_serpiente_1+10			;10		0	-	serp_x_2
																		;		1	-	serp_y_2
																		;		2	-	serp_direcion_2
																		;		3	-	serp_paso_2
																		;		4	-	color_serp_2
																		;		5	-	cont_retardo_serp_2
																		;		6	-	cont_retardo_serp_2_mobil
																		;		7	-	retardo_veloc_serp_2
																		;		8	-	retardo_veloc_serp_2_mobil
																		;		9	-	PANTALLA EN LA QUE ESTA
variables_serpiente_3:			equ	variables_serpiente_2+10			;10		0	-	serp_x_3
																		;		1	-	serp_y_3
																		;		2	-	serp_direcion_3
																		;		3	-	serp_paso_3
																		;		4	-	color_serp_3
																		;		5	-	cont_retardo_serp_3
																		;		6	-	cont_retardo_serp_3_mobil
																		;		7	-	retardo_veloc_serp_3
																		;		8	-	retardo_veloc_serp_3_mobil
																		;		9	-	PANTALLA EN LA QUE ESTA
variables_serpiente_4:			equ	variables_serpiente_3+10			;10		0	-	serp_x_4
																		;		1	-	serp_y_4
																		;		2	-	serp_direcion_4
																		;		3	-	serp_paso_4
																		;		4	-	color_serp_4
																		;		5	-	cont_retardo_serp_4
																		;		6	-	cont_retardo_serp_4_mobil
																		;		7	-	retardo_veloc_serp_4
																		;		8	-	retardo_veloc_serp_4_mobil
																		;		9	-	PANTALLA EN LA QUE ESTA
colision_cuchillo_serp_real:	equ	variables_serpiente_4+10			;1		0	-	no hay colision, 1	-	si la hay															
serp1:							equ	colision_cuchillo_serp_real+1		;1		serpiente 1 1-presente 0-ausente
serp2:							equ	serp1+1								;1		serpiente 2 1-presente 0-ausente
serp3:							equ	serp2+1								;1		serpiente 3 1-presente 0-ausente
serp4:							equ	serp3+1								;1		serpiente 4 1-presente 0-ausente

cont_no_salta_dos_seguidas:		equ	serp4+1								;1		para evitar el doble salto

pasamos_la_fase:				equ	cont_no_salta_dos_seguidas+1		;1		0 estamos jugando 1 pasamos la fase

momento_lanzamiento:			equ	pasamos_la_fase+1					;1		0 no lanza - 1 movm 1 - 2 mov 2 - 3 en órbita
pantalla_cuchillo:				equ	momento_lanzamiento+1				;1		1 o 2
contador_poses_lanzar:			equ	pantalla_cuchillo+1					;1		para retrasar las poses de lanzar
recordar_lo_que_habia:			equ	contador_poses_lanzar+1				;2		guarda el valor de lo que borra si hay que pintar circunstancialmente una cosa
dir_cuchillo:					equ	recordar_lo_que_habia+2				;1		la dirección hacia la que ba el cuchillo
cx:								equ	dir_cuchillo+1						;1		x cuchillo
cy:								equ	cx+1								;1		y cuchillo

escalera_activada:				equ	cy+1								;1		0 no - 1 si
posicion_escalera:				equ	escalera_activada+1					;2		numero de tile que tiene que pintar de la escalera alternativa
contador_escalera:				equ	posicion_escalera+2					;1		retardo para la construccion de la escalaera
limite_escalera					equ	contador_escalera+1					;2		numero de tile en el que tiene que parar de construir
pantalla_escalera:				equ	limite_escalera+2					;1		pantalla en la que está la escalera

OUS_ACTIU:						equ	pantalla_escalera+1					;1		para saber el huevo que está activando
trampa:							equ	OUS_ACTIU+1							;1		cantidad de pasar fases que tienes
inmune_serp:					equ	trampa+1							;1		inmune a las serpientes
inmune_bomb:					equ	inmune_serp+1						;1		inmune a los bomberos

grifo_estado:					equ	inmune_bomb+1						;1		0 - cerrado	1 - abierto


ESTADO_MUSICA:					EQU	grifo_estado+1						;1		0 - apagada y 1 - encendida

vision_estado:					equ	ESTADO_MUSICA+1						;1		0 	-	no ve nada y 1 - lo ve todo

colision_bombero_prota_real:	equ	vision_estado+1						;1		0	-	no hay colision,	1	-	si la hay			
bombero_1:						equ	colision_bombero_prota_real+1		;1		0 	- 	existe				1 	- 	no existe
bombero_control:				equ	bombero_1+1							;13		0	-	x					(0 - 255)
																		;		1	-	y					(0 - 255)
																		;		2	.	velocidad			(1 - 3)
																		;		3	-	cada cuanto para	(0 - 255)
																		;		4	-	tiempo que para		(0 - 255)
																		;		5	-	paso				(0 - quieto	1 - andando)
																		;		6	-	direccion			(0 - derecha)	1 - izquierda)
																		;		7	-	en escalera			(0 - no	1 - si)
																		;		8	-	tiempo para aparecer(0-255)
																		;		9	-	retardo de velocidad(0-10)
																		;		10	-	0 - decide subir 1 - decide bajar 2- decide no utilizar
																		;		11	-	contador de reten para evitar que suba  y baje escaleras de forma seguida
																		;		12	-	pantalla en la que está 1 o 2
																
toca_bombero:					equ	bombero_control+13					;1		0 no saldrá bombero en la siguiente 1 si saldrá
velocidad_paseo_fases:			equ	toca_bombero+1						;1		1 - mas tiempo para leer mensaje 2-menos tiempo
tile_grifo_balsa_1:				equ	velocidad_paseo_fases+1				;2		tile en que se localiza el primer grifo de balsa
tile_grifo_balsa_2:				equ	tile_grifo_balsa_1+2				;2		tile en que se localiza el segundo grifo de balsa
grifos_balsa_cerrados:			equ	tile_grifo_balsa_2+2				;1		0 es cerrado - 1 es abierto
posicion_balsa_desde_grifo:		equ	grifos_balsa_cerrados+1				;2		posición en la que empieza la balsa, desde el grifo en sí
balsa_activa:					equ	posicion_balsa_desde_grifo+2		;1		0 - no 1 - si
balsa_bacia:					equ	balsa_activa+1						;1		0 - se vacio 1 - no se vacio
pantalla_tile_grifo_balsa_1:	equ balsa_bacia+1						;1		pantalla en la que está el grifo 1
pantalla_tile_grifo_balsa_2:	equ	pantalla_tile_grifo_balsa_1+1		;1		pantalla en la que está el grifo 2
pantalla_balsa:					equ	pantalla_tile_grifo_balsa_2+1		;1		pantalla en la que está la balsa
GAME_OVER:						equ	pantalla_balsa+1					;390	MUSICA FIN PARTIDA

MUTE:							EQU	GAME_OVER+390						;117	silencio musical								
MUERTO:							EQU	MUTE+117							;373	MUSICA MUERTO
clock_1:						equ	MUERTO+373							;1		VARIALBLE A DEFINIR
ENTRE_FASES:					equ	clock_1+1							;470	MUSICA ENTRE FASES
sticky:							equ	ENTRE_FASES+470						;1		stick o strig 0 o 1
EFECTOS_BANCO:					equ	sticky+1							;1939	efectos de sonido
posicion_brillo_items:			equ	EFECTOS_BANCO+1939					;1		control para el brillo de los items
GEN_MUSIC:						EQU	posicion_brillo_items+1				;2925	MUSICA INICIO
sigue_pulsando					equ	GEN_MUSIC+2925						;1		controla que no se pulse dos veces seguidas una dirección durante el menu
VDPW99:                         equ  sigue_pulsando + 1
VDPW98:                         equ VDPW99 + 1
valor_a_cambiar_en_tile_v:		equ	VDPW98+1							;1		para controlar el triple cambio de tile con una única variable

