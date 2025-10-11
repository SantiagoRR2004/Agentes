// Agent ptolemyIX in project family

{ include("family.asl") }

/* Initial beliefs and rules */

es_padre_de(ptolemyVII,ptolemyIX).
es_madre_de(cleopatraIII,ptolemyIX).

divorciados(ptolemyIX,cleopatraIV).
es_padre_de(ptolemyIX,ptolemyXII).

casadoCon(ptolemyIX,cleopatraSeleneI).
es_padre_de(ptolemyIX,bereniceIII).

/* Initial goals */


/* Plans for events and intentions */

