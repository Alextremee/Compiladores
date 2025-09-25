%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* --- Estructura para representar un Token --- 
   clase: tipo de token (reservada, identificador, operador, etc.)
   valor: referencia (posición en tabla o valor numérico) */
struct token {
    int clase;
    int valor;
};

/* --- Estructura para la Tabla de Símbolos --- 
   pos: posición en la tabla
   nom: nombre del identificador
   tipo: tipo de dato (inicialmente -1) */
struct Simbolo {
    int pos;
    char *nom;
    int tipo;
};

/* --- Estructura para las Tablas de Literales (cadenas y reales) --- 
   pos: posición en la tabla
   dato: contenido del literal */
struct literal {
    int pos;
    char *dato;
};

/* --- Definiciones de capacidad máxima de tablas --- */
#define TABLA 100

/* --- Declaración de Tablas Globales --- */
struct Simbolo tabladeSimbolos[TABLA];
int possimbolo = 0;

struct literal tabladeCadenas[TABLA];
int posCadena = 0;

struct literal tabladeReales[TABLA];
int posReales = 0;

/* Variable externa de Flex para obtener el número de línea */
extern int yylineno;

/* Prototipos de funciones auxiliares */
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

/* --- Manejo de separadores --- */
[ \t\n]+ { /* Se ignora cualquier espacio, tabulador o salto de línea */ }

/* --- Manejo de comentarios --- 
   Se definen como texto entre comillas dobles */
\"[^"\n]*\" { /* Se ignoran los comentarios entre comillas */ }

/* --- Palabras reservadas --- */
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

/* --- Constantes enteras --- */
[+\-]?{digito}+ {   Token(1, atoi(yytext)); }

/* --- Identificadores --- 
   Comienzan con letras minúsculas, 
   pueden incluir guiones bajos y terminan opcionalmente con dígitos */
{letra_min}+(_{letra_min}+)*{digito}* {   Token(2, buscar(yytext)); }

/* --- Constantes reales --- 
   Notación con '@' y parte opcional de exponente con '@@' */
[+\-]?{digito}+"@"{digito}+("@@"[+\-]?{digito}+)? {   Token(6, insertarReal(yytext)); }

/* --- Constantes de cadena --- 
   Se encierran con símbolos ¿ y ? */
"¿"[^?\n]*"?" {   Token(7, insertarCadena(yytext)); }

/* --- Operadores de asignación --- */
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


/* --- Operadores lógicos --- */
"\\" {   Token(5, 0); }
"//" {   Token(5, 1); }
"||" {   Token(5, 2); }

/* --- Operadores aritméticos (notación especial con ¬) --- */
"¬+¬" { Token(8, 0); }
"¬-¬" { Token(8, 1); }
"¬*¬" { Token(8, 2); }
"¬/¬" { Token(8, 3); }
"¬^¬" { Token(8, 4); }
"¬%¬" { Token(8, 5); }

/* --- Operadores relacionales --- */
"::" {   Token(9, 0); }
"¿:" {   Token(9, 1); }
">" {   Token(9, 2); }
"<" {   Token(9, 3); }
">:" {   Token(9, 4); }
"<:" {   Token(9, 5); }

/* --- Símbolos especiales --- */
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

/* --- Manejo de errores léxicos --- */
. { printf("Error Léxico en la línea %d: Símbolo no reconocido '%s'\n", yylineno, yytext); }

%%

/* --- Función principal --- */
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
     /* Llamada al analizador generado por Flex */
    yylex();
    printf("\n--- FIN DEL ANÁLISIS LÉXICO ---\n\n");
     /* Mostrar las tablas construidas */
    mostrarTablaDeSimbolos();
    mostrarTablasDeLiterales();
    fclose(archivo);
    return 0;
}

/* --- IMPLEMENTACIÓN DE FUNCIONES AUXILIARES --- */
/* Imprime el token en el formato <clase, valor> */
void   Token(int clase, int valor) {
    printf("<%d, %d> ", clase, valor);
}

/* Busca un identificador en la tabla de símbolos. 
   Si no existe, lo inserta. */
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

/* Inserta un literal de cadena en su tabla */
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

/* Inserta un literal real en su tabla */
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

/* --- Mostrar las tablas de literales (cadenas y reales) --- */
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

/* Función especial que indica a Flex que no hay más input */
int yywrap() {
    return 1;
}
