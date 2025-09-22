%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct token {
    int clase;
    int valor;
};

struct Simbolo {
    int pos;
    char *nom;
    int tipo;
};

struct literal {
    int pos;
    char *dato;
};

#define TABLA 100

struct Simbolo tabladeSimbolos[TABLA];
int possimbolo = 0;

struct literal tabladeCadenas[TABLA];
int posCadena = 0;

struct literal tabladeReales[TABLA];
int posReales = 0;

extern int yylineno;

void   Token(int clase, int valor);
int buscar(char *id);
int insertarCadena(char *cadena);
int insertarReal(char *real);
void mostrarTablaDeSimbolos();      
void mostrarTablasDeLiterales();    

%}

/* --- Definiciones de Nombres para Expresiones Regulares --- */
digito [0-9]
letra_min [a-z]

%%

[ \t\n]+ { /* Se ignora cualquier espacio, tabulador o salto de línea */ }
\"[^"\n]*\" { /* Se ignoran los comentarios entre comillas */ }


"cadena" {   Token(0, 0); }
"caso" {   Token(0, 1); }
"entero" {   Token(0, 2); }
"flotante" {   Token(0, 3); }
"hacer" {   Token(0, 4); }
"mientras" {   Token(0, 5); }
"ocaso" {   Token(0, 6); }
"para" {   Token(0, 7); }
"predet" {   Token(0, 8); }
"salir" {   Token(0, 9); }
"select" {   Token(0, 10); }
"si" {   Token(0, 11); }
"vacio" {   Token(0, 12); }


[+\-]?{digito}+ {   Token(1, atoi(yytext)); }
{letra_min}+(_?{letra_min}+)*{digito}* {   Token(2, buscar(yytext)); }
[+\-]?{digito}+"@"{digito}+("@@"[+\-]?{digito}+)? {   Token(6, insertarReal(yytext)); }
"¿"[^?\n]*"?" {   Token(7, insertarCadena(yytext)); }


"=" {   Token(3, 0); }
"*=" {   Token(3, 1); }
"/=" {   Token(3, 2); }
"+=" {   Token(3, 3); }
"-=" {   Token(3, 4); }
"%=" {   Token(3, 5); }
"<<=" {   Token(3, 6); }
">>=" {   Token(3, 7); }
"&=" {   Token(3, 8); }
"|=" {   Token(3, 10); }



"\\" {   Token(5, 0); }
"//" {   Token(5, 1); }
"||" {   Token(5, 2); }


"¬+¬" { Token(8, 0); }
"¬-¬" { Token(8, 1); }
"¬*¬" { Token(8, 2); }
"¬/¬" { Token(8, 3); }
"¬^¬" { Token(8, 4); }
"¬%¬" { Token(8, 5); }



"::" {   Token(9, 0); }
"!=" {   Token(9, 1); }
">" {   Token(9, 2); }
"<" {   Token(9, 3); }
">:" {   Token(9, 4); }
"<:" {   Token(9, 5); }


"$" {   Token(4, (int)'$'); }
"(" {   Token(4, (int)'('); }
")" {   Token(4, (int)')'); }
"{" {   Token(4, (int)'{'); }
"}" {   Token(4, (int)'}'); }
"[" {   Token(4, (int)'['); }
"]" {   Token(4, (int)']'); }
";" {   Token(4, (int)';'); }
"." {   Token(4, (int)'.'); }


. { printf("Error Léxico en la línea %d: Símbolo no reconocido '%s'\n", yylineno, yytext); }

%%


