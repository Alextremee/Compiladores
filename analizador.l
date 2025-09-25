%option noyywrap yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int clase;
    int valor;
} token;

typedef struct {
    int  pos;
    char *nom;
    int  tipo;
} Simbolo;

typedef struct {
    int  pos;
    char *dato;
} Literal;

#define TABLA 1000

Simbolo tabladeSimbolos[TABLA];
int     possimbolo = 0;

Literal tabladeCadenas[TABLA];
int     posCadena = 0;

Literal tabladeReales[TABLA];
int     posReales = 0;

void Token(int clase, int valor);
int  buscar(const char *id);
int  insertarSimbolo(const char *s);
int  insertarCadena(const char *cadena);
int  insertarReal(const char *real);
void mostrarTablaDeSimbolos(void);
void mostrarTablasDeLiterales(void);

extern FILE *yyin;
extern int   yylineno;

static void tablaLlena(const char *msg) { fputs(msg, stderr); exit(1); }
%}

digito     [0-9]
letra_min  [a-z]

%%

[ \t\r\n]+          { }
\"([^"\n]|\\.)*\"   { }

"cadena"    { Token(0, 0); }
"caso"      { Token(0, 1); }
"entero"    { Token(0, 2); }
"flotante"  { Token(0, 3); }
"hacer"     { Token(0, 4); }
"mientras"  { Token(0, 5); }
"ocaso"     { Token(0, 6); }
"para"      { Token(0, 7); }
"predet"    { Token(0, 8); }
"salir"     { Token(0, 9); }
"select"    { Token(0,10); }
"si"        { Token(0,11); }
"vacio"     { Token(0,12); }

[+\-]?{digito}+     { Token(1, atoi(yytext)); }

{letra_min}+(_{letra_min}+)*(_{digito}+|{digito}+)? {
    int pos = buscar(yytext);
    if (pos < 0) pos = insertarSimbolo(yytext);
    Token(2, pos);
}

[+\-]?{digito}+@{digito}+(@@[+\-]?{digito}+)? {
    int idx = insertarReal(yytext);
    Token(6, idx);
}
"¿"([^?\n]|\\.)*"?"               {
    int idx = insertarCadena(yytext);
    Token(7, idx);
}

"<<="   { Token(3, 6); }
">>="   { Token(3, 7); }
"*="    { Token(3, 1); }
"/="    { Token(3, 2); }
"+="    { Token(3, 3); }
"-="    { Token(3, 4); }
"%="    { Token(3, 5); }
"&="    { Token(3, 8); }
"^="    { Token(3, 9); }
"|="    { Token(3,10); }
"="     { Token(3, 0); }

"\\\\"  { Token(5, 0); }
"//"    { Token(5, 1); }
"||"    { Token(5, 2); }

"¬+¬"   { Token(8, 0); }
"¬-¬"   { Token(8, 1); }
"¬*¬"   { Token(8, 2); }
"¬/¬"   { Token(8, 3); }
"¬^¬"   { Token(8, 4); }
"¬%¬"   { Token(8, 5); }

"::"    { Token(9, 0); }
"¿:"    { Token(9, 1); }
">:"    { Token(9, 4); }
"<:"    { Token(9, 5); }
">"     { Token(9, 2); }
"<"     { Token(9, 3); }

"$"     {   Token(4, (int)'$'); }
"%"     {   Token(4, (int)'%'); }
"("     {   Token(4, (int)'('); }
")"     {   Token(4, (int)')'); }
"{"     {   Token(4, (int)'{'); }
"}"     {   Token(4, (int)'}'); }
"["     {   Token(4, (int)'['); }
"]"     {   Token(4, (int)']'); }
";"     {   Token(4, (int)';'); }
"."     {   Token(4, (int)'.'); }

. { fprintf(stderr,"Error Léxico en la línea %d: %s\n",yylineno,yytext); }

%%

int buscar(const char *id) {
    for (int i = 0; i < possimbolo; ++i) {
        if (strcmp(tabladeSimbolos[i].nom, id) == 0) return i;
    }
    return -1;
}

int insertarSimbolo(const char *s) {
    if (possimbolo >= TABLA) tablaLlena("Tabla de símbolos llena\n");
    tabladeSimbolos[possimbolo].pos  = possimbolo;
    tabladeSimbolos[possimbolo].nom  = strdup(s);
    tabladeSimbolos[possimbolo].tipo = -1;
    return possimbolo++;
}

int insertarCadena(const char *cadena) {
    if (posCadena >= TABLA) tablaLlena("Tabla de cadenas llena\n");
    tabladeCadenas[posCadena].pos  = posCadena;
    tabladeCadenas[posCadena].dato = strdup(cadena);
    return posCadena++;
}
int insertarReal(const char *real) {
    if (posReales >= TABLA) tablaLlena("Tabla de reales llena\n");
    tabladeReales[posReales].pos  = posReales;
    tabladeReales[posReales].dato = strdup(real);
    return posReales++;
}

void Token(int clase, int valor) {
    switch (clase) {
        case 2:
            printf("[%d],[%d] -> %s\n", clase, valor, tabladeSimbolos[valor].nom);
            break;
        case 6:
            printf("[%d],[%d] -> %s\n", clase, valor, tabladeReales[valor].dato);
            break;
        case 7:
            printf("[%d],[%d] -> %s\n", clase, valor, tabladeCadenas[valor].dato);
            break;
        default:
            printf("[%d],[%d] \n", clase, valor);
    }
}

void mostrarTablaDeSimbolos(void) {
    puts("\nTabla de símbolos");
    puts("pos  nombre                 tipo");
    for (int i = 0; i < possimbolo; ++i) {
        printf("%-3d  %-20s   %d\n", tabladeSimbolos[i].pos, tabladeSimbolos[i].nom, tabladeSimbolos[i].tipo);
    }
}

static void imprimirTablaLit(const char *titulo, Literal *tab, int n) {
    printf("\n%s\n", titulo);
    puts("pos  dato");
    for (int i = 0; i < n; ++i) {
        printf("%-3d  %s\n", tab[i].pos, tab[i].dato);
    }
}

void mostrarTablasDeLiterales(void) {
    imprimirTablaLit("Tabla de literales ctes reales",  tabladeReales,  posReales);
    imprimirTablaLit("Tabla de literales ctes cadena",  tabladeCadenas, posCadena);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { fprintf(stderr, "No se pudo abrir '%s'\n", argv[1]); return 1; }
    }
    puts("Tokens (clase,valor):");
    yylex();
    mostrarTablaDeSimbolos();
    mostrarTablasDeLiterales();
    if (yyin && yyin != stdin) fclose(yyin);
    return 0;
}
