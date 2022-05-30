

package analiLex;

import java_cup.runtime.*;
import java.io.Reader;
      
%% //inicio de opciones
   

   

%class Lexer

/*
    Activar el contador de lineas, variable yyline
    Activar el contador de columna, variable yycolumn
*/
%line
%column
    
/* 
   Activamos la compatibilidad con Java CUP para analizadores
   sintacticos(parser)
*/
%cup
   
/*
    Declaraciones

    El codigo entre %{  y %} sera copiado integramente en el 
    analizador generado.
*/
%{
    /*Para almacenar temporalmente las cadenas*/
    private StringBuilder string = new StringBuilder();

    /*  Generamos un java_cup.Symbol para guardar el tipo de token 
        encontrado */
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    
    /* Generamos un Symbol para el tipo de token encontrado 
       junto con su valor */
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}
   

/*
    Macro declaraciones
  
    Declaramos expresiones regulares que despues usaremos en las
    reglas lexicas.
*/
   
/*  Un salto de linea es un \n, \r o \r\n dependiendo del SO   */
Salto = \r|\n|\r\n
   
/* Espacio es un espacio en blanco, tabulador \t, salto de linea 
    o avance de pagina \f, normalmente son ignorados */
Espacio     = {Salto} | [ \t\f]
   
/* Una literal entera es un numero 0 oSystem.out.println("\n*** Generado " + archNombre + "***\n"); un digito del 1 al 9 
    seguido de 0 o mas digitos del 0 al 9 */
Entero = 0 | [1-9][0-9]*

Identificador = [a-zA-Z]([a-zA-Z0-9])*

/*Cualquier caracter que no sea de escape o comilla simple*/
CaracterCadena = [^\r\n\"\\] //Para poder detectar "

/*Un estado temporal para manejar cadenas y sus caracteres de escape*/
%state CADENA

%% //fin de opciones
/* -------------------- Seccion de reglas lexicas ------------------ */
   
/*
   Esta seccion contiene expresiones regulares y acciones. 
   Las acciones son código en Java que se ejecutara cuando se
   encuentre una entrada valida para la expresion regular correspondiente */
   
   /* YYINITIAL es el estado inicial del analizador lexico al escanear.
      Las expresiones regulares solo serán comparadas si se encuentra
      en ese estado inicial. Es decir, cada vez que se encuentra una 
      coincidencia el scanner vuelve al estado inicial. Por lo cual se ignoran
      estados intermedios.*/
   
<YYINITIAL> {
   /* Regresa que el token OP_IGUAL declarado en la clase sym fue encontrado. 
    */
    "=="                {  
                          return symbol(sym.OP_IGUAL); }
   /* Regresa que el token OP_DIFER declarado en la clase sym fue encontrado. 
    */
    "!="                {  
                          return symbol(sym.OP_DIFER); }
    /* Regresa que el token OP_MENOR declarado en la clase sym fue encontrado. 
    */
    "<"                {  
                          return symbol(sym.OP_MENOR); }
    /* Regresa que el token SEMI declarado en la clase sym fue encontrado. */
    ";"                { return symbol(sym.SEMI); }
    /* Regresa que el token OP_SUMA declarado en la clase sym fue encontrado. */
    "+"                {  
                          return symbol(sym.OP_SUMA); }
    /* Regresa que el token OP_SUMA declarado en la clase sym fue encontrado. */
    "-"                {  
                          return symbol(sym.OP_RESTA); }
    /* Regresa que el token OP_SUMA declarado en la clase sym fue encontrado. */
    "*"                {  
                          return symbol(sym.OP_MULT); }
    /* Regresa que el token OP_ASIGN declarado en la clase sym fue encontrado.
    */
    "="                {  
                          return symbol(sym.OP_ASIGN); }
    /* Regresa que el token PARENIZQ declarado en la clase sym fue encontrado. */
    "("                {  
                          return symbol(sym.PARENIZQ); }
                          /* Regresa que el token PARENIZQ declarado en la clase sym fue encontrado. */
    ")"                {  
                          return symbol(sym.PARENDER); }
    /* Regresa que el token OP_LLAVEDER declarado en la clase sym fue 
encontrado.
    */
    "{"                {  AnalizadorSintactico.addBloque();
                          return symbol(sym.LLAVEIZQ); }
    /* Regresa que el token LLAVEIZQ declarado en la 
clase sym fue encontrado. */
    "}"                {  
                          return symbol(sym.LLAVEDER); }
    /* Regresa que el token OP_AND declarado en la clase sym fue encontrado. 
    */
    "&"                {  
                          return symbol(sym.OP_AND); }
    /* Regresa que el token OP_OR declarado en la clase 
sym fue encontrado. 
    */
    "|"                {  
                          return symbol(sym.OP_OR); }
    /* Regresa que el token OP_NOT declarado en la clase sym fue encontrado. 
    */
    "!"                {  
                          return symbol(sym.OP_NOT ); }
    /* Palabra reservada para imprimir un texto en consola */
    "IMPRIMIR"         {return symbol(sym.IMPRIMIR);}


    /* Si encuentra una cadena */
    \"            /*"*/     { yybegin(CADENA); //Una cadena inicia con "
                          string.setLength(0);
                       }
    
   
    /* Si se encuentra un entero, se imprime, se regresa un token numero
        que representa un entero y el valor que se obtuvo de la cadena yytext
        al convertirla a entero. yytext es el token encontrado. */
    {Entero}         {   
                      return symbol(sym.ENTERO, Integer.parseInt(yytext())); 
                     }
                     
    /* Regresa que el token OP_SI declarado en la clase sym fue encontrado. 
    */
    "si"                {  
                          return symbol(sym.OP_SI); }
    /* Regresa que el token OP_NO declarado en la clase sym fue encontrado. 
    */
    "no"                {  
                          return symbol(sym.OP_NO); }

    {Identificador}   {
			Simbolo s = 
			  AnalizadorSintactico.programa.getTabla().get(
			    yytext());
			return symbol(sym.ID, s);
		      }
		      
    /* No hace nada si encuentra el espacio en blanco */
    {Espacio}       { /* ignora el espacio */ } 
}
 /* Estado especial para procesar cadenas*/
<CADENA> {
  \"   /*"*/   { yybegin(YYINITIAL);//Cadena finaliza con
                return symbol(sym.CADENA, string.toString()); }
          
  {CaracterCadena}+             { string.append( yytext() ); }
  
  /* Caracteres de escape */
  "\\b"                          { string.append( '\b' ); }
  "\\t"                          { string.append( '\t' ); }
  "\\n"                          { string.append( '\n' ); }
  "\\f"                          { string.append( '\f' ); }
  "\\r"                          { string.append( '\r' ); }
  "\\\""                         { string.append( '\"' ); }
  "\\'"                          { string.append( '\'' ); }
  "\\\\"                         { string.append( '\\' ); }
  {Salto}                        { /*Ignoramos los saltos dentro de cadenas*/}

  //Errores
  \\.                            { throw new RuntimeException("Secuencia de escape ilegal \""+yytext()+"\""); }
}


/* Si el token contenido en la entrada no coincide con ninguna regla
    entonces se marca un token ilegal */
[^]                    { throw new Error("Caracter ilegal <"+yytext()+">"); }
