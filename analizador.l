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
{letra_min}+(_{letra_min}+)*{digito}* {   Token(2, buscar(yytext)); }
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
"^=" {   Token(3, 9); }
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
"¿:" {   Token(9, 1); }
">" {   Token(9, 2); }
"<" {   Token(9, 3); }
">:" {   Token(9, 4); }
"<:" {   Token(9, 5); }


"$" {   Token(4, (int)'$'); }
"%" {   Token(4, (int)'%'); }
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

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <archivo_de_entrada>\n", argv[0]);
        return 1;
    }
    FILE *archivo = fopen(argv[1], "r");
    if (!archivo) {
        perror("Error al abrir el archivo");
        return 1;
    }
    yyin = archivo;
    printf("--- INICIO DEL ANÁLISIS LÉXICO ---\n");
    printf("--- Secuencia de Tokens ---\n");
    yylex();
    printf("\n--- FIN DEL ANÁLISIS LÉXICO ---\n\n");
    mostrarTablaDeSimbolos();
    mostrarTablasDeLiterales();
    fclose(archivo);
    return 0;
}

/* --- IMPLEMENTACIÓN DE FUNCIONES AUXILIARES --- */
void   Token(int clase, int valor) {
    printf("<%d, %d> ", clase, valor);
}

int buscar(char *id) {
    for (int i = 0; i < possimbolo; i++) {
        if (strcmp(tabladeSimbolos[i].nom, id) == 0) {
            return i;
        }
    }
    if (possimbolo < TABLA) {
        tabladeSimbolos[possimbolo].nom = strdup(id);
        tabladeSimbolos[possimbolo].pos = possimbolo;
        tabladeSimbolos[possimbolo].tipo = -1;
        return possimbolo++;
    } else {
        printf("Error: Tabla de símbolos llena.\n");
        exit(1);
    }
}

int insertarCadena(char *cadena) {
    if (posCadena < TABLA) {
        tabladeCadenas[posCadena].dato = strdup(cadena);
        tabladeCadenas[posCadena].pos = posCadena;
        return posCadena++;
    } else {
        printf("Error: Tabla de literales de cadena llena.\n");
        exit(1);
    }
}

int insertarReal(char *real) {
    if (posReales < TABLA) {
        tabladeReales[posReales].dato = strdup(real);
        tabladeReales[posReales].pos = posReales;
        return posReales++;
    } else {
        printf("Error: Tabla de literales de reales llena.\n");
        exit(1);
    }
}

/* --- FUNCIONES PARA MOSTRAR LAS TABLAS --- */
void mostrarTablaDeSimbolos() {
    printf("--- Tabla de Símbolos ---\n");
    printf("Posición | Nombre\t\t| Tipo\n");
    printf("---------------------------------------\n");
    for (int i = 0; i < possimbolo; i++) {
        printf("%-8d | %-22s | %d\n", tabladeSimbolos[i].pos, tabladeSimbolos[i].nom, tabladeSimbolos[i].tipo);
    }
    printf("\n");
}

void mostrarTablasDeLiterales() {
    printf("--- Tabla de Literales (Cadenas) ---\n");
    printf("Posición | Dato\n");
    printf("---------------------------------------\n");
    for (int i = 0; i < posCadena; i++) {
        printf("%-8d | %s\n", tabladeCadenas[i].pos, tabladeCadenas[i].dato);
    }
    printf("\n");

    printf("--- Tabla de Literales (Reales) ---\n");
    printf("Posición | Dato\n");
    printf("---------------------------------------\n");
    for (int i = 0; i < posReales; i++) {
        printf("%-8d | %s\n", tabladeReales[i].pos, tabladeReales[i].dato);
    }
    printf("\n");
}

int yywrap() {
    return 1;
}
