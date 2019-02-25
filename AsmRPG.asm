#	SINGLE ROOM, SINGLE ENEMY, TEXT RPG
#	programmed by gallorob

	.data
#	Messages text strings
intro:	.asciiz	"You find yourself in a dark and dank room, a torch barely lights the place.\nWhat will you do?\n\n\n\n\n\n\n\n"
nomons:	.asciiz	"The room is empty, there is just green blood on the floor.\n\n\n\n\n\n\n\n\n"
mons:	.asciiz	"In the middle of the room there's a ferocious sword-branding goblin, ready to attack you!\n\n\n\n\n\n\n\n\n"
atk1:	.asciiz	"You hit the enemy for a total of "
atk2:	.asciiz	" damage!\n"
atk3:	.asciiz	"You get hit for a total of "
atk4:	.asciiz	" damage!\n\n\n\n\n\n\n\n"
heal:	.asciiz	"You cure yourself for a total of 5 HP\n"
fail:	.asciiz	"You don't have enought mana points to heal yourself! Loose a turn!\n"
ovr:	.asciiz	"You fully restore your life!\n"
win0:	.asciiz	"With a last slash, the enemy tumbles and dies within seconds.\nYou gain "
win1:	.asciiz	" EP!\n\n\n\n\n\n\n"
dft:	.asciiz	"Exhausted, you can't parry the enemy's last attack and his weapon cuts through your guts!\nYou die in agony after a few seconds.\n\n\n\n\n\n"
ex_m:	.asciiz	"\n\n\n\n GAME OVER \n\n\n\n\n"

#	Actions text strings
act0:	.asciiz	"[I]nspect the room, check your [S]tatus or [E]xit?"
act1:	.asciiz	"[A]ttack, heal with [M]agic or check your [S]tatus?"
ret:	.asciiz	"Press [Z] to go back"
cont:	.asciiz	"Press [Z] to continue"
cont1:	.asciiz	"Press a button to continue..."

#	status strings
stat0:	.asciiz	"Player's current status: \nHealth: "
stat1:	.asciiz	"/18 \nMana: "
stat2:	.asciiz	"/75 \nExp: "
stat3:	.asciiz	"/100 \nBase damage: "
stat4:	.asciiz	"/10 \n\n\n\n\n"

#	Dati per il gioco
buffer:	.space	2
room0:	.byte	1
player:	.byte	0x12, 0x4b, 0x19, 0x3	# HP(18), Mana(75), Exp(25), BaseDamage(3)
mnstr1:	.byte	0x10, 0x2, 0x14	# HP(16), BaseDamage(2), Exp(20)


	.text
		.globl start
		
start:
#	Load intro
		la	$a0, intro
		li	$v0, 4
		syscall
		la	$a0, act0
		syscall
#	Parse input command		
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
		lbu	$t0, ($a0)
		
		beq	$t0, 'e', exit
		beq	$t0, 'i', inspect
		beq	$t0, 's', st0
		b	start

exit:
#	Print endgame string and exit program
		la	$a0, ex_m
		li 	$v0, 4
		syscall
		li	$v0, 10
		syscall

st0:	jal	status
		b	start

status:
#	Nested call to load player's data
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal load_player
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
#	Print player's data
		li	$v0, 4
		la	$a0, stat0
		syscall
		li	$v0, 1
		move	$a0, $s1
		syscall
		li	$v0, 4
		la	$a0, stat1
		syscall
		li	$v0, 1
		move	$a0, $s2
		syscall
		li	$v0, 4
		la	$a0, stat2
		syscall
		li	$v0, 1
		move	$a0, $s3
		syscall
		li	$v0, 4
		la	$a0, stat3
		syscall
		li	$v0, 1
		move	$a0, $s4
		syscall
		li	$v0, 4
		la	$a0, stat4
		syscall
#	Get any input to continue				
		li	$v0, 4
		la	$a0, cont1
		syscall
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
#	Go back to start		
		jr	$ra

inspect:
#	Read from memory if room is empty (0) or if there's an enemy (1)
		la	$a0, room0
		lbu	$t0, ($a0)
		bnez	$t0, fight
#	Print that there are no monsters		
		la	$a0, nomons
		li	$v0, 4
		syscall
		la	$a0, cont
		syscall
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
		lbu	$t0, ($a0)
#	Loops until 'z' is pressed, otherwise go back to start		
		beq	$t0, 'z', start
		b	inspect

fight:
#	Fighting routine
#	Print message and player's possible choices
		la	$a0, mons
		li	$v0, 4
		syscall
		la	$a0, act1
		syscall
#	Nested call for command routine		
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
		lbu	$t0, ($a0)
#	Option 1: attack		
		beq	$t0, 'a', atk
#	Option 2: heal with magic
		beq	$t0, 'm', magic
#	Option 3: check status
		beq	$t0, 's', st1
#	Debug: "z" to go back to start
		beq	$t0, 'z', r0
#	Loop
		b	fight

r0:
#	Debugging mini-routine
		b	start

st1:	
#	Nested call to status (no need to change $ra)
		jal 	status
		b	fight
		
atk:
#	Figthing routine (one turn for player and monster each)
#	Nested call to load player's and monster's data
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal load_player
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal load_monster
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
#	Random value to add to player's attack		
		li	$a1, 6
		li	$v0, 42
		syscall
#	Execute player's attack and print messages
		move	$t0, $a0
		add	$t0, $t0, $s4
		sub	$s5, $s5, $t0
		la	$a0, atk1
		li	$v0, 4
		syscall
		move	$a0, $t0
		li	$v0, 1
		syscall
		la	$a0, atk2
		li	$v0, 4
		syscall
#	Update memory value of monster's health and check winning condition
		la	$s0, mnstr1
		sb	$s5, 0($s0)
		blez	$s5, win
#	Random value to add to monster's attack
		li	$a1, 3
		li	$v0, 42
		syscall
#	Execute monster's attack and print messages
		move	$t0, $a0
		add	$t0, $t0, $s6
		sub	$s1, $s1, $t0
		la	$a0, atk3
		li	$v0, 4
		syscall
		move	$a0, $t0
		li	$v0, 1
		syscall
#	Update memory value of player's health and check losing condition
		la	$s0, player
		sb	$s1, 0($s0)
		blez	$s1, defeat
#	Print last string
		la	$a0, atk4
		li	$v0, 4
		syscall
#	Print 'any button' continue
		la	$a0, cont1
		syscall
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
#	Go back to fighting
		b 	fight

magic:
#	Magic healing routine (for player) and single attack (for monster)
#	Nested call to load player's and monster's data
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal load_player
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
		addi	$sp, $sp, -4
		sw	$ra, 0($sp)
		jal load_monster
		lw	$ra, 0($sp)
		addi	$sp, $sp, 4
#	Check player's available mana
		ble	$s2, 20, hfail
#	Update mana (-20 for each healing)
		subi	$s2, $s2, 20
		la	$s0, player
		sb	$s2, 1($s0)
#	Check player's HP
		move	$t0, $s1
		add	$t0 $t0, 5
		li	$t1, 18
		bgt	$t0, $t1, over
#	Update player's HP
		move	$s1, $t0
		sb	$s1, 0($s0)
#	Print successfull healing
		la	$a0, heal
		li	$v0, 4
		syscall
#	Continue to mag_1
		b	mag_1
	
hfail:
#	Mana available is less than 20 -> healing fails
#	Print message
		la	$a0, fail
		li	$v0, 4
		syscall
#	Continue to mag_1
		b	mag_1
		
over:
#	HP+5 > 18 -> HP is fully restored
#	Set HP to 18 and print message
		li	$s1, 18
		la	$a0, ovr
		li	$v0, 4
		syscall
#	Continue to mag_1
		b	mag_1

mag_1:
#	Enemy attacking turn routine
#	Random value to add to monster's attack
		li	$a1, 3
		li	$v0, 42
		syscall
#	Execute monster's attack and print messages
		move	$t0, $a0
		add	$t0, $t0, $s6
		sub	$s1, $s1, $t0
		la	$a0, atk3
		li	$v0, 4
		syscall
		move	$a0, $t0
		li	$v0, 1
		syscall
#	Update memory value of player's health and check losing condition
		la	$s0, player
		sb	$s1, 0($s0)
		blez	$s1, defeat
#	Print last string
		la	$a0, atk4
		li	$v0, 4
		syscall
#	Print 'any button' continue
		la	$a0, cont1
		syscall
		li	$a1, 2
		la	$a0, buffer
		li	$v0, 8
		syscall
#	Go back to fighting
		b 	fight

win:
#	Winning routine
#	Print winning message
		li	$v0, 4
		la	$a0, win0
		syscall
#	Add EP and update memory values
		la	$s0, player
		add	$s3, $s3, $s7
		move	$a0, $s7
		sb	$s3, 2($s0)
		li	$v0, 1
		syscall
		la	$a0, win1
		li	$v0, 4
		syscall
		la	$a0, cont1
		syscall
		li	$v0, 8
		syscall
#	Update room status (-> 0, no monsters)
		la	$a0, room0
		li	$t0, 0
		sb	$t0, 0($a0)
#	Go back to start
		b 	start

defeat:
#	Defeat routine
#	Print messages
		la	$a0, atk2
		li	$v0, 4
		syscall
		la	$a0, dft
		syscall
		la	$a0, cont1
		syscall
		li	$v0, 8
		syscall
#	Leave game
		b	exit

load_player:
#	Load player's data from memory
		la	$s0, player	
		lb	$s1, 0($s0)	# HP
		lb	$s2, 1($s0)	# Mana
		lb	$s3, 2($s0)	# Exp
		lb	$s4, 3($s0)	# Base damage
#	Go back to calling routine
		jr	$ra

load_monster:
#	Load monster's data from memory
		la	$s0, mnstr1	
		lb	$s5, 0($s0)	# HP
		lb	$s6, 1($s0)	# Base damage
		lb	$s7, 2($s0)	# Exp
#	Go back to calling routine	
		jr	$ra