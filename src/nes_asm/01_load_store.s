; ============================================================
; 01_load_store.s — LDA / STA / LDX / STX / LDY / STY
;
; All supported addressing modes for each instruction.
; Note: LDX/STX use Y as index; LDY/STY use X as index.
; ============================================================
.segment "CODE"
.proc examples_load_store

    ; Restore pointer so indirect examples work after any prior corruption
    lda #<scratch
    sta ptr_lo
    lda #>scratch
    sta ptr_hi

; ---- LDA — Load Accumulator ------------------------------------------------

    lda #$42                ; immediate:        A = $42
    lda zp_a                ; zero page:        A = mem[$00]
    ldx #2
    lda zp_a, x             ; zero page,X:      A = mem[$00 + X]
    lda const_table         ; absolute:         A = mem[const_table]   = $11
    ldx #3
    lda const_table, x      ; absolute,X:       A = mem[const_table+3] = $44
    ldy #5
    lda const_table, y      ; absolute,Y:       A = mem[const_table+5] = $66
    ldx #0
    lda (ptr_lo, x)         ; (indirect,X):     addr = {mem[ptr_lo+1], mem[ptr_lo]}; A = mem[addr]
    ldy #0
    lda (ptr_lo), y         ; (indirect),Y:     addr = {mem[ptr_lo+1], mem[ptr_lo]}; A = mem[addr+Y]

; ---- STA — Store Accumulator (no immediate mode) ----------------------------

    lda #$BB
    sta zp_b                ; zero page:        mem[zp_b] = $BB
    ldx #1
    sta zp_arr, x           ; zero page,X:      mem[zp_arr+1] = $BB
    sta scratch             ; absolute:         mem[scratch] = $BB
    ldx #2
    sta scratch, x          ; absolute,X:       mem[scratch+2] = $BB
    ldy #3
    sta scratch, y          ; absolute,Y:       mem[scratch+3] = $BB
    ldx #0
    sta (ptr_lo, x)         ; (indirect,X):     mem[addr from ptr_lo] = $BB
    ldy #4
    sta (ptr_lo), y         ; (indirect),Y:     mem[addr from ptr_lo + 4] = $BB

; ---- LDX — Load X  (indexed modes use Y, not X) -----------------------------

    ldx #$0F                ; immediate:        X = $0F
    ldx zp_a                ; zero page:        X = mem[zp_a]
    ldy #1
    ldx zp_a, y             ; zero page,Y:      X = mem[zp_a + Y]   (Y, not X!)
    ldx const_table         ; absolute:         X = mem[const_table] = $11
    ldx const_table, y      ; absolute,Y:       X = mem[const_table+1] = $22

; ---- STX — Store X  (no absolute,Y) -----------------------------------------

    stx zp_b                ; zero page:        mem[zp_b] = X
    ldy #2
    stx zp_arr, y           ; zero page,Y:      mem[zp_arr+2] = X
    stx scratch             ; absolute:         mem[scratch] = X

; ---- LDY — Load Y  (indexed modes use X, not Y) -----------------------------

    ldy #$05                ; immediate:        Y = $05
    ldy zp_a                ; zero page:        Y = mem[zp_a]
    ldx #1
    ldy zp_a, x             ; zero page,X:      Y = mem[zp_a + X]   (X, not Y!)
    ldy const_table         ; absolute:         Y = mem[const_table] = $11
    ldy const_table, x      ; absolute,X:       Y = mem[const_table+1] = $22

; ---- STY — Store Y  (no absolute,X) -----------------------------------------

    sty zp_b                ; zero page:        mem[zp_b] = Y
    ldx #2
    sty zp_arr, x           ; zero page,X:      mem[zp_arr+2] = Y
    sty scratch             ; absolute:         mem[scratch] = Y

    rts
.endproc
